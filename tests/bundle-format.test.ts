import { describe, expect, it, vi } from "vitest";
import {
  ASSIGNED_IDS,
  BUNDLE_FORMAT_VERSION,
  FROM_THE_WIRE,
  IMPORT_ORDER,
  ON_THE_WIRE,
  assertReadable,
  classifyGraph,
  collectPages,
  emptyBundle,
  selectFromList,
  unsupportedReason,
  type BundleResourceType,
} from "../overlay/bundle-format";

const node = (type: string, id: string, name?: string) => ({ type, id, name });

describe("resource names on the wire", () => {
  // The format is written in the validator's names, not this SDK's, because that
  // is what Studio reads. Four of these differ, which is the whole hazard.
  it.each([
    ["applications", "bot"],
    ["flows", "intent"],
    ["slotTypes", "slot"],
    ["dataRequests", "variable"],
    ["contextVariables", "contextAttribute"],
    ["liveSyncScripts", "journey"],
    ["modalities", "model"],
    ["analyticsTags", "analyticsTag"],
    ["knowledgeBases", "knowledgeBase"],
    ["secrets", "secret"],
    ["guardrails", "guardrail"],
  ] as [BundleResourceType, string][])("%s is %s on the wire", (sdk, wire) => {
    expect(ON_THE_WIRE[sdk]).toBe(wire);
    expect(FROM_THE_WIRE[wire]).toBe(sdk);
  });

  it("round-trips every type", () => {
    for (const sdk of Object.keys(ON_THE_WIRE) as BundleResourceType[]) {
      expect(FROM_THE_WIRE[ON_THE_WIRE[sdk]]).toBe(sdk);
    }
  });
});

describe("import order", () => {
  // Knowledge bases and guardrails are assigned their ids on creation, and flows
  // and applications refer to them, so they have to be created first or the
  // references cannot be remapped.
  it.each(ASSIGNED_IDS)("creates %s before flows and applications", (type) => {
    expect(IMPORT_ORDER.indexOf(type)).toBeLessThan(
      IMPORT_ORDER.indexOf("flows"),
    );
    expect(IMPORT_ORDER.indexOf(type)).toBeLessThan(
      IMPORT_ORDER.indexOf("applications"),
    );
  });

  it("creates applications last, since they reference everything else", () => {
    expect(IMPORT_ORDER[IMPORT_ORDER.length - 1]).toBe("applications");
  });

  it("covers every carried type and no uncarried one", () => {
    // Secrets are never carried, so they must not be in the order.
    expect(IMPORT_ORDER).not.toContain("secrets");
    expect(new Set(IMPORT_ORDER).size).toBe(IMPORT_ORDER.length);
    expect(IMPORT_ORDER).toHaveLength(10);
  });
});

describe("classifyGraph", () => {
  const root = { type: "applications" as BundleResourceType, id: "app-1" };

  it("carries the root and its dependencies", () => {
    const { carried, unsupported } = classifyGraph(
      [node("bot", "app-1", "Store"), node("intent", "f1"), node("slot", "s1")],
      root,
    );

    expect(carried.get("applications")).toEqual([{ id: "app-1", name: "Store" }]);
    expect(carried.get("flows")).toEqual([{ id: "f1", name: undefined }]);
    expect(carried.get("slotTypes")).toEqual([{ id: "s1", name: undefined }]);
    expect(unsupported).toEqual([]);
  });

  // A second application in the graph is a handoff target, which is its own
  // export — carrying it would silently duplicate a whole application.
  it("treats a non-root application as unsupported", () => {
    const { carried, unsupported } = classifyGraph(
      [node("bot", "app-1"), node("bot", "app-2", "Other")],
      root,
    );

    expect(carried.get("applications")).toEqual([{ id: "app-1", name: undefined }]);
    expect(unsupported).toEqual([
      {
        type: "bot",
        id: "app-2",
        name: "Other",
        reason:
          "Handoff targets are separate applications; export each one on its own.",
      },
    ]);
  });

  it("carries a live sync script only when it is the root", () => {
    const asDependency = classifyGraph([node("journey", "j1")], root);
    expect(asDependency.carried.has("liveSyncScripts")).toBe(false);
    expect(asDependency.unsupported[0].reason).toContain(
      "exported on their own",
    );

    const asRoot = classifyGraph([node("journey", "j1")], {
      type: "liveSyncScripts",
      id: "j1",
    });
    expect(asRoot.carried.get("liveSyncScripts")).toEqual([
      { id: "j1", name: undefined },
    ]);
    expect(asRoot.unsupported).toEqual([]);
  });

  it("never carries a secret", () => {
    const { carried, unsupported } = classifyGraph(
      [node("secret", "sec-1")],
      root,
    );

    expect(carried.has("secrets")).toBe(false);
    expect(unsupported[0].reason).toContain("never returned by the API");
  });

  // The validator cannot resolve these, so they should not appear in a graph at
  // all — but if one ever does it must be reported, not dropped or crashed on.
  it.each(["lifecycleHook", "dashboard", "scenario", "connectKnowledgeBase"])(
    "reports %s as unsupported rather than dropping it",
    (wireType) => {
      const { carried, unsupported } = classifyGraph(
        [node(wireType, "x1")],
        root,
      );

      expect(carried.size).toBe(0);
      expect(unsupported).toHaveLength(1);
      expect(unsupported[0].type).toBe(wireType);
      expect(unsupported[0].reason).not.toBe("");
    },
  );

  it("falls back to the id when a node has no name", () => {
    const { unsupported } = classifyGraph([node("secret", "sec-1")], root);
    expect(unsupported[0].name).toBe("sec-1");
  });

  it("groups repeats of the same type", () => {
    const { carried } = classifyGraph(
      [node("intent", "f1"), node("intent", "f2")],
      root,
    );
    expect(carried.get("flows")).toHaveLength(2);
  });
});

describe("unsupportedReason", () => {
  it("has wording for every type the validator can name", () => {
    for (const wire of Object.values(ON_THE_WIRE)) {
      expect(unsupportedReason(wire)).not.toBe("");
    }
  });

  it("falls back for an unknown type", () => {
    expect(unsupportedReason("somethingNew")).toBe(
      "This resource type cannot be created through the SDK.",
    );
  });
});

describe("emptyBundle", () => {
  it("writes the root type on the wire, not in SDK names", () => {
    expect(emptyBundle({ type: "applications", id: "app-1" }).root).toEqual({
      type: "bot",
      id: "app-1",
    });
  });

  it("stamps the current format version and every collection", () => {
    const bundle = emptyBundle({ type: "flows", id: "f1" });
    expect(bundle.formatVersion).toBe(BUNDLE_FORMAT_VERSION);
    for (const key of IMPORT_ORDER) {
      expect(bundle[key]).toEqual([]);
    }
    expect(bundle.unsupported).toEqual([]);
  });
});

describe("assertReadable", () => {
  it.each([1, 2])("accepts format version %i", (formatVersion) => {
    expect(() => assertReadable({ formatVersion })).not.toThrow();
  });

  it("refuses a version it does not know rather than misreading it", () => {
    expect(() => assertReadable({ formatVersion: 99 })).toThrow(
      /formatVersion 99/,
    );
  });
});

describe("collectPages", () => {
  it("follows nextToken to the end", async () => {
    const page = vi
      .fn()
      .mockResolvedValueOnce({ items: [{ a: 1 }], nextToken: "t1" })
      .mockResolvedValueOnce({ items: [{ a: 2 }], nextToken: "t2" })
      .mockResolvedValueOnce({ items: [{ a: 3 }] });

    expect(await collectPages(page)).toEqual([{ a: 1 }, { a: 2 }, { a: 3 }]);
    expect(page).toHaveBeenNthCalledWith(2, "t1");
    expect(page).toHaveBeenNthCalledWith(3, "t2");
  });

  it("tolerates a response with no items", async () => {
    expect(await collectPages(vi.fn().mockResolvedValue({}))).toEqual([]);
  });
});

describe("selectFromList", () => {
  const page = () =>
    Promise.resolve({ items: [{ name: "a" }, { name: "b" }, { name: "c" }] });
  const byName = (item: unknown) => (item as { name?: string }).name;

  it("picks only what was asked for", async () => {
    expect(await selectFromList(["a", "c"], page, byName)).toEqual([
      { name: "a" },
      { name: "c" },
    ]);
  });

  // The two kinds with no Get operation are listed, so an empty want list must
  // not pay for a list call.
  it("does not list when nothing is wanted", async () => {
    const spy = vi.fn();
    expect(await selectFromList([], spy, byName)).toEqual([]);
    expect(spy).not.toHaveBeenCalled();
  });

  it("skips entries whose key is missing", async () => {
    const withGap = () => Promise.resolve({ items: [{}, { name: "a" }] });
    expect(await selectFromList(["a"], withGap, byName)).toEqual([
      { name: "a" },
    ]);
  });
});
