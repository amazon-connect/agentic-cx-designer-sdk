'use strict';

/**
 * AutoCare Voice Assistant - knowledge base step.
 *
 * Creates the AutoCare FAQ knowledge base and reconciles its Q&A articles
 * (idempotent create-or-update).
 *
 * Exports `ensureKnowledgeBaseStep(client)` for the orchestrator, and runs
 * standalone via:  npm run autocare:kb
 */

const { makeClient } = require('../lib/client');
const { createKnowledgeBase, createArticle } = require('../lib/ensure');
const { KNOWLEDGE_BASE, ARTICLES } = require('./kb-content');

/** Create the KB and all its articles. Returns { knowledgeBaseId }. */
async function ensureKnowledgeBaseStep(client) {
  console.log(`Knowledge base "${KNOWLEDGE_BASE.name}":`);
  const kb = await createKnowledgeBase(client, KNOWLEDGE_BASE);
  console.log(`  CREATED - knowledgeBaseId=${kb.knowledgeBaseId}`);

  console.log(`  creating ${ARTICLES.length} article(s) ...`);
  for (const qa of ARTICLES) {
    await createArticle(client, kb.knowledgeBaseId, qa);
    console.log(`    created - "${qa.question}"`);
  }
  return { knowledgeBaseId: kb.knowledgeBaseId };
}

module.exports = { ensureKnowledgeBaseStep };

// Standalone runner
if (require.main === module) {
  (async () => {
    try {
      await ensureKnowledgeBaseStep(makeClient());
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
