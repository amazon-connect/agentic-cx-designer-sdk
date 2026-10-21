import { describe, expect, it } from "vitest";
import {
  ASSIGNED_IDS,
  BUNDLE_FORMAT_VERSION,
  FROM_THE_WIRE,
  IMPORT_ORDER,
  ON_THE_WIRE,
  assertReadable,
  splitKnowledgeBaseEntry,
  type BundleResourceType,
} from "../overlay/bundle-format";

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

describe("assertReadable", () => {
  it.each([1, 2])("accepts format version %i", (formatVersion) => {
    expect(() => assertReadable({ formatVersion })).not.toThrow();
  });

  it("refuses a version it does not know rather than misreading it", () => {
    expect(() => assertReadable({ formatVersion: 99 })).toThrow(
      /formatVersion 99/,
    );
  });

  it("accepts the version this SDK writes", () => {
    expect(() =>
      assertReadable({ formatVersion: BUNDLE_FORMAT_VERSION }),
    ).not.toThrow();
  });
});

describe("splitKnowledgeBaseEntry", () => {
  // The export writes a knowledge base nested, since its articles are created
  // separately. Reading it with a rest spread yields `{ knowledgeBase: {...} }`
  // and the create call then fails on required fields it cannot see — which is
  // how a real import first broke, with an opaque "type is required".
  it("returns the inner knowledge base, not the wrapper", () => {
    const kb = { knowledgeBaseId: "kb-1", name: "FAQ", type: "articles" };
    const { knowledgeBase, articles } = splitKnowledgeBaseEntry({
      knowledgeBase: kb,
      articles: [{ articleId: "a-1" }],
    });

    expect(knowledgeBase).toEqual(kb);
    expect(knowledgeBase).not.toHaveProperty("knowledgeBase");
    expect(articles).toEqual([{ articleId: "a-1" }]);
  });

  it("treats a knowledge base with no articles as an empty list", () => {
    expect(splitKnowledgeBaseEntry({ knowledgeBase: { knowledgeBaseId: "kb-1" } }).articles).toEqual([]);
  });

  it("does not throw on an entry missing the knowledge base", () => {
    expect(splitKnowledgeBaseEntry({})).toEqual({ knowledgeBase: {}, articles: [] });
  });
});
