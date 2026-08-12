// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Users
// ============================================================================
/// Lists all users for the workspace.
@http(method: "GET", uri: "/sdk/users")
@readonly
operation ListUsers {
    input: ListUsersRequest
    output: ListUsersResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new user.
@http(method: "POST", uri: "/sdk/users", code: 201)
operation CreateUser {
    input: CreateUserRequest
    output: User
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Gets a single user by ID.
@http(method: "GET", uri: "/sdk/users/{userId}")
@readonly
operation GetUser {
    input: GetUserRequest
    output: User
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates a user.
@http(method: "PATCH", uri: "/sdk/users/{userId}")
@idempotent
operation UpdateUser {
    input: UpdateUserRequest
    output: User
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Deletes a user.
@http(method: "DELETE", uri: "/sdk/users/{userId}", code: 204)
@idempotent
operation DeleteUser {
    input: DeleteUserRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Enums — Users
// ============================================================================
enum CxnRole {
    MEMBER = "member"
    ADMINISTRATOR = "administrator"
    OWNER = "owner"
}

// ============================================================================
// Request/Response Structures — Users
// ============================================================================
structure ListUsersRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure ListUsersResponse {
    @required
    items: UserList

    nextToken: String
}

structure CreateUserRequest {
    @required
    userId: String

    @required
    cxnRole: CxnRole

    @required
    userArn: String

    @required
    @length(min: 1, max: 128)
    username: String

    @length(min: 1, max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    firstName: String

    @length(max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    lastName: String

    @length(min: 3, max: 256)
    email: String

    applicationIds: ApplicationIdList

    roles: UserRoleAssignmentList

    defaultRole: UserDefaultRole
}

structure GetUserRequest {
    @required
    @httpLabel
    userId: String
}

structure UpdateUserRequest {
    @required
    @httpLabel
    userId: String

    cxnRole: CxnRole

    userArn: String

    @length(min: 1, max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    firstName: String

    @length(max: 36)
    @pattern("^[A-Za-z ,.'-]+$")
    lastName: String

    @length(min: 3, max: 256)
    email: String

    applicationIds: ApplicationIdList

    roles: UserRoleAssignmentList

    defaultRole: UserDefaultRole
}

structure DeleteUserRequest {
    @required
    @httpLabel
    userId: String
}

// ============================================================================
// Resource Shapes — Users
// ============================================================================
structure User {
    @required
    userId: String

    cxnRole: CxnRole

    userArn: String

    username: String

    firstName: String

    lastName: String

    email: String

    applicationIds: ApplicationIdList

    roles: UserRoleAssignmentList

    defaultRole: UserDefaultRole

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure UserRoleAssignment {
    @required
    applicationId: UUIDv4

    @required
    role: PredefinedRoleName

    roleId: UUIDv4
}

structure UserDefaultRole {
    @required
    role: PredefinedRoleName

    roleId: UUIDv4
}

// ============================================================================
// Lists — Users
// ============================================================================
list UserList {
    member: User
}

list ApplicationIdList {
    member: UUIDv4
}

list UserRoleAssignmentList {
    member: UserRoleAssignment
}
