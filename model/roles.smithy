// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Roles
// ============================================================================
/// Lists all roles for the workspace.
@http(method: "GET", uri: "/sdk/roles")
@readonly
operation ListRoles {
    input: ListRolesRequest
    output: ListRolesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new role.
@http(method: "POST", uri: "/sdk/roles", code: 201)
operation CreateRole {
    input: CreateRoleRequest
    output: Role
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Gets a single role by ID.
@http(method: "GET", uri: "/sdk/roles/{roleId}")
@readonly
operation GetRole {
    input: GetRoleRequest
    output: Role
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates a role.
@http(method: "PATCH", uri: "/sdk/roles/{roleId}")
@idempotent
operation UpdateRole {
    input: UpdateRoleRequest
    output: Role
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Deletes a role.
@http(method: "DELETE", uri: "/sdk/roles/{roleId}", code: 204)
@idempotent
operation DeleteRole {
    input: DeleteRoleRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        ConflictException
        InternalServerException
    ]
}

/// Gets the list of available permissions that can be assigned to roles.
@http(method: "GET", uri: "/sdk/roles/permissions")
@readonly
operation GetRolePermissions {
    input: GetRolePermissionsRequest
    output: GetRolePermissionsResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Enums — Roles
// ============================================================================
enum RoleType {
    STUDIO = "studio"
    VOICE_COMPASS = "voicecompass"
    VOICE_INSIGHTS = "voiceinsights"
}

enum PermissionEffect {
    ALLOW = "allow"
    DENY = "deny"
}

enum RoleConditionOperandType {
    LANGUAGE_CODE = "languageCode"
    RESOURCE_ID = "resourceId"
    CONSTANT = "constant"
}

enum RoleConditionOperator {
    EQ = "EQ"
    NEQ = "NEQ"
    PREFIX = "PREFIX"
    NOT_PREFIX = "NOT_PREFIX"
    SUFFIX = "SUFFIX"
    NOT_SUFFIX = "NOT_SUFFIX"
    CONTAINS = "CONTAINS"
    NOT_CONTAINS = "NOT_CONTAINS"
}

enum RoleConditionBooleanOperator {
    AND = "AND"
    OR = "OR"
}

// ============================================================================
// Custom Types — Roles
// ============================================================================
@pattern("^[A-Za-z0-9 -]+$")
@length(min: 3, max: 36)
string RoleName

/// Role description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 200)
string RoleDescription

// ============================================================================
// Request/Response Structures — Roles
// ============================================================================
structure ListRolesRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer

    @httpQuery("type")
    type: RoleType
}

structure ListRolesResponse {
    @required
    items: RoleList

    nextToken: String
}

structure CreateRoleRequest {
    @required
    name: RoleName

    type: RoleType

    description: RoleDescription

    permissions: RolePermissionList

    conditionCatalog: RoleConditionCatalogList
}

structure GetRoleRequest {
    @required
    @httpLabel
    roleId: String
}

structure UpdateRoleRequest {
    @required
    @httpLabel
    roleId: String

    name: RoleName

    type: RoleType

    description: RoleDescription

    permissions: RolePermissionList

    conditionCatalog: RoleConditionCatalogList
}

structure DeleteRoleRequest {
    @required
    @httpLabel
    roleId: String
}

structure GetRolePermissionsRequest {
    @required
    @httpQuery("type")
    type: RoleType
}

structure GetRolePermissionsResponse {
    @required
    permissions: Document
}

// ============================================================================
// Resource Shapes — Roles
// ============================================================================
structure Role {
    @required
    roleId: String

    @required
    name: RoleName

    type: RoleType

    description: RoleDescription

    permissions: RolePermissionList

    conditionCatalog: RoleConditionCatalogList

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure RolePermission {
    @required
    permissionId: String

    @required
    effect: PermissionEffect

    conditionId: String
}

structure RoleConditionCatalogEntry {
    categoryId: String
    subcategoryId: String
    conditionId: String
    conditions: RoleConditions
}

/// A single condition comparison.
structure RoleCondition {
    @required
    left: RoleConditionOperand

    right: RoleConditionOperand

    @required
    operator: RoleConditionOperator
}

/// A composite condition with a boolean operator and nested conditions.
structure RoleCompositeCondition {
    @required
    operator: RoleConditionBooleanOperator

    @required
    items: RoleConditionsList
}

/// Conditions can be a single condition or a composite.
union RoleConditions {
    condition: RoleCondition
    composite: RoleCompositeCondition
}

structure RoleConditionOperand {
    @required
    type: RoleConditionOperandType

    value: String
}

// ============================================================================
// Lists — Roles
// ============================================================================
list RoleList {
    member: Role
}

list RolePermissionList {
    member: RolePermission
}

list RoleConditionCatalogList {
    member: RoleConditionCatalogEntry
}

list RoleConditionsList {
    member: RoleConditions
}
