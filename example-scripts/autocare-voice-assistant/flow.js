'use strict';

/**
 * AutoCare Voice Assistant — flow step.
 *
 * Creates or updates the "AutoCareAssistant" flow (start ->
 * generative_journey -> terminate) with the generative node wired to the
 * given knowledge base.
 *
 * Exports `ensureFlowStep(client, { knowledgeBaseId })` for the orchestrator,
 * and runs standalone via:  npm run autocare:flow  (ensures the KB first).
 */

const { makeClient } = require('../lib/client');
const { ensureKnowledgeBase, ensureFlow } = require('../lib/ensure');
const { KNOWLEDGE_BASE } = require('./kb-content');
const { buildNodes } = require('./flow-template');

const FLOW_ID = 'AutoCareAssistant';

/** Ensure the flow, wired to knowledgeBaseId. Returns { flowId }. */
async function ensureFlowStep(client, { knowledgeBaseId }) {
  console.log(`Flow "${FLOW_ID}" (wired to knowledgeBaseId=${knowledgeBaseId}):`);
  const nodes = buildNodes({ knowledgeBaseId });
  const flow = await ensureFlow(client, {
    flowId: FLOW_ID,
    description: 'AutoCare voice assistant flow: greet, answer via KB, terminate.',
    nodes,
  });
  console.log(`  ${flow.action.toUpperCase()} — flowId=${flow.flowId}`);
  return { flowId: flow.flowId };
}

module.exports = { ensureFlowStep, FLOW_ID };

// Standalone runner — ensures the KB first so the flow has something to wire to.
if (require.main === module) {
  (async () => {
    const client = makeClient();
    try {
      const kb = await ensureKnowledgeBase(client, KNOWLEDGE_BASE);
      await ensureFlowStep(client, { knowledgeBaseId: kb.knowledgeBaseId });
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
