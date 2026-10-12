// Resource bundles: export a resource with everything it depends on, and import
// one into another workspace.
//
// Copied into the generated package's `src/` at build time alongside wrapper.ts
// and bundle-format.ts (see scripts/inject-wrapper.mjs). The `./index` and
// `./wrapper` imports resolve there, not here, so this file cannot be compiled
// from `overlay/` — the format logic it builds on lives in bundle-format.ts,
// which can.
import {
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
  ExportResourceCommand,
  GetDownloadCommand,
} from "./index";
import type { AgenticCXDesignerClient } from "./wrapper";
import { remapIds } from "./wrapper";
import {
  assertReadable,
  type BundleResourceType,
  type CarriedResourceType,
  type ResourceBundle,
} from "./bundle-format";

/** What an import created, keyed the way the bundle named it. */
export interface ImportOutcome {
  idMap: Record<string, string>;
  created: Partial<Record<BundleResourceType, Record<string, unknown>[]>>;
}

export interface ExportOptions {
  /** How long to keep polling before giving up. Default 10 minutes. */
  timeoutMs?: number;
  /** Gap between polls. Default 2 seconds. */
  pollIntervalMs?: number;
  /**
   * Idempotency token. Supply one to make this call safe to repeat: a retry
   * answers the export the first call started instead of running a second one.
   * The generated client fills one in per call if omitted, which does not
   * survive a process restart — pass your own if you resume work.
   */
  clientToken?: string;
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Export `resourceId` together with every resource reachable from it.
 *
 * The dependency set is computed by the service from its resource graph rather
 * than from reading the resource's own settings, so something several hops away
 * — a slot type used by a flow that another flow redirects to — is carried too.
 *
 * The export is asynchronous because a bundle for a large workspace exceeds what
 * a single response can carry. This starts it, polls until the file is ready,
 * and downloads it; `ConflictException` from GetDownload is the "still
 * generating" signal and is what the polling loop waits on.
 *
 * @example
 * const bundle = await exportBundle(client, {
 *   resourceType: "applications",
 *   resourceId: applicationId,
 * });
 */
export const exportBundle = async (
  client: AgenticCXDesignerClient,
  root: { resourceType: CarriedResourceType; resourceId: string },
  options: ExportOptions = {},
): Promise<ResourceBundle> => {
  const { timeoutMs = 600_000, pollIntervalMs = 2_000, clientToken } = options;

  const started = await client.send(
    new ExportResourceCommand({
      resourceType: root.resourceType,
      resourceId: root.resourceId,
      ...(clientToken === undefined ? {} : { clientToken }),
    }),
  );

  const downloadIdentifier = started.downloadIdentifier!;
  const deadline = Date.now() + timeoutMs;

  let url: string | undefined;
  while (url === undefined) {
    try {
      const download = await client.send(
        new GetDownloadCommand({ downloadIdentifier }),
      );
      url = download.url!;
    } catch (error) {
      // A 409 means the workflow has not finished writing the file. Anything
      // else — the export failed, the id is unknown, the caller lost access —
      // is not something more waiting will fix.
      if ((error as { name?: string }).name !== "ConflictException") throw error;
      if (Date.now() >= deadline) {
        throw new Error(
          `Export ${downloadIdentifier} was still generating after ${Math.round(timeoutMs / 1000)}s. It may still complete; poll GetDownload with that identifier.`,
        );
      }
      await sleep(pollIntervalMs);
    }
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(
      `Failed to download export ${downloadIdentifier}: ${response.status} ${response.statusText}`,
    );
  }

  const bundle = (await response.json()) as ResourceBundle;
  assertReadable(bundle);
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
