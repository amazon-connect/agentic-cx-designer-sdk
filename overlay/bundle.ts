// Resource bundles: export a resource with everything it depends on, and import
// one into another workspace.
//
// Copied into the generated package's `src/` at build time alongside wrapper.ts
// and bundle-format.ts (see scripts/inject-wrapper.mjs). The `./index` and
// `./wrapper` imports resolve there, not here, so this file cannot be compiled
// from `overlay/` — the format logic it builds on lives in bundle-format.ts,
// which can.
import {
  GetApplicationCommand,
  GetDataRequestCommand,
  GetFlowCommand,
  GetGuardrailCommand,
  GetKnowledgeBaseCommand,
  GetLiveSyncScriptCommand,
  GetModalityCommand,
  GetSlotTypeCommand,
  ListAnalyticsTagsCommand,
  ListContextVariablesCommand,
  ListKnowledgeBaseArticlesCommand,
  CreateAnalyticsTagCommand,
  CreateApplicationCommand,
  CreateContextVariableCommand,
  CreateDataRequestCommand,
  CreateFlowCommand,
  CreateGuardrailCommand,
  CreateKnowledgeBaseArticleCommand,
  CreateKnowledgeBaseCommand,
  CreateLiveSyncScriptCommand,
  CreateModalityCommand,
  CreateSlotTypeCommand,
  ValidateResourceCommand,
} from "./index";
import type { AgenticCXDesignerClient } from "./wrapper";
import { remapIds } from "./wrapper";
import {
  assertReadable,
  classifyGraph,
  collectPages,
  emptyBundle,
  ON_THE_WIRE,
  selectFromList,
  type BundleResourceType,
  type ResourceBundle,
} from "./bundle-format";

/** What an import created, keyed the way the bundle named it. */
export interface ImportOutcome {
  idMap: Record<string, string>;
  created: Partial<Record<BundleResourceType, Record<string, unknown>[]>>;
}

/**
 * Export `root` together with every resource reachable from it.
 *
 * The dependency set comes from the validator's graph rather than from reading
 * the resource's own settings, so something several hops away — a slot type used
 * by a flow that another flow redirects to — is carried too.
 *
 * @example
 * const bundle = await exportBundle(client, {
 *   resourceType: "applications",
 *   resourceId: applicationId,
 * });
 */
export const exportBundle = async (
  client: AgenticCXDesignerClient,
  root: { resourceType: BundleResourceType; resourceId: string },
): Promise<ResourceBundle> => {
  const graph = await client.send(
    new ValidateResourceCommand({
      mode: "graph",
      resourceType: root.resourceType,
      resourceId: root.resourceId,
    }),
  );

  // Back to the validator's names, which is what the format is written in. An
  // unrecognised type keeps its own name so it lands in `unsupported` rather
  // than becoming undefined.
  const nodes = (graph.resources ?? []).map((node) => {
    const sdkType = node.resource!.type as BundleResourceType;
    return {
      type: ON_THE_WIRE[sdkType] ?? String(sdkType),
      id: node.resource!.id!,
      name: node.resource!.name,
    };
  });

  const { carried, unsupported } = classifyGraph(nodes, {
    type: root.resourceType,
    id: root.resourceId,
  });

  const bundle = emptyBundle({
    type: root.resourceType,
    id: root.resourceId,
  });
  bundle.unsupported = unsupported;

  const idsOf = (type: BundleResourceType) =>
    (carried.get(type) ?? []).map((r) => r.id);

  const fetchEach = async (
    type: BundleResourceType,
    get: (id: string) => Promise<unknown>,
  ): Promise<Record<string, unknown>[]> =>
    (await Promise.all(idsOf(type).map(get))) as Record<string, unknown>[];

  bundle.applications = await fetchEach("applications", (id) =>
    client.send(new GetApplicationCommand({ applicationIdentifier: id })),
  );
  bundle.flows = await fetchEach("flows", (id) =>
    client.send(new GetFlowCommand({ flowIdentifier: id })),
  );
  bundle.liveSyncScripts = await fetchEach("liveSyncScripts", (id) =>
    client.send(new GetLiveSyncScriptCommand({ liveSyncScriptIdentifier: id })),
  );
  bundle.slotTypes = await fetchEach("slotTypes", (id) =>
    client.send(new GetSlotTypeCommand({ slotTypeIdentifier: id })),
  );
  bundle.dataRequests = await fetchEach("dataRequests", (id) =>
    client.send(new GetDataRequestCommand({ dataRequestIdentifier: id })),
  );
  bundle.modalities = await fetchEach("modalities", (id) =>
    client.send(new GetModalityCommand({ modalityIdentifier: id })),
  );
  bundle.guardrails = await fetchEach("guardrails", (id) =>
    client.send(new GetGuardrailCommand({ guardrailIdentifier: id })),
  );

  // Knowledge bases carry their articles, which are a separate collection.
  // Note the member is `knowledgeBaseId`, not the `...Identifier` every other
  // resource uses.
  bundle.knowledgeBases = await Promise.all(
    idsOf("knowledgeBases").map(async (id) => {
      const [knowledgeBase, articles] = await Promise.all([
        client.send(new GetKnowledgeBaseCommand({ knowledgeBaseId: id })),
        collectPages((nextToken) =>
          client.send(
            new ListKnowledgeBaseArticlesCommand({
              knowledgeBaseId: id,
              nextToken,
            }),
          ),
        ),
      ]);
      return { ...knowledgeBase, articles } as Record<string, unknown>;
    }),
  );

  // No GetContextVariable or GetAnalyticsTag operation exists, so these are
  // listed and filtered rather than fetched by id.
  bundle.contextVariables = await selectFromList(
    idsOf("contextVariables"),
    (nextToken) => client.send(new ListContextVariablesCommand({ nextToken })),
    (item) => (item as { name?: string }).name,
  );
  bundle.analyticsTags = await selectFromList(
    idsOf("analyticsTags"),
    (nextToken) => client.send(new ListAnalyticsTagsCommand({ nextToken })),
    (item) => (item as { name?: string }).name,
  );

  return bundle;
};

/**
 * Create everything in a bundle in the target workspace.
 *
 * Order matters and so do the ids. Most resources are keyed by a name you chose,
 * which survives the move; knowledge bases and guardrails are assigned an id on
 * creation, so they are created before the flows and applications that reference
 * them and their new ids are substituted in (see `remapIds`).
 *
 * Throws on the first failure, leaving what it already created in place — there
 * is no rollback. The returned `idMap` is what you need to reconcile a partial
 * run, so keep it.
 *
 * @example
 * const { idMap } = await importBundle(client, bundle);
 */
export const importBundle = async (
  client: AgenticCXDesignerClient,
  bundle: ResourceBundle,
): Promise<ImportOutcome> => {
  assertReadable(bundle);

  const idMap: Record<string, string> = {};
  const created: ImportOutcome["created"] = {};

  const createAll = async (
    type: BundleResourceType,
    payloads: Record<string, unknown>[],
    create: (payload: Record<string, unknown>) => Promise<unknown>,
  ) => {
    const results: Record<string, unknown>[] = [];
    for (const payload of payloads) {
      results.push((await create(payload)) as Record<string, unknown>);
    }
    created[type] = results;
    return results;
  };

  // Keep this sequence in step with IMPORT_ORDER in bundle-format.ts, which the
  // tests assert against.
  await createAll("contextVariables", bundle.contextVariables, (p) =>
    client.send(new CreateContextVariableCommand(p)),
  );
  await createAll("analyticsTags", bundle.analyticsTags, (p) =>
    client.send(new CreateAnalyticsTagCommand(p)),
  );
  await createAll("slotTypes", bundle.slotTypes, (p) =>
    client.send(new CreateSlotTypeCommand(p)),
  );
  await createAll("dataRequests", bundle.dataRequests, (p) =>
    client.send(new CreateDataRequestCommand(p)),
  );
  await createAll("modalities", bundle.modalities, (p) =>
    client.send(new CreateModalityCommand(p)),
  );
  await createAll("liveSyncScripts", bundle.liveSyncScripts, (p) =>
    client.send(new CreateLiveSyncScriptCommand(p)),
  );

  // Knowledge bases and guardrails are assigned their ids here, so everything
  // after this point goes through remapIds.
  const knowledgeBases: Record<string, unknown>[] = [];
  for (const entry of bundle.knowledgeBases) {
    const { articles = [], ...knowledgeBase } = entry as {
      articles?: Record<string, unknown>[];
    };
    const result = (await client.send(
      new CreateKnowledgeBaseCommand(knowledgeBase as Record<string, unknown>),
    )) as { knowledgeBaseId?: string };

    const oldId = (knowledgeBase as { knowledgeBaseId?: string })
      .knowledgeBaseId;
    if (oldId && result.knowledgeBaseId) idMap[oldId] = result.knowledgeBaseId;

    for (const article of articles) {
      await client.send(
        new CreateKnowledgeBaseArticleCommand({
          ...article,
          knowledgeBaseId: result.knowledgeBaseId,
        }),
      );
    }
    knowledgeBases.push(result as Record<string, unknown>);
  }
  created.knowledgeBases = knowledgeBases;

  const guardrails: Record<string, unknown>[] = [];
  for (const guardrail of bundle.guardrails) {
    const result = (await client.send(
      new CreateGuardrailCommand(guardrail),
    )) as { guardrailId?: string };
    const oldId = (guardrail as { guardrailId?: string }).guardrailId;
    if (oldId && result.guardrailId) idMap[oldId] = result.guardrailId;
    guardrails.push(result as Record<string, unknown>);
  }
  created.guardrails = guardrails;

  await createAll("flows", bundle.flows, (p) =>
    client.send(new CreateFlowCommand(remapIds(p, idMap))),
  );
  await createAll("applications", bundle.applications, (p) =>
    client.send(new CreateApplicationCommand(remapIds(p, idMap))),
  );

  return { idMap, created };
};
