'use strict';

/**
 * Shared client factory for all example blueprints.
 *
 * Reads configuration from the environment (optionally seeded from a local
 * .env file) and returns a configured AgenticCXDesignerClient plus every
 * command re-exported for convenience.
 */

const fs = require('fs');
const path = require('path');

// Minimal .env loader - avoids adding a dependency. Only sets vars that are
// not already present in process.env (real env always wins).
function loadDotEnv() {
  const envPath = path.resolve(__dirname, '..', '.env');
  if (!fs.existsSync(envPath)) return;
  for (const rawLine of fs.readFileSync(envPath, 'utf8').split('\n')) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    if (eq === -1) continue;
    const key = line.slice(0, eq).trim();
    const value = line.slice(eq + 1).trim();
    if (key && process.env[key] === undefined) process.env[key] = value;
  }
}

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `Missing required config: ${name}. Copy .env.example to .env and fill it in.`
    );
  }
  return value;
}

loadDotEnv();

const sdk = require('amazon-connect-acxd-sdk');

/** Build a client from ACXD_* environment configuration. */
function makeClient() {
  return new sdk.AgenticCXDesignerClient({
    region: requireEnv('ACXD_REGION'),
    apiKey: requireEnv('ACXD_API_KEY'),
    workspaceId: requireEnv('ACXD_WORKSPACE_ID'),
  });
}

module.exports = { makeClient, sdk };
