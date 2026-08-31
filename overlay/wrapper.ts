// Hand-written client wrapper, layered on top of the Smithy-generated client.
//
// This file is copied into the generated package's `src/` at build time (see
// scripts/inject-wrapper.mjs, invoked by the GitHub build/publish workflows)
// and re-exported from the generated `index.ts`, shadowing the generated
// `AgenticCXDesignerClient` export under the same name. Because it lives in
// `src/` at compile time, the `./AgenticCXDesignerClient` import resolves there
// (it will show as unresolved while sitting in `overlay/` — that is expected).
//
// It provides two ergonomic conveniences the generated client cannot:
//   1. Flatten `apiKey`: accept a plain string and normalize it into the
//      `@httpApiKeyAuth` identity shape (`{ apiKey }`) the signer expects.
//   2. Inject the `x-workspace-id` header from a flat `workspaceId` option
//      (a per-request tenancy header that is not part of the auth model).
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
