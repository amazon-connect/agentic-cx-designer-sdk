'use strict';

/**
 * Resource creation helpers shared by all blueprints.
 *
 * Each blueprint provisions a fresh set of resources. These helpers create a
 * resource and fail with a clear "already exists" error if a resource with the
 * same natural key (name / id) is already present - so a re-run does not
 * silently modify or clobber existing resources. To start over, delete the
 * existing resources (or the application) and run again.
 *
 * Deployment is the one exception: an application/environment has a single
 * deployment slot, so `deployApplication` creates it the first time and updates
 * that same slot on subsequent deploys.
 */

const { sdk } = require('./client');

/** Error thrown when a resource already exists. */
class AlreadyExistsError extends Error {
  constructor(kind, key) {
    super(`${kind} "${key}" already exists. Delete it (or the application) and run again to recreate.`);
    this.name = 'AlreadyExistsError';
  }
}

/**
 * Find an application in the workspace by name (paginating the list).
 * Returns the ApplicationSummary or undefined.
 */
async function findApplicationByName(client, name) {
  let nextToken;
  do {
    const res = await client.send(new sdk.ListApplicationsCommand(nextToken ? { nextToken } : {}));
    const match = (res.items ?? []).find((a) => a.name === name);
    if (match) return match;
    nextToken = res.nextToken;
  } while (nextToken);
  return undefined;
}

/**
 * Create an application. Fails if one with the same name already exists.
 * @param desired { name, description?, flows?, settings? }
 * @returns { applicationId }
 */
async function createApplication(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('createApplication: desired.name is required');
  if (await findApplicationByName(client, name)) throw new AlreadyExistsError('Application', name);

  const response = await client.send(
    new sdk.CreateApplicationCommand({
      name: desired.name,
      ...(desired.description !== undefined && { description: desired.description }),
      ...(desired.flows !== undefined && { flows: desired.flows }),
      ...(desired.settings !== undefined && { settings: desired.settings }),
    }),
  );
  return { applicationId: response.applicationId };
}

/**
 * Create a knowledge base. Fails if one with the same name already exists.
 * @param desired { name, type?, description?, mainLanguageCode? }
 * @returns { knowledgeBaseId }
 */
async function createKnowledgeBase(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('createKnowledgeBase: desired.name is required');

  let nextToken;
  do {
    const res = await client.send(new sdk.ListKnowledgeBasesCommand(nextToken ? { nextToken } : {}));
    if ((res.items ?? []).some((k) => k.name === name)) throw new AlreadyExistsError('Knowledge base', name);
    nextToken = res.nextToken;
  } while (nextToken);

  const response = await client.send(
    new sdk.CreateKnowledgeBaseCommand({
      name: desired.name,
      type: desired.type ?? 'articles',
      ...(desired.description !== undefined && { description: desired.description }),
      ...(desired.mainLanguageCode !== undefined && { mainLanguageCode: desired.mainLanguageCode }),
    }),
  );
  return { knowledgeBaseId: response.knowledgeBaseId };
}

/**
 * Create a single Q&A article in a knowledge base.
 * @param qa { question: string, answer: string }
 * @returns { articleId }
 */
async function createArticle(client, knowledgeBaseId, qa) {
  const question = { text: qa.question };
  const responses = [{ type: 'text', body: qa.answer }];
  const response = await client.send(
    new sdk.CreateKnowledgeBaseArticleCommand({ knowledgeBaseId, question, responses }),
  );
  return { articleId: response.articleId };
}

/**
 * Find a flow by its id/name (flowId is the customer-provided identifier).
 */
async function findFlowById(client, flowId) {
  let nextToken;
  do {
    const res = await client.send(new sdk.ListFlowsCommand(nextToken ? { nextToken } : {}));
    const match = (res.items ?? []).find((f) => f.flowId === flowId);
    if (match) return match;
    nextToken = res.nextToken;
  } while (nextToken);
  return undefined;
}

/**
 * Create a flow. Fails if one with the same flowId (name) already exists.
 * @param desired { flowId, nodes, description?, mainLanguageCode?, languageCodes?, utterances?, slotTypes? }
 * @returns { flowId }
 */
async function createFlow(client, desired) {
  const { flowId, nodes } = desired;
  if (!flowId) throw new Error('createFlow: desired.flowId is required');
  if (!nodes) throw new Error('createFlow: desired.nodes is required');
  if (await findFlowById(client, flowId)) throw new AlreadyExistsError('Flow', flowId);

  const mainLanguageCode = desired.mainLanguageCode ?? 'en-US';
  await client.send(
    new sdk.CreateFlowCommand({
      flowId,
      utterances: desired.utterances ?? [],
      description: desired.description ?? 'Example flow.',
      untrained: true,
      mainLanguageCode,
      languageCodes: desired.languageCodes ?? [mainLanguageCode],
      slotTypes: desired.slotTypes ?? [],
      nodes,
    }),
  );
  return { flowId };
}

/**
 * Create a slot type. Fails if one with the same id already exists.
 * @param desired { slotTypeId, values: [{ value, valueId }], description? }
 * @returns { slotTypeId }
 */
async function createSlotType(client, desired) {
  const { slotTypeId } = desired;
  if (!slotTypeId) throw new Error('createSlotType: desired.slotTypeId is required');

  let nextToken;
  do {
    const res = await client.send(new sdk.ListSlotTypesCommand(nextToken ? { nextToken } : {}));
    if ((res.items ?? []).some((s) => s.slotTypeId === slotTypeId)) throw new AlreadyExistsError('Slot type', slotTypeId);
    nextToken = res.nextToken;
  } while (nextToken);

  await client.send(
    new sdk.CreateSlotTypeCommand({
      slotTypeId,
      values: desired.values,
      ...(desired.description !== undefined && { description: desired.description }),
    }),
  );
  return { slotTypeId };
}

/**
 * Create a data request (webhook). Fails if one with the same id already exists.
 * @param desired { dataRequestId, type, webhook, description? }
 * @returns { dataRequestId }
 */
async function createDataRequest(client, desired) {
  const { dataRequestId } = desired;
  if (!dataRequestId) throw new Error('createDataRequest: desired.dataRequestId is required');

  let nextToken;
  do {
    const res = await client.send(new sdk.ListDataRequestsCommand(nextToken ? { nextToken } : {}));
    if ((res.items ?? []).some((d) => d.dataRequestId === dataRequestId)) throw new AlreadyExistsError('Data request', dataRequestId);
    nextToken = res.nextToken;
  } while (nextToken);

  await client.send(
    new sdk.CreateDataRequestCommand({
      dataRequestId,
      type: desired.type,
      webhook: desired.webhook,
      ...(desired.description !== undefined && { description: desired.description }),
    }),
  );
  return { dataRequestId };
}

/**
 * Create a guardrail. Fails if one with the same name already exists.
 * @param desired { name, trigger, rules, description?, active? }
 * @returns { guardrailId }
 */
async function createGuardrail(client, desired) {
  const { name } = desired;
  if (!name) throw new Error('createGuardrail: desired.name is required');

  let nextToken;
  do {
    const res = await client.send(new sdk.ListGuardrailsCommand(nextToken ? { nextToken } : {}));
    if ((res.items ?? []).some((g) => g.name === name)) throw new AlreadyExistsError('Guardrail', name);
    nextToken = res.nextToken;
  } while (nextToken);

  const res = await client.send(
    new sdk.CreateGuardrailCommand({
      name: desired.name,
      trigger: desired.trigger,
      rules: desired.rules,
      ...(desired.description !== undefined && { description: desired.description }),
      ...(desired.active !== undefined && { active: desired.active }),
    }),
  );
  return { guardrailId: res.guardrailId };
}

/**
 * Deploy an application build. An application/environment has a single
 * deployment slot: this creates it the first time and updates that same slot on
 * subsequent deploys (redeploy in place). This is intentionally not create-only,
 * since re-deploying newer builds to the existing slot is the normal workflow.
 *
 * @param opts { applicationId, buildId, environment, languageCodes }
 * @returns { action: 'created' | 'updated', deploymentId, deploymentStatus }
 */
async function deployApplication(client, { applicationId, buildId, environment, languageCodes }) {
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
        description: 'Example application deployment (via example scripts).',
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
      description: 'Example application deployment (via example scripts).',
    }),
  );
  return { action: 'updated', deploymentId: existing.deploymentId, deploymentStatus: res.deploymentStatus };
}

module.exports = {
  AlreadyExistsError,
  findApplicationByName,
  createApplication,
  createKnowledgeBase,
  createArticle,
  findFlowById,
  createFlow,
  createSlotType,
  createDataRequest,
  createGuardrail,
  deployApplication,
};
