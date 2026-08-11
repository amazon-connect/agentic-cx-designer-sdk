// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Programmatic Users
// ============================================================================
/// Creates a new programmatic user (machine identity for Platform SDK access).
@http(method: "POST", uri: "/sdk/programmatic-users", code: 201)
operation CreateProgrammaticUser {
    input: CreateProgrammaticUserRequest
    output: ProgrammaticUser
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Lists all programmatic users for the workspace.
@http(method: "GET", uri: "/sdk/programmatic-users")
@readonly
operation ListProgrammaticUsers {
    input: ListProgrammaticUsersRequest
    output: ListProgrammaticUsersResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Gets a single programmatic user by ID.
@http(method: "GET", uri: "/sdk/programmatic-users/{userId}")
@readonly
operation GetProgrammaticUser {
    input: GetProgrammaticUserRequest
    output: ProgrammaticUser
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates a programmatic user (name, roles).
@http(method: "PATCH", uri: "/sdk/programmatic-users/{userId}")
@idempotent
operation UpdateProgrammaticUser {
    input: UpdateProgrammaticUserRequest
    output: ProgrammaticUser
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Deletes a programmatic user. Fails if API keys are still associated.
@http(method: "DELETE", uri: "/sdk/programmatic-users/{userId}", code: 204)
@idempotent
operation DeleteProgrammaticUser {
    input: DeleteProgrammaticUserRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        ConflictException
        InternalServerException
    ]
}

// ============================================================================
// Role Configuration — Programmatic Users
// ============================================================================
union RoleConfig {
    accountRole: AccountRole
    workspaceRoles: WorkspaceRoleAssignmentList
}

/// Account-level role.
enum AccountRole {
    ADMINISTRATOR = "administrator"
}

/// A role assignment scoped to a specific workspace.
/// Provide either `role` (predefined) or `roleId` (custom UUID), not both.
structure WorkspaceRoleAssignment {
    @required
    workspaceId: UUIDv4

    role: PredefinedRoleName

    roleId: UUIDv4
}

list WorkspaceRoleAssignmentList {
    member: WorkspaceRoleAssignment
}

// ============================================================================
// Request/Response Structures — Programmatic Users
// ============================================================================
/// Programmatic user name.
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 128)
string ProgrammaticUserName

structure CreateProgrammaticUserRequest {
    @required
    name: ProgrammaticUserName

    roleConfig: RoleConfig
}

structure ListProgrammaticUsersRequest {
    @httpQuery("maxResults")
    maxResults: Integer

    @httpQuery("nextToken")
    nextToken: String
}

structure ListProgrammaticUsersResponse {
    @required
    items: ProgrammaticUserList

    nextToken: String
}

structure GetProgrammaticUserRequest {
    @required
    @httpLabel
    userId: UUIDv4
}

structure UpdateProgrammaticUserRequest {
    @required
    @httpLabel
    userId: UUIDv4

    name: ProgrammaticUserName

    roleConfig: RoleConfig
}

structure DeleteProgrammaticUserRequest {
    @required
    @httpLabel
    userId: UUIDv4
}

// ============================================================================
// Resource Shapes — Programmatic Users
// ============================================================================
structure ProgrammaticUser {
    @required
    userId: UUIDv4

    @required
    teamId: String

    @required
    name: ProgrammaticUserName

    roleConfig: RoleConfig

    @required
    createdAt: DateTime

    updatedAt: DateTime
}

list ProgrammaticUserList {
    member: ProgrammaticUser
}
