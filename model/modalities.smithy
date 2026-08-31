// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Modalities
// ============================================================================
/// Lists all modalities for the workspace, paginated.
@http(method: "GET", uri: "/sdk/modalities")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListModalities {
    input: ListModalitiesRequest
    output: ListModalitiesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new modality.
@http(method: "POST", uri: "/sdk/modalities", code: 201)
operation CreateModality {
    input: CreateModalityRequest
    output: Modality
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single modality by ID.
@http(method: "GET", uri: "/sdk/modalities/{modalityIdentifier}")
@readonly
operation GetModality {
    input: GetModalityRequest
    output: Modality
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing modality.
@http(method: "PATCH", uri: "/sdk/modalities/{modalityIdentifier}")
@idempotent
operation UpdateModality {
    input: UpdateModalityRequest
    output: Modality
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a modality by ID.
@http(method: "DELETE", uri: "/sdk/modalities/{modalityIdentifier}", code: 204)
@idempotent
operation DeleteModality {
    input: DeleteModalityRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — Modalities
// ============================================================================
/// Modality identifier — alphanumeric with underscores, cannot start with a digit.
@pattern("^(?!\\d)[a-zA-Z0-9_]+$")
@length(min: 1, max: 50)
string ModalityId

enum ModalitySchemaType {
    STRING = "string"
    NUMBER = "number"
    BOOLEAN = "boolean"
    ARRAY = "array"
    OBJECT = "object"
}

// ============================================================================
// Request/Response Structures
// ============================================================================
structure ListModalitiesRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListModalitiesResponse {
    @required
    items: ModalityList

    nextToken: String
}

structure CreateModalityRequest {
    @required
    modalityId: ModalityId

    @required
    schema: ModalitySchema

    metadata: ModalityMetadata
}

structure GetModalityRequest {
    @required
    @httpLabel
    modalityIdentifier: ModalityId
}

structure UpdateModalityRequest {
    @required
    @httpLabel
    modalityIdentifier: ModalityId

    schema: ModalitySchema

    metadata: ModalityMetadata
}

structure DeleteModalityRequest {
    @required
    @httpLabel
    modalityIdentifier: ModalityId
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full modality resource.
structure Modality {
    @required
    modalityId: ModalityId

    @required
    schema: ModalitySchema

    metadata: ModalityMetadata

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure ModalityMetadata {
    @length(max: 512)
    path: String

    tags: ModalityTagList
}

/// Recursive schema definition for a modality field.
structure ModalitySchema {
    @required
    type: ModalitySchemaType

    @length(max: 255)
    @pattern("^[ -~]*$")
    description: String

    isSensitive: Boolean

    /// Nested properties (required when type=object).
    properties: ModalitySchemaMap

    /// Nested item schema (required when type=array).
    items: ModalitySchema
}

map ModalitySchemaMap {
    key: String
    value: ModalitySchema
}

// ============================================================================
// Lists
// ============================================================================
list ModalityList {
    member: Modality
}

@length(max: 5)
list ModalityTagList {
    member: ModalityTag
}

@length(min: 1, max: 256)
string ModalityTag
