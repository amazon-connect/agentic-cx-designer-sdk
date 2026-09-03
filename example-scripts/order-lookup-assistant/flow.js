'use strict';

/**
 * OrderLookup - flow step.
 *
 * Creates or updates the "OrderLookup" flow, wired to the OrderLookup data
 * request.
 *
 * Exports `ensureFlowStep(client, { dataRequestId })`, and runs standalone via:
 *   npm run order:flow  (ensures the data request first).
 */

const { makeClient } = require('../lib/client');
const { createFlow } = require('../lib/ensure');
const { ensureDataRequestStep } = require('./data-request');
const { buildNodes } = require('./flow-template');

const FLOW_ID = 'OrderLookup';

async function ensureFlowStep(client, { dataRequestId }) {
  console.log(`Flow "${FLOW_ID}":`);
  const nodes = buildNodes({ dataRequestId });
  const flow = await createFlow(client, {
    flowId: FLOW_ID,
    description: 'Order lookup flow: ask for an order number, fetch it from an external API, summarize.',
    nodes,
  });
  console.log(`  CREATED - flowId=${flow.flowId}`);
  return { flowId: flow.flowId };
}

module.exports = { ensureFlowStep, FLOW_ID };

if (require.main === module) {
  (async () => {
    const client = makeClient();
    try {
      const { dataRequestId } = await ensureDataRequestStep(client);
      await ensureFlowStep(client, { dataRequestId });
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
