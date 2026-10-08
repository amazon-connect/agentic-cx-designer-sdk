// The bundle format, with no dependency on the generated client.
//
// Split out from bundle.ts so it can be tested on its own: bundle.ts imports the
// generated commands, which only exist after `smithy build`, and so cannot be
// compiled or run from `overlay/`.
//
// The format is the one Agentic CX Designer Studio reads and writes, so a bundle
// exported here imports there and vice versa.

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

/**
 * Why a resource in the dependency graph is named but not carried. Matches the
 * wording Studio uses, so a bundle reads the same whichever side wrote it.
 */
export const unsupportedReason = (wireType: string): string =>
  ({
    secret:
      "A secret's value is never returned by the API, so only you can recreate it.",
    bot: "Handoff targets are separate applications; export each one on its own.",
    journey:
      "Live sync scripts are exported on their own, from the live sync script itself.",
    connectKnowledgeBase:
      "This lives in your Connect instance, not in the workspace.",
    dashboard:
      "Dashboards are not part of an application and have no SDK operation.",
    lifecycleHook: "Lifecycle hooks have no SDK operation yet.",
    scenario: "Simulation scenarios have no SDK operation yet.",
  })[wireType] ?? "This resource type cannot be created through the SDK.";

/**
 * Applications and live sync scripts are only carried when they are the root.
 * Reached from somewhere else they are a handoff target or a separate script,
 * which is its own export.
 */
export const carriedOnlyAsRoot = (type: BundleResourceType): boolean =>
  type === "applications" || type === "liveSyncScripts";

/** Secrets can never be carried: the API does not return their value. */
export const neverCarried = (type: BundleResourceType): boolean =>
  type === "secrets";

export const emptyBundle = (root: {
  type: BundleResourceType;
  id: string;
}): ResourceBundle => ({
  formatVersion: BUNDLE_FORMAT_VERSION,
  root: { type: ON_THE_WIRE[root.type], id: root.id },
  applications: [],
  flows: [],
  liveSyncScripts: [],
  slotTypes: [],
  dataRequests: [],
  modalities: [],
  contextVariables: [],
  analyticsTags: [],
  guardrails: [],
  knowledgeBases: [],
  unsupported: [],
});

export const assertReadable = (bundle: { formatVersion: number }): void => {
  if (!READABLE_FORMAT_VERSIONS.includes(bundle.formatVersion)) {
    throw new Error(
      `Unreadable bundle: formatVersion ${bundle.formatVersion}, expected one of ${READABLE_FORMAT_VERSIONS.join(", ")}. Export it again from a current version.`,
    );
  }
};

/** Which graph nodes go into which collection, and which become `unsupported`. */
export const classifyGraph = (
  nodes: { type: string; id: string; name?: string }[],
  root: { type: BundleResourceType; id: string },
): {
  carried: Map<BundleResourceType, { id: string; name?: string }[]>;
  unsupported: UnsupportedResource[];
} => {
  const carried = new Map<BundleResourceType, { id: string; name?: string }[]>();
  const unsupported: UnsupportedResource[] = [];

  for (const node of nodes) {
    const sdkType = FROM_THE_WIRE[node.type];
    const isRoot = sdkType === root.type && node.id === root.id;

    if (
      sdkType === undefined ||
      neverCarried(sdkType) ||
      (carriedOnlyAsRoot(sdkType) && !isRoot)
    ) {
      unsupported.push({
        type: node.type,
        id: node.id,
        name: node.name ?? node.id,
        reason: unsupportedReason(node.type),
      });
      continue;
    }

    const existing = carried.get(sdkType) ?? [];
    existing.push({ id: node.id, name: node.name });
    carried.set(sdkType, existing);
  }

  return { carried, unsupported };
};

type Page = { items?: unknown[]; nextToken?: string };

/** Reads every page of a paginated list operation. */
export const collectPages = async (
  page: (nextToken?: string) => Promise<Page>,
): Promise<Record<string, unknown>[]> => {
  const all: Record<string, unknown>[] = [];
  let nextToken: string | undefined;
  do {
    const response = await page(nextToken);
    all.push(...((response.items ?? []) as Record<string, unknown>[]));
    nextToken = response.nextToken;
  } while (nextToken);
  return all;
};

/**
 * Picks wanted entries out of a list operation, for the two resource kinds with
 * no Get operation to fetch them by id.
 */
export const selectFromList = async (
  wanted: string[],
  page: (nextToken?: string) => Promise<Page>,
  keyOf: (item: unknown) => string | undefined,
): Promise<Record<string, unknown>[]> => {
  if (wanted.length === 0) return [];
  const all = await collectPages(page);
  const keys = new Set(wanted);
  return all.filter((item) => {
    const key = keyOf(item);
    return key !== undefined && keys.has(key);
  });
};
