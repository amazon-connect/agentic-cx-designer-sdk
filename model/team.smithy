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
