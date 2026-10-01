// Hand-written client wrapper, layered on top of the Smithy-generated client.
//
// This file is copied into the generated package's `src/` at build time (see
// scripts/inject-wrapper.mjs, invoked by the GitHub build/publish workflows)
// and re-exported from the generated `index.ts`, shadowing the generated
// `AgenticCXDesignerClient` export under the same name. Because it lives in
// `src/` at compile time, the `./AgenticCXDesignerClient` import resolves there
// (it will show as unresolved while sitting in `overlay/` — that is expected).
//
// It provides three ergonomic conveniences the generated client cannot:
//   1. Flatten `apiKey`: accept a plain string and normalize it into the
//      `@httpApiKeyAuth` identity shape (`{ apiKey }`) the signer expects.
//   2. Inject the `x-workspace-id` header from a flat `workspaceId` option
//      (a per-request tenancy header that is not part of the auth model).
//   3. `remapIds`, for copying resources between workspaces: substitute the ids
//      a target workspace has just assigned into payloads that still carry the
//      ids they were exported with.
import {
  AgenticCXDesignerClient as GeneratedClient,
  type AgenticCXDesignerClientConfig,
} from "./AgenticCXDesignerClient";

/** Client configuration with flattened `apiKey` and a `workspaceId` convenience. */
export interface AgenticCXDesignerClientFlatConfig
  extends Omit<AgenticCXDesignerClientConfig, "apiKey"> {
  /** API key value. Accepts a plain string; normalized to the SDK identity shape. */
  apiKey?: string | AgenticCXDesignerClientConfig["apiKey"];
  /** Workspace id, sent as the `x-workspace-id` header on every request. */
  workspaceId?: string;
}

/**
 * Drop-in replacement for the generated `AgenticCXDesignerClient` that accepts a
 * flat `apiKey` string and a `workspaceId`. All other configuration and every
 * command are inherited unchanged from the generated client.
 */
export class AgenticCXDesignerClient extends GeneratedClient {
  constructor(config: AgenticCXDesignerClientFlatConfig = {}) {
    const { apiKey, workspaceId, ...rest } = config;
    super({
      ...rest,
      apiKey: typeof apiKey === "string" ? { apiKey } : apiKey,
    } as AgenticCXDesignerClientConfig);

    if (workspaceId) {
      this.middlewareStack.add(
        (next) => async (args) => {
          (args.request as { headers: Record<string, string> }).headers[
            "x-workspace-id"
          ] = workspaceId;
          return next(args);
        },
        { step: "build", name: "addWorkspaceHeader" },
      );
    }
  }
}

/**
 * Substitute newly assigned resource ids throughout a payload.
 *
 * Copying resources from one workspace to another, most ids survive the move:
 * flows, slot types, data requests, modalities and context variables are keyed by
 * a name you chose. Knowledge bases and guardrails are not — the backend assigns
 * those — and they are referenced from places as deep as a flow node's
 * `metadata.knowledgeBase.knowledgeBaseId` or an application's
 * `settings.defaultFlows`.
 *
 * Collect each new id as you create it, then pass the payloads that refer to them
 * through this on the way to their own `Create*Command`. Substituting on the
 * serialized form means callers don't have to enumerate the reference sites, which
 * change as the flow schema grows.
 *
 * Ids are matched as whole strings, so the substitution is only safe for the
 * server-assigned UUIDs it is meant for. Do not use it to rename a resource keyed
 * by a human-chosen name: `"Main"` would also be rewritten inside any text that
 * happens to contain it.
 *
 * @example
 * const idMap: Record<string, string> = {};
 *
 * const created = await client.send(new CreateKnowledgeBaseCommand(knowledgeBase));
 * idMap[knowledgeBase.knowledgeBaseId] = created.knowledgeBaseId;
 *
 * await client.send(new CreateFlowCommand(remapIds(flow, idMap)));
 */
export const remapIds = <T>(payload: T, idMap: Record<string, string>): T =>
  JSON.parse(
    Object.entries(idMap).reduce(
      (json, [oldId, newId]) => json.replaceAll(oldId, newId),
      JSON.stringify(payload),
    ),
  ) as T;
