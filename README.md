# Agentic CX Designer SDK

TypeScript SDK client for Amazon Connect Agentic CX Designer — provides programmatic access to workspace resources including applications, flows, knowledge bases, guardrails, and more.

## Installation

```bash
npm install @amazon-connect/agentic-cx-designer-sdk
```

## Usage

```javascript
const { AgenticCXDesignerClient, ListApplicationsCommand } = require('@amazon-connect/agentic-cx-designer-sdk');

const client = new AgenticCXDesignerClient({
  region: 'us-west-2',
});

// Add authentication
client.middlewareStack.add(
  (next) => async (args) => {
    args.request.headers['x-api-key'] = 'your-api-key';
    args.request.headers['x-workspace-id'] = 'your-workspace-id';
    return next(args);
  },
  { step: 'build', name: 'addAuthHeaders' }
);

const response = await client.send(new ListApplicationsCommand({}));
console.log(response.items);
```

## Architecture

This repository contains the [Smithy](https://smithy.io) model that defines the Agentic CX Designer API. The TypeScript SDK client is generated from this model using [smithy-typescript-codegen](https://github.com/smithy-lang/smithy-typescript) and published to npm.

```
model/               <- Smithy model files (API source of truth)
smithy-build.json    <- Codegen configuration (TypeScript client + Maven deps)
.github/workflows/   <- CI: build, publish, CodeQL scanning
```

## Development

### Prerequisites

- [Smithy CLI](https://smithy.io/2.0/guides/smithy-cli/cli_installation.html) (1.72.0+)
- Node.js 22+
- Java 17+ (required by Smithy CLI)

### Generate and build the SDK locally

```bash
# Generate TypeScript client from Smithy model
smithy build

# Build the generated client
cd build/smithy/typescript-client/typescript-codegen
npm install
npm run build

# Test it
node -e "const sdk = require('.'); console.log(Object.keys(sdk).length, 'exports')"
```

### Endpoint resolution

The SDK resolves the service endpoint from the region:

| Configuration | Endpoint |
|---|---|
| `region: 'us-west-2'` | `https://api.acxd.connect.us-west-2.amazonaws.com` |
| `endpoint: 'https://custom-url'` | Uses the override (for testing) |

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for how to report security issues.

## License

This project is licensed under the Apache-2.0 License. See [LICENSE](LICENSE).
