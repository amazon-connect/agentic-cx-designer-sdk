'use strict';

/**
 * OrderLookup — application step.
 *
 * Creates or updates the application with the flow attached as the welcome flow.
 *
 * Exports `ensureApplicationStep(client)`, and runs standalone via:
 *   npm run order:app
 */

const { makeClient } = require('../lib/client');
const { ensureApplication } = require('../lib/ensure');
const { FLOW_ID } = require('./flow');

const APPLICATION = {
  name: 'order-lookup',
  description: 'Order lookup assistant (calls an external API), created via the ACXD example scripts.',
  flows: [{ flowId: FLOW_ID }],
  settings: {
    languageCode: 'en-US',
    defaultFlows: { welcome: { flowId: FLOW_ID } },
  },
};

async function ensureApplicationStep(client) {
  console.log(`Application "${APPLICATION.name}":`);
  const result = await ensureApplication(client, APPLICATION);
  console.log(`  ${result.action.toUpperCase()} — applicationId=${result.applicationId}`);
  return { applicationId: result.applicationId };
}

module.exports = { ensureApplicationStep, APPLICATION };

if (require.main === module) {
  (async () => {
    try {
      await ensureApplicationStep(makeClient());
      console.log('\nDone.');
    } catch (e) {
      console.error('ERROR', e.name, '-', e.message);
      if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
      process.exitCode = 1;
    }
  })();
}
