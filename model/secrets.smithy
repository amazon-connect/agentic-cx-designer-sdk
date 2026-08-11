// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// --- Operations ---
/// Lists all secrets for the workspace, paginated.
@http(method: "GET", uri: "/sdk/secrets")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListSecrets {
    input: ListSecretsRequest
    output: ListSecretsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new secret in the workspace.
@http(method: "POST", uri: "/sdk/secrets", code: 201)
operation CreateSecret {
    input: CreateSecretRequest
    output: Secret
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single secret by ID.
@http(method: "GET", uri: "/sdk/secrets/{secretIdentifier}")
@readonly
operation GetSecret {
    input: GetSecretRequest
    output: Secret
    errors: [
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing secret.
@http(method: "PATCH", uri: "/sdk/secrets/{secretIdentifier}")
@idempotent
operation UpdateSecret {
    input: UpdateSecretRequest
    output: Secret
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a secret by ID.
@http(method: "DELETE", uri: "/sdk/secrets/{secretIdentifier}", code: 204)
@idempotent
operation DeleteSecret {
    input: DeleteSecretRequest
    errors: [
        ResourceNotFoundException
        InternalServerException
    ]
}

// --- Custom Types ---
@sensitive
@length(min: 1, max: 4096)
string SecretValue

@length(min: 3, max: 100)
@pattern("^[A-Za-z0-9_]+$")
string SecretName

@length(min: 0, max: 200)
@pattern("^[^\\p{C}]*$")
string Description

@length(min: 1, max: 256)
string UpdatedBy

// --- Request/Response Structures ---
structure ListSecretsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListSecretsResponse {
    @required
    items: SecretSummaryList

    nextToken: String
}

structure CreateSecretRequest {
    @required
    name: SecretName

    @required
    secretValue: SecretValue

    description: Description

    isSensitive: Boolean

    metadata: SecretMetadata
}

structure GetSecretRequest {
    @required
    @httpLabel
    secretIdentifier: SecretName
}

structure UpdateSecretRequest {
    @required
    @httpLabel
    secretIdentifier: SecretName

    secretValue: SecretValue

    description: Description

    isSensitive: Boolean

    metadata: SecretMetadata
}

structure DeleteSecretRequest {
    @required
    @httpLabel
    secretIdentifier: SecretName
}

// --- Resource Shapes ---
structure Secret {
    @required
    name: SecretName

    @required
    secretValue: SecretValue

    description: Description

    isSensitive: Boolean

    metadata: SecretMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: UpdatedBy
}

structure SecretSummary {
    @required
    name: SecretName

    description: Description

    isSensitive: Boolean

    metadata: SecretMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime
}

structure SecretMetadata {
    @length(max: 512)
    path: String

    tags: SecretTagList
}

@length(min: 1, max: 256)
string SecretTag

@length(max: 5)
list SecretTagList {
    member: SecretTag
}

list SecretSummaryList {
    member: SecretSummary
}
