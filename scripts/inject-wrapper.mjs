// Injects the hand-written overlay (overlay/*.ts) into the Smithy-generated
// TypeScript client after `smithy build`, then re-exports it from the generated
// barrel so the wrapper shadows the generated `AgenticCXDesignerClient` under the
// same name.
//
// Idempotent: safe to run repeatedly. Run from the repo root (where `overlay/`
// and the `build/` output live). Invoked by the GitHub build/publish workflows
// between "Generate TypeScript client" and "Install dependencies".
import { copyFileSync, readFileSync, appendFileSync, existsSync } from "node:fs";

const GEN = "build/smithy/typescript-client/typescript-codegen/src";
const OVERLAY = ["wrapper.ts", "bundle-format.ts", "bundle.ts"];
const REEXPORTS = [
  'export { AgenticCXDesignerClient, remapIds } from "./wrapper";',
  'export { exportBundle, importBundle } from "./bundle";',
  'export type { ImportOutcome } from "./bundle";',
  'export { unsupportedReason, classifyGraph, BUNDLE_FORMAT_VERSION } from "./bundle-format";',
  'export type { ResourceBundle, BundleResourceType, CarriedResourceType, UnsupportedResource } from "./bundle-format";',
];

const indexPath = `${GEN}/index.ts`;
if (!existsSync(indexPath)) {
  console.error(
    `[inject-wrapper] generated client not found at ${GEN} — run \`smithy build --config smithy-build.github.json\` first`,
  );
  process.exit(1);
}

// 1. Copy the overlay next to the generated client so its relative imports resolve.
for (const file of OVERLAY) {
  copyFileSync(`overlay/${file}`, `${GEN}/${file}`);
}

// 2. Append the explicit re-export (NOT `export *`, which would collide with the
//    generated client's own export of the same name and drop it as ambiguous).
//    Explicit named re-export, placed after the generated `export *`, wins.
const index = readFileSync(indexPath, "utf8");
for (const reexport of REEXPORTS) {
  if (!index.includes(reexport)) {
    appendFileSync(indexPath, `\n${reexport}\n`);
  }
}

console.log(`[inject-wrapper] injected ${OVERLAY.join(", ")} and re-exported`);
