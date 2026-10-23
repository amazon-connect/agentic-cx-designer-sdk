// The bundle format, with no dependency on the generated client.
//
// Split out from bundle.ts so it can be tested on its own: bundle.ts imports the
// generated commands, which only exist after `smithy build`, and so cannot be
// compiled or run from `overlay/`.
//
// The format is the one Agentic CX Designer Studio reads and writes, so a bundle
// exported here imports there and vice versa. Exporting is done by the service
// (ExportResource), which owns the writing side of this format; what is left
// here is what a client needs to read a bundle and import it.

/** Bumped when the shape changes in a way an older reader would misread. */
export const BUNDLE_FORMAT_VERSION = 2;

/** Format versions this can read. */
export const READABLE_FORMAT_VERSIONS = [1, 2];

export type BundleResourceType =
  | "applications"
  | "flows"
  | "slotTypes"
  | "dataRequests"
  | "contextVariables"
  | "analyticsTags"
  | "liveSyncScripts"
  | "knowledgeBases"
  | "modalities"
  | "secrets"
  | "guardrails";

/**
 * `root.type` and `unsupported[].type` are written with the validator's resource
 * names, not this SDK's, because that is what Studio writes and reads. Changing
 * it would make bundles from the two sides mutually unreadable.
 */
export const ON_THE_WIRE: Record<BundleResourceType, string> = {
  applications: "bot",
  flows: "intent",
  slotTypes: "slot",
  dataRequests: "variable",
  contextVariables: "contextAttribute",
  analyticsTags: "analyticsTag",
  liveSyncScripts: "journey",
  knowledgeBases: "knowledgeBase",
  modalities: "model",
  secrets: "secret",
  guardrails: "guardrail",
};

export const FROM_THE_WIRE: Record<string, BundleResourceType> =
  Object.fromEntries(
    Object.entries(ON_THE_WIRE).map(([sdk, wire]) => [wire, sdk]),
  ) as Record<string, BundleResourceType>;

/**
 * The kinds a bundle actually carries. Secrets are named in a graph but never
 * carried, so they are not a collection — which is why this is not simply
 * BundleResourceType.
 */
export type CarriedResourceType = Exclude<BundleResourceType, "secrets">;

/** The order `importBundle` creates in. Anything that is assigned an id on
 * creation has to come before whatever refers to it. */
export const IMPORT_ORDER: CarriedResourceType[] = [
  "contextVariables",
  "analyticsTags",
  "slotTypes",
  "dataRequests",
  "modalities",
  "liveSyncScripts",
  "knowledgeBases",
  "guardrails",
  "flows",
  "applications",
];

/** Resources whose ids the backend assigns, so references to them need remapping. */
export const ASSIGNED_IDS: CarriedResourceType[] = [
  "knowledgeBases",
  "guardrails",
];

/** A resource the bundle names but cannot carry, with why. */
export interface UnsupportedResource {
  type: string;
  id: string;
  name: string;
  reason: string;
}

export type ResourceBundle = {
  formatVersion: number;
  root: { type: string; id: string };
  unsupported: UnsupportedResource[];
} & { [K in CarriedResourceType]: Record<string, unknown>[] };

export const assertReadable = (bundle: { formatVersion: number }): void => {
  if (!READABLE_FORMAT_VERSIONS.includes(bundle.formatVersion)) {
    throw new Error(
      `Unreadable bundle: formatVersion ${bundle.formatVersion}, expected one of ${READABLE_FORMAT_VERSIONS.join(", ")}. Export it again from a current version.`,
    );
  }
};

/**
 * A carried knowledge base is nested — `{ knowledgeBase, articles }` — because
 * its articles are a separate resource with their own create call. Reading it
 * with a rest spread yields `{ knowledgeBase: {...} }`, which a create call
 * rejects for missing required fields it cannot see, so the split lives here
 * where it can be tested; bundle.ts cannot be compiled outside the generated
 * package.
 */
export const splitKnowledgeBaseEntry = (
  entry: Record<string, unknown>,
): {
  knowledgeBase: Record<string, unknown>;
  articles: Record<string, unknown>[];
} => ({
  knowledgeBase: (entry.knowledgeBase ?? {}) as Record<string, unknown>,
  articles: (entry.articles ?? []) as Record<string, unknown>[],
});

/**
 * `DefaultFlows` is a Smithy structure whose members all carry `@jsonName`, so
 * its wire keys ("ACXD.Welcome") differ from the generated client's member
 * names ("welcome"). A bundle holds the wire form, because a server writes it,
 * and the client serialises only members it recognises — so handing it the wire
 * form drops every entry silently and the application is rejected for having
 * no default welcome flow.
 *
 * Every other field in a bundle has the same wire and client form. This is the
 * only place the two diverge, which is why nothing else needed converting.
 */
const DEFAULT_FLOW_MEMBERS: Record<string, string> = {
  "ACXD.Welcome": "welcome",
  "ACXD.Fallback": "fallback",
  "ACXD.Unknown": "unknown",
  "ACXD.Escalation": "escalation",
  "ACXD.Frustration": "frustration",
  "ACXD.Help": "help",
  "ACXD.Repeat": "repeat",
  "ACXD.Resume": "resume",
};

/**
 * Rewrites a carried application into what the generated client accepts. Only
 * `settings.defaultFlows` needs it; an unrecognised key is passed through
 * rather than dropped, so a default flow added to the service before this SDK
 * knows about it still reaches the create call.
 */
export const toClientApplication = (
  application: Record<string, unknown>,
): Record<string, unknown> => {
  const settings = application.settings as Record<string, unknown> | undefined;
  const defaultFlows = settings?.defaultFlows as
    | Record<string, unknown>
    | undefined;
  if (!settings || !defaultFlows) return application;

  return {
    ...application,
    settings: {
      ...settings,
      defaultFlows: Object.fromEntries(
        Object.entries(defaultFlows).map(([key, value]) => [
          DEFAULT_FLOW_MEMBERS[key] ?? key,
          value,
        ]),
      ),
    },
  };
};

