'use strict';

/**
 * AutoCare Voice Assistant - one-command setup.
 *
 * Stands up a complete, working ACXD "agentic voice" application from scratch,
 * in dependency order:
 *
 *   1. Knowledge base + Q&A articles   (the answers the agent draws from)
 *   2. Flow wired to that KB           (start -> generative_journey -> terminate)
 *   3. Application with the flow        (attached + set as the welcome flow)
 *
 * Every step is idempotent (create-or-update), so re-running converges to the
 * desired state instead of creating duplicates.
 *
 * Prerequisites: an ACXD workspace and an API key (set ACXD_API_KEY,
 * ACXD_WORKSPACE_ID, ACXD_REGION in .env). This script only provisions ACXD
 * resources - a Connect instance and phone number are set up separately.
 *
 * Run with:  npm run autocare:create
 */

const { makeClient } = require('../lib/client');
const { ensureKnowledgeBaseStep } = require('./kb');
const { ensureFlowStep } = require('./flow');
const { ensureApplicationStep } = require('./application');

(async () => {
  const client = makeClient();
  try {
    console.log('Creating the AutoCare voice assistant application ...\n');

    const { knowledgeBaseId } = await ensureKnowledgeBaseStep(client);
    console.log('');

    await ensureFlowStep(client, { knowledgeBaseId });
    console.log('');

    const { applicationId } = await ensureApplicationStep(client);

    console.log('\nCreate complete.');
    console.log(`  application: autocare-assistant (${applicationId})`);
    console.log('  Next: run "npm run autocare:build-deploy" to make it runnable.');
  } catch (e) {
    console.error('\nCreate failed:', e.name, '-', e.message);
    if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
    process.exitCode = 1;
  }
})();
