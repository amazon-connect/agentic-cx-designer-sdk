// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — API Tokens
// ============================================================================
/// Creates a new Platform SDK API token for a user.
@http(method: "POST", uri: "/sdk/programmatic-users/{userId}/api-tokens", code: 201)
operation CreateApiToken {
    input: CreateApiTokenRequest
    output: CreateApiTokenResponse
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Lists all API tokens for a user (metadata only, never exposes secrets).
@http(method: "GET", uri: "/sdk/programmatic-users/{userId}/api-tokens")
@readonly
operation ListApiTokens {
    input: ListApiTokensRequest
    output: ListApiTokensResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Permanently deletes an API token by its prefix.
@http(method: "DELETE", uri: "/sdk/programmatic-users/{userId}/api-tokens/{keyPrefix}", code: 204)
@idempotent
operation DeleteApiToken {
    input: DeleteApiTokenRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — API Tokens
// ============================================================================
@length(min: 20, max: 20)
@pattern("^[a-zA-Z0-9]+$")
string KeyPrefix

@sensitive
string ApiTokenSecret

/// API token description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 200)
string ApiTokenDescription

// ============================================================================
// Request/Response Structures — API Tokens
// ============================================================================
structure CreateApiTokenRequest {
    @required
    @httpLabel
    userId: UUIDv4

    description: ApiTokenDescription
}

structure CreateApiTokenResponse {
    @required
    token: ApiTokenSecret

    @required
    keyPrefix: KeyPrefix

    description: ApiTokenDescription

    @required
    createdAt: DateTime
}

structure ListApiTokensRequest {
    @required
    @httpLabel
    userId: UUIDv4
}

structure ListApiTokensResponse {
    @required
    items: ApiTokenList
}

structure DeleteApiTokenRequest {
    @required
    @httpLabel
    userId: UUIDv4

    @required
    @httpLabel
    keyPrefix: KeyPrefix
}

// ============================================================================
// Resource Shapes — API Tokens
// ============================================================================
structure ApiToken {
    @required
    keyPrefix: KeyPrefix

    description: ApiTokenDescription

    @required
    createdAt: DateTime

    lastAccessedAt: DateTime
}

list ApiTokenList {
    member: ApiToken
}
