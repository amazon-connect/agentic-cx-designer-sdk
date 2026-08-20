// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Workspaces
// ============================================================================
/// Lists all workspaces for the team.
@http(method: "GET", uri: "/sdk/workspaces")
@readonly
operation ListWorkspaces {
    input: ListWorkspacesRequest
    output: ListWorkspacesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new workspace.
@http(method: "POST", uri: "/sdk/workspaces", code: 201)
operation CreateWorkspace {
    input: CreateWorkspaceRequest
    output: Workspace
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Gets a single workspace by ID.
@http(method: "GET", uri: "/sdk/workspaces/{workspaceId}")
@readonly
operation GetWorkspace {
    input: GetWorkspaceRequest
    output: Workspace
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates a workspace.
@http(method: "PATCH", uri: "/sdk/workspaces/{workspaceId}")
@idempotent
operation UpdateWorkspace {
    input: UpdateWorkspaceRequest
    output: Workspace
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Deletes a workspace.
@http(method: "DELETE", uri: "/sdk/workspaces/{workspaceId}", code: 204)
@idempotent
operation DeleteWorkspace {
    input: DeleteWorkspaceRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Request/Response Structures — Workspaces
// ============================================================================
structure ListWorkspacesRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure ListWorkspacesResponse {
    @required
    items: WorkspaceList

    nextToken: String
}

structure CreateWorkspaceRequest {
    @required
    @length(min: 1, max: 36)
    @pattern("^[A-Za-z0-9 ,.'-]+$")
    name: String

    tags: WorkspaceTagList
}

structure GetWorkspaceRequest {
    @required
    @httpLabel
    workspaceId: UUIDv4
}

structure UpdateWorkspaceRequest {
    @required
    @httpLabel
    workspaceId: UUIDv4

    @length(min: 1, max: 36)
    @pattern("^[A-Za-z0-9 ,.'-]+$")
    name: String

    tags: WorkspaceTagList
}

structure DeleteWorkspaceRequest {
    @required
    @httpLabel
    workspaceId: UUIDv4
}

// ============================================================================
// Resource Shapes — Workspaces
// ============================================================================
structure Workspace {
    @required
    workspaceId: UUIDv4

    name: String

    tags: WorkspaceTagList

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

// ============================================================================
// Lists — Workspaces
// ============================================================================
list WorkspaceList {
    member: Workspace
}

@length(max: 5)
list WorkspaceTagList {
    member: String
}
