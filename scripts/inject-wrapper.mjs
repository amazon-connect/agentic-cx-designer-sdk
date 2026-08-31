// Injects the hand-written client wrapper (overlay/wrapper.ts) into the
// Smithy-generated TypeScript client after `smithy build`, then re-exports it
// from the generated barrel so it shadows the generated `AgenticCXDesignerClient`
// under the same name.
//
// Idempotent: safe to run repeatedly. Run from the repo root (where `overlay/`
// and the `build/` output live). Invoked by the GitHub build/publish workflows
// between "Generate TypeScript client" and "Install dependencies".
import { copyFileSync, readFileSync, appendFileSync, existsSync } from "node:fs";

const GEN = "build/smithy/typescript-client/typescript-codegen/src";
const REEXPORT = 'export { AgenticCXDesignerClient } from "./wrapper";';

const indexPath = `${GEN}/index.ts`;
if (!existsSync(indexPath)) {
  console.error(
    `[inject-wrapper] generated client not found at ${GEN} — run \`smithy build --config smithy-build.github.json\` first`,
  );
  process.exit(1);
}

// 1. Copy the wrapper next to the generated client so its relative import resolves.
copyFileSync("overlay/wrapper.ts", `${GEN}/wrapper.ts`);

// 2. Append the explicit re-export (NOT `export *`, which would collide with the
//    generated client's own export of the same name and drop it as ambiguous).
//    Explicit named re-export, placed after the generated `export *`, wins.
const index = readFileSync(indexPath, "utf8");
if (!index.includes(REEXPORT)) {
  appendFileSync(indexPath, `\n${REEXPORT}\n`);
}

console.log("[inject-wrapper] wrapper injected and re-exported");
