'use strict';

/**
 * Trailhead Assistant — one-command create.
 *
 * Stands up a complete Cedar Ridge visitor assistant from scratch, in order:
 *   1. Knowledge base + Q&A articles
 *   2. YesOrNo slot type (for the user_choice branch)
 *   3. Flow wired to the KB + slot (user_input -> knowledge_base ->
 *      generative_text -> user_choice -> escalate/end)
 *   4. Application with the flow attached
 *
 * Every step is idempotent (create-or-update).
 *
 * Run with:  npm run trailhead:create
 */

const { makeClient } = require('../lib/client');
const { ensureKnowledgeBaseStep } = require('./kb');
const { ensureSlotTypeStep } = require('./slot-type');
const { ensureFlowStep } = require('./flow');
const { ensureApplicationStep } = require('./application');

(async () => {
  const client = makeClient();
  try {
    console.log('Creating the Trailhead assistant application ...\n');

    const { knowledgeBaseId } = await ensureKnowledgeBaseStep(client);
    console.log('');

    const { yesValueId, noValueId } = await ensureSlotTypeStep(client);
    console.log('');

    await ensureFlowStep(client, { knowledgeBaseId, yesValueId, noValueId });
    console.log('');

    const { applicationId } = await ensureApplicationStep(client);

    console.log('\nCreate complete.');
    console.log(`  application: trailhead-assistant (${applicationId})`);
    console.log('  Next: run "npm run trailhead:build-deploy" to make it runnable.');
  } catch (e) {
    console.error('\nCreate failed:', e.name, '-', e.message);
    if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
    process.exitCode = 1;
  }
})();
