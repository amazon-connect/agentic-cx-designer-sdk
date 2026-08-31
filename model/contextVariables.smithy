// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// --- Operations ---
/// Lists all context variables for the workspace.
@http(method: "GET", uri: "/sdk/context-variables")
@readonly
operation ListContextVariables {
    input: ListContextVariablesRequest
    output: ListContextVariablesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new context variable in the workspace.
@http(method: "POST", uri: "/sdk/context-variables", code: 201)
operation CreateContextVariable {
    input: CreateContextVariableRequest
    output: ContextVariable
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Updates an existing context variable.
@http(method: "PATCH", uri: "/sdk/context-variables/{contextVariableIdentifier}")
@idempotent
operation UpdateContextVariable {
    input: UpdateContextVariableRequest
    output: ContextVariable
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a context variable by name.
@http(method: "DELETE", uri: "/sdk/context-variables/{contextVariableIdentifier}", code: 204)
@idempotent
operation DeleteContextVariable {
    input: DeleteContextVariableRequest
    errors: [
        ResourceNotFoundException
        InternalServerException
    ]
}

// --- Custom Types ---
@length(min: 1, max: 64)
@pattern("^(?!acxd_context)[A-Za-z_]+$")
string ContextVariableName

enum ContextVariableType {
    TEXT = "text"
    STRING = "string"
    NUMBER = "number"
    BOOLEAN = "boolean"
}

// --- Request/Response Structures ---
structure ListContextVariablesRequest {}

structure ListContextVariablesResponse {
    @required
    items: ContextVariableList
}

structure CreateContextVariableRequest {
    @required
    name: ContextVariableName

    schema: Document

    disallowExternalModification: Boolean
}

structure UpdateContextVariableRequest {
    @required
    @httpLabel
    contextVariableIdentifier: ContextVariableName

    schema: Document

    disallowExternalModification: Boolean
}

structure DeleteContextVariableRequest {
    @required
    @httpLabel
    contextVariableIdentifier: ContextVariableName
}

// --- Resource Shapes ---
/// Single context variable — used in all responses (Create, Update, List).
structure ContextVariable {
    @required
    name: ContextVariableName

    @required
    type: ContextVariableType

    schema: Document

    disallowExternalModification: Boolean

    metadata: ContextVariableMetadata

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure ContextVariableMetadata {
    @length(max: 512)
    path: String

    tags: ContextVariableTagList
}

@length(max: 5)
list ContextVariableTagList {
    member: ContextVariableTag
}

@length(min: 1, max: 256)
string ContextVariableTag

@length(max: 250)
list ContextVariableList {
    member: ContextVariable
}
