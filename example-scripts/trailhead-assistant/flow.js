'use strict';

/**
 * Trailhead Assistant - flow step.
 *
 * Creates or updates the "TrailheadAssistant" flow, wired to the Cedar Ridge
 * knowledge base and the YesOrNo slot type value ids.
 *
 * Exports `ensureFlowStep(client, { knowledgeBaseId, yesValueId, noValueId })`,
 * and runs standalone via:  npm run trailhead:flow  (ensures KB + slot first).
 */

const { makeClient } = require('../lib/client');
const { createKnowledgeBase, createFlow } = require('../lib/ensure');
const { KNOWLEDGE_BASE } = require('./kb-content');
const { ensureSlotTypeStep } = require('./slot-type');
const { buildNodes } = require('./flow-template');

const FLOW_ID = 'TrailheadAssistant';

async function ensureFlowStep(client, { knowledgeBaseId, yesValueId, noValueId }) {
  console.log(`Flow "${FLOW_ID}":`);
  const nodes = buildNodes({ knowledgeBaseId, yesValueId, noValueId });
  const flow = await createFlow(client, {
    flowId: FLOW_ID,
    description: 'Trailhead assistant flow: ask, KB lookup, generative reply, escalate on no.',
    nodes,
    slotTypes: [{ name: 'YesNo', type: 'YesOrNo' }],
  });
  console.log(`  CREATED - flowId=${flow.flowId}`);
  return { flowId: flow.flowId };
}

module.exports = { ensureFlowStep, FLOW_ID };

if (require.main === module) {
  (async () => {
    const client = makeClient();
    try {
      const kb = await createKnowledgeBase(client, KNOWLEDGE_BASE);
      const { yesValueId, noValueId } = await ensureSlotTypeStep(client);
      await ensureFlowStep(client, { knowledgeBaseId: kb.knowledgeBaseId, yesValueId, noValueId });
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
