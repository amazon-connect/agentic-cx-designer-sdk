'use strict';

/**
 * AutoCare Voice Assistant — build + deploy step.
 *
 * Follow-up to `npm run autocare:create`. Builds the application, waits for the
 * build to finish, then deploys it so it becomes runnable:
 *
 *   1. CreateApplicationBuild       -> starts an async build (status PENDING)
 *   2. poll GetApplicationBuild     -> until status is BUILT (or failed)
 *   3. CreateApplicationDeployment  -> deploys the built build to an environment
 *
 * Run with:  npm run autocare:build-deploy
 */

const { makeClient, sdk } = require('../lib/client');
const { findApplicationByName, ensureDeployment } = require('../lib/ensure');
const { APPLICATION } = require('./application');

const DEPLOY_ENVIRONMENT = 'development';
const DEPLOY_LANGUAGE_CODES = ['en-US'];

// Build status values. A build starts PENDING and ends at BUILT on success.
const BUILD_SUCCESS = 'BUILT';
const BUILD_PENDING = new Set(['PENDING', 'IN_PROGRESS', 'BUILDING']);

const POLL_INTERVAL_MS = 5000;
const POLL_TIMEOUT_MS = 5 * 60 * 1000;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** Poll GetApplicationBuild until the build reaches a terminal status. */
async function waitForBuild(client, applicationId, buildId) {
  const deadline = Date.now() + POLL_TIMEOUT_MS;
  for (;;) {
    const build = await client.send(
      new sdk.GetApplicationBuildCommand({
        applicationIdentifier: applicationId,
        buildIdentifier: buildId,
      }),
    );
    if (build.status === BUILD_SUCCESS) return build.status;
    if (!BUILD_PENDING.has(build.status)) {
      throw new Error(`Build ${buildId} ended with status "${build.status}".`);
    }
    if (Date.now() > deadline) {
      throw new Error(`Build ${buildId} did not finish within the timeout (last status "${build.status}").`);
    }
    await sleep(POLL_INTERVAL_MS);
  }
}

(async () => {
  const client = makeClient();
  try {
    const app = await findApplicationByName(client, APPLICATION.name);
    if (!app) {
      throw new Error(`Application "${APPLICATION.name}" not found. Run "npm run autocare:create" first.`);
    }
    console.log(`Application "${APPLICATION.name}" (${app.applicationId})`);

    // 1. Build.
    console.log('Creating build ...');
    const build = await client.send(
      new sdk.CreateApplicationBuildCommand({
        applicationIdentifier: app.applicationId,
        description: 'AutoCare voice assistant build (via example scripts).',
      }),
    );
    console.log(`  build ${build.buildId} — status ${build.status}`);

    // 2. Wait for the build to finish.
    console.log('  waiting for build to finish ...');
    await waitForBuild(client, app.applicationId, build.buildId);
    console.log(`  build ${build.buildId} — status ${BUILD_SUCCESS}`);

    // 3. Deploy (create the deployment, or update the existing one in place).
    console.log(`Deploying build to "${DEPLOY_ENVIRONMENT}" ...`);
    const deployment = await ensureDeployment(client, {
      applicationId: app.applicationId,
      buildId: build.buildId,
      environment: DEPLOY_ENVIRONMENT,
      languageCodes: DEPLOY_LANGUAGE_CODES,
    });
    console.log(
      `  ${deployment.action.toUpperCase()} — deployment ${deployment.deploymentId} — status ${deployment.deploymentStatus}`,
    );

    console.log('\nBuild + deploy complete.');
  } catch (e) {
    console.error('\nBuild/deploy failed:', e.name, '-', e.message);
    if (e.$metadata) console.error('HTTP', e.$metadata.httpStatusCode);
    process.exitCode = 1;
  }
})();
