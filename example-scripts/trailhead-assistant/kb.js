'use strict';

/**
 * Trailhead Assistant - knowledge base step.
 *
 * Creates the Cedar Ridge FAQ knowledge base and reconciles its Q&A articles
 * (idempotent create-or-update). Attach the printed knowledgeBaseId to the
 * knowledge_base node in your flow.
 *
 * Exports `ensureKnowledgeBaseStep(client)` for the orchestrator, and runs
 * standalone via:  npm run trailhead:kb
 */

const { makeClient } = require('../lib/client');
const { createKnowledgeBase, createArticle } = require('../lib/ensure');
const { KNOWLEDGE_BASE, ARTICLES } = require('./kb-content');

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

if (require.main === module) {
  (async () => {
    try {
      const { knowledgeBaseId } = await ensureKnowledgeBaseStep(makeClient());
      console.log('\nDone.');
      console.log('\nAttach this knowledge base to the knowledge_base node in your flow:');
      console.log(`  knowledgeBaseId = ${knowledgeBaseId}`);
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
