'use strict';

/**
 * Idempotent "ensure" helpers shared by all blueprints.
 *
 * The pattern, for every resource: look it up by its stable natural key
 * (here, the application name). If it does not exist, create it. If it does,
 * update it in place. Re-running a blueprint therefore converges to the
 * desired state instead of creating duplicates or erroring.
 */

const { sdk } = require('./client');

/**
 * Find an application in the workspace by name (paginating the list).
 * Returns the ApplicationSummary or undefined.
 */
async function findApplicationByName(client, name) {
  let nextToken;
  do {
    const res = await client.send(
      new sdk.ListApplicationsCommand(nextToken ? { nextToken } : {})
    );
    const match = (res.items ?? []).find((a) => a.name === name);
    if (match) return match;
    nextToken = res.nextToken;
  } while (nextToken);
  return undefined;
}

/**
 * Create-or-update an application by name.
 *
 * @param client  AgenticCXDesignerClient
 * @param desired { name, description?, flows?, settings? }
 * @returns { action: 'created' | 'updated', applicationId, response }
 */
async function ensureApplication(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('ensureApplication: desired.name is required');

  const existing = await findApplicationByName(client, name);

  if (!existing) {
    const response = await client.send(
      new sdk.CreateApplicationCommand({
        name: desired.name,
        ...(desired.description !== undefined && { description: desired.description }),
        ...(desired.flows !== undefined && { flows: desired.flows }),
        ...(desired.settings !== undefined && { settings: desired.settings }),
      })
    );
    return { action: 'created', applicationId: response.applicationId, response };
  }

  const response = await client.send(
    new sdk.UpdateApplicationCommand({
      applicationIdentifier: existing.applicationId,
      ...(desired.name !== undefined && { name: desired.name }),
      ...(desired.description !== undefined && { description: desired.description }),
      ...(desired.flows !== undefined && { flows: desired.flows }),
      ...(desired.settings !== undefined && { settings: desired.settings }),
    })
  );
  return { action: 'updated', applicationId: existing.applicationId, response };
}

/**
 * Find a knowledge base by name (paginating the list).
 * Returns the summary or undefined.
 */
async function findKnowledgeBaseByName(client, name) {
  let nextToken;
  do {
    const res = await client.send(
      new sdk.ListKnowledgeBasesCommand(nextToken ? { nextToken } : {})
    );
    const match = (res.items ?? []).find((k) => k.name === name);
    if (match) return match;
    nextToken = res.nextToken;
  } while (nextToken);
  return undefined;
}

/**
 * Create a knowledge base if one with the same name does not already exist.
 * KBs have no fields we need to reconcile here, so an existing KB is reused
 * as-is (its articles are reconciled separately by ensureArticle).
 *
 * @returns { action: 'created' | 'exists', knowledgeBaseId }
 */
async function ensureKnowledgeBase(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('ensureKnowledgeBase: desired.name is required');

  const existing = await findKnowledgeBaseByName(client, name);
  if (existing) {
    return { action: 'exists', knowledgeBaseId: existing.knowledgeBaseId };
  }

  const response = await client.send(
    new sdk.CreateKnowledgeBaseCommand({
      name: desired.name,
      type: desired.type ?? 'articles',
      ...(desired.description !== undefined && { description: desired.description }),
      ...(desired.mainLanguageCode !== undefined && { mainLanguageCode: desired.mainLanguageCode }),
    })
  );
  return { action: 'created', knowledgeBaseId: response.knowledgeBaseId };
}

/**
 * Create-or-update a single Q&A article, keyed on the question text.
 *
 * @param client
 * @param knowledgeBaseId
 * @param qa { question: string, answer: string }
 * @returns { action: 'created' | 'updated', articleId }
 */
async function ensureArticle(client, knowledgeBaseId, qa) {
  // Find an existing article with the same question text.
  let existing;
  let nextToken;
  do {
    const res = await client.send(
      new sdk.ListKnowledgeBaseArticlesCommand(
        nextToken ? { knowledgeBaseId, nextToken } : { knowledgeBaseId }
      )
    );
    existing = (res.items ?? []).find((a) => a.question?.text === qa.question);
    if (existing) break;
    nextToken = res.nextToken;
  } while (nextToken);

  const question = { text: qa.question };
  const responses = [{ type: 'text', body: qa.answer }];

  if (!existing) {
    const response = await client.send(
      new sdk.CreateKnowledgeBaseArticleCommand({ knowledgeBaseId, question, responses })
    );
    return { action: 'created', articleId: response.articleId };
  }

  await client.send(
    new sdk.UpdateKnowledgeBaseArticleCommand({
      knowledgeBaseId,
      articleId: existing.articleId,
      question,
      responses,
    })
  );
  return { action: 'updated', articleId: existing.articleId };
}

/**
 * Find a flow by its id/name (flowId is the customer-provided identifier).
 */
async function findFlowById(client, flowId) {
  let nextToken;
  do {
    const res = await client.send(
      new sdk.ListFlowsCommand(nextToken ? { nextToken } : {})
    );
    const match = (res.items ?? []).find((f) => f.flowId === flowId);
    if (match) return match;
    nextToken = res.nextToken;
  } while (nextToken);
  return undefined;
}

/**
 * Create-or-update a flow, keyed on flowId (the name).
 *
 * @param client
 * @param desired { flowId, nodes, description?, mainLanguageCode?, languageCodes?, utterances? }
 * @returns { action: 'created' | 'updated', flowId }
 */
async function ensureFlow(client, desired) {
  const { flowId, nodes } = desired;
  if (!flowId) throw new Error('ensureFlow: desired.flowId is required');
  if (!nodes) throw new Error('ensureFlow: desired.nodes is required');

  const description = desired.description ?? 'Agentic Voice starter flow.';
  const mainLanguageCode = desired.mainLanguageCode ?? 'en-US';
  const languageCodes = desired.languageCodes ?? [mainLanguageCode];
  const utterances = desired.utterances ?? [];
  const slotTypes = desired.slotTypes ?? [];

  const existing = await findFlowById(client, flowId);

  if (!existing) {
    await client.send(
      new sdk.CreateFlowCommand({
        flowId,
        utterances,
        description,
        untrained: true,
        mainLanguageCode,
        languageCodes,
        slotTypes,
        nodes,
      })
    );
    return { action: 'created', flowId };
  }

  await client.send(
    new sdk.UpdateFlowCommand({
      flowIdentifier: flowId,
      utterances,
      description,
      mainLanguageCode,
      languageCodes,
      slotTypes,
      nodes,
    })
  );
  return { action: 'updated', flowId };
}

/**
 * Create-or-update the deployment for an environment.
 *
 * An application/environment has a single deployment slot. The first deploy
 * creates it; subsequent deploys update that same slot to point at a new
 * build (redeploy in place) rather than creating another — which the backend
 * rejects with a limit error.
 *
 * @param client
 * @param opts { applicationId, buildId, environment, languageCodes }
 * @returns { action: 'created' | 'updated', deploymentId, deploymentStatus }
 */
async function ensureDeployment(client, { applicationId, buildId, environment, languageCodes }) {
  const list = await client.send(
    new sdk.ListApplicationDeploymentsCommand({ applicationIdentifier: applicationId }),
  );
  const existing = (list.items ?? []).find((d) => d.environment === environment);

  if (!existing) {
    const res = await client.send(
      new sdk.CreateApplicationDeploymentCommand({
        applicationIdentifier: applicationId,
        buildIdentifier: buildId,
        environment,
        description: 'Agentic Voice starter deployment (via example scripts).',
      }),
    );
    return { action: 'created', deploymentId: res.deploymentId, deploymentStatus: res.deploymentStatus };
  }

  const res = await client.send(
    new sdk.UpdateApplicationDeploymentCommand({
      applicationIdentifier: applicationId,
      deploymentIdentifier: existing.deploymentId,
      buildIdentifier: buildId,
      environment,
      languageCodes,
      description: 'Agentic Voice starter deployment (via example scripts).',
    }),
  );
  return { action: 'updated', deploymentId: existing.deploymentId, deploymentStatus: res.deploymentStatus };
}

/**
 * Create-or-update a slot type by id, with caller-provided value ids so the
 * ids are stable across workspaces (the flow's user_choice conditions can then
 * reference fixed value ids).
 *
 * @param client
 * @param desired { slotTypeId, values: [{ value, valueId }], description? }
 * @returns { action: 'created' | 'updated', slotTypeId }
 */
async function ensureSlotType(client, desired) {
  const { slotTypeId } = desired;
  if (!slotTypeId) throw new Error('ensureSlotType: desired.slotTypeId is required');

  let existing;
  let nextToken;
  do {
    const res = await client.send(new sdk.ListSlotTypesCommand(nextToken ? { nextToken } : {}));
    existing = (res.items ?? []).find((s) => s.slotTypeId === slotTypeId);
    if (existing) break;
    nextToken = res.nextToken;
  } while (nextToken);

  if (!existing) {
    await client.send(
      new sdk.CreateSlotTypeCommand({
        slotTypeId,
        values: desired.values,
        ...(desired.description !== undefined && { description: desired.description }),
      }),
    );
    return { action: 'created', slotTypeId };
  }

  await client.send(
    new sdk.UpdateSlotTypeCommand({
      slotTypeIdentifier: slotTypeId,
      values: desired.values,
      ...(desired.description !== undefined && { description: desired.description }),
    }),
  );
  return { action: 'updated', slotTypeId };
}

/**
 * Create-or-update a data request (webhook) by id.
 *
 * @param client
 * @param desired { dataRequestId, type, webhook, description? }
 * @returns { action: 'created' | 'updated', dataRequestId }
 */
async function ensureDataRequest(client, desired) {
  const { dataRequestId } = desired;
  if (!dataRequestId) throw new Error('ensureDataRequest: desired.dataRequestId is required');

  let existing;
  let nextToken;
  do {
    const res = await client.send(new sdk.ListDataRequestsCommand(nextToken ? { nextToken } : {}));
    existing = (res.items ?? []).find((d) => d.dataRequestId === dataRequestId);
    if (existing) break;
    nextToken = res.nextToken;
  } while (nextToken);

  if (!existing) {
    await client.send(
      new sdk.CreateDataRequestCommand({
        dataRequestId,
        type: desired.type,
        webhook: desired.webhook,
        ...(desired.description !== undefined && { description: desired.description }),
      }),
    );
    return { action: 'created', dataRequestId };
  }

  await client.send(
    new sdk.UpdateDataRequestCommand({
      dataRequestIdentifier: dataRequestId,
      type: desired.type,
      webhook: desired.webhook,
      ...(desired.description !== undefined && { description: desired.description }),
    }),
  );
  return { action: 'updated', dataRequestId };
}

/**
 * Create-or-update a guardrail by name.
 *
 * @param client
 * @param desired { name, trigger, rules, description?, active? }
 * @returns { action: 'created' | 'updated', guardrailId }
 */
async function ensureGuardrail(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('ensureGuardrail: desired.name is required');

  let existing;
  let nextToken;
  do {
    const res = await client.send(new sdk.ListGuardrailsCommand(nextToken ? { nextToken } : {}));
    existing = (res.items ?? []).find((g) => g.name === name);
    if (existing) break;
    nextToken = res.nextToken;
  } while (nextToken);

  const body = {
    name: desired.name,
    trigger: desired.trigger,
    rules: desired.rules,
    ...(desired.description !== undefined && { description: desired.description }),
    ...(desired.active !== undefined && { active: desired.active }),
  };

  if (!existing) {
    const res = await client.send(new sdk.CreateGuardrailCommand(body));
    return { action: 'created', guardrailId: res.guardrailId };
  }

  await client.send(
    new sdk.UpdateGuardrailCommand({ guardrailIdentifier: existing.guardrailId, ...body }),
  );
  return { action: 'updated', guardrailId: existing.guardrailId };
}

module.exports = { findApplicationByName, ensureApplication, ensureKnowledgeBase, ensureArticle, findFlowById, ensureFlow, ensureDeployment, ensureSlotType, ensureDataRequest, ensureGuardrail };


