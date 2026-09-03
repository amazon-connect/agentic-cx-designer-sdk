'use strict';

/**
 * AutoCare Voice Assistant — application step.
 *
 * Creates or updates the application (idempotent) and attaches the starter
 * flow, setting it as the welcome (entry) flow. The flow must already exist.
 *
 * Exports `ensureApplicationStep(client)` for the orchestrator, and runs
 * standalone via:  npm run autocare:app
 */

const { makeClient } = require('../lib/client');
const { ensureApplication } = require('../lib/ensure');
const { FLOW_ID } = require('./flow');
const { ensureGuardrailStep } = require('./guardrail');

const APPLICATION = {
  name: 'autocare-assistant',
  description: 'AutoCare Auto Repair voice assistant, created via the ACXD example scripts.',
  flows: [{ flowId: FLOW_ID }],
  settings: {
    languageCode: 'en-US',
    defaultFlows: {
      welcome: { flowId: FLOW_ID },
    },
  },
};

/**
 * Ensure the application with the flow attached and the content-safety guardrail
 * applied. Returns { applicationId }.
 */
async function ensureApplicationStep(client) {
  // Ensure the guardrail first so we can attach it by id.
  const { guardrailId } = await ensureGuardrailStep(client);

  const desired = {
    ...APPLICATION,
    settings: { ...APPLICATION.settings, guardrails: [{ guardrailId }] },
  };

  console.log(`Application "${APPLICATION.name}":`);
  const result = await ensureApplication(client, desired);
  console.log(`  ${result.action.toUpperCase()} — applicationId=${result.applicationId}`);
  return { applicationId: result.applicationId };
}

module.exports = { ensureApplicationStep, APPLICATION };

// Standalone runner
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
