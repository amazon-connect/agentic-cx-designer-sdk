// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Team
// ============================================================================
/// Retrieves the team settings for the authenticated workspace.
@http(method: "GET", uri: "/sdk/team")
@readonly
operation GetTeam {
    output: Team
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates team settings.
@http(method: "PATCH", uri: "/sdk/team")
@idempotent
operation UpdateTeam {
    input: UpdateTeamRequest
    output: Team
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Creates a new team.
@http(method: "POST", uri: "/sdk/team", code: 201)
operation CreateTeam {
    input: CreateTeamRequest
    output: Team
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

// ============================================================================
// Request/Response Structures — Team
// ============================================================================
structure CreateTeamRequest {
    @required
    @length(min: 1, max: 36)
    @pattern("^[A-Za-z0-9 ,.'-]+$")
    name: String

    @required
    @length(min: 3, max: 256)
    email: String

    @required
    @length(min: 1, max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    firstName: String

    @length(max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    lastName: String
}

structure UpdateTeamRequest {
    @length(min: 1, max: 36)
    @pattern("^[A-Za-z0-9 ,.'-]+$")
    name: String

    @length(min: 3, max: 256)
    email: String
}

// ============================================================================
// Resource Shapes — Team
// ============================================================================
structure Team {
    @required
    teamId: UUIDv4

    name: String

    createdAt: DateTime

    updatedAt: DateTime
}
