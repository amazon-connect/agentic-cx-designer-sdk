// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Knowledge Bases
// ============================================================================
/// Lists all knowledge bases for the workspace.
@http(method: "GET", uri: "/sdk/knowledge-bases")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListKnowledgeBases {
    input: ListKnowledgeBasesRequest
    output: ListKnowledgeBasesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new knowledge base.
@http(method: "POST", uri: "/sdk/knowledge-bases", code: 201)
operation CreateKnowledgeBase {
    input: CreateKnowledgeBaseRequest
    output: KnowledgeBase
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single knowledge base by ID.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}")
@readonly
operation GetKnowledgeBase {
    input: GetKnowledgeBaseRequest
    output: KnowledgeBase
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing knowledge base.
@http(method: "PATCH", uri: "/sdk/knowledge-bases/{knowledgeBaseId}")
@idempotent
operation UpdateKnowledgeBase {
    input: UpdateKnowledgeBaseRequest
    output: KnowledgeBase
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a knowledge base by ID.
@http(method: "DELETE", uri: "/sdk/knowledge-bases/{knowledgeBaseId}", code: 204)
@idempotent
operation DeleteKnowledgeBase {
    input: DeleteKnowledgeBaseRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Clones a knowledge base, creating a new copy with a new ID.
@http(method: "POST", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/clone", code: 201)
operation CloneKnowledgeBase {
    input: CloneKnowledgeBaseRequest
    output: KnowledgeBase
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Publishes a knowledge base (triggers indexing/deployment).
@http(method: "POST", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/publish", code: 201)
operation PublishKnowledgeBase {
    input: PublishKnowledgeBaseRequest
    output: KnowledgeBaseDeployment
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Retrieves a specific knowledge base publication by deployment ID.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/publications/{deploymentId}")
@readonly
operation GetKnowledgeBasePublication {
    input: GetKnowledgeBasePublicationRequest
    output: KnowledgeBaseDeployment
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Lists all publications for a knowledge base.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/publications")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListKnowledgeBasePublications {
    input: ListKnowledgeBasePublicationsRequest
    output: ListKnowledgeBasePublicationsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Enums — Knowledge Bases
// ============================================================================
/// The type of knowledge base.
enum KnowledgeBaseType {
    ARTICLES = "articles"
    DOCUMENTS = "documents"
}

/// Creation status of a knowledge base.
enum KnowledgeBaseCreationStatus {
    PENDING = "PENDING"
    SUCCEEDED = "SUCCEEDED"
}

/// Deployment status of a knowledge base publication.
enum KnowledgeBaseDeploymentStatus {
    SCHEDULED = "scheduled"
    PUBLISHED = "published"
    FAILED = "failed"
}

// ============================================================================
// Custom Types — Knowledge Bases
// ============================================================================
/// Knowledge base name.
@pattern("^[A-Za-z0-9 _-]+$")
@length(min: 1, max: 100)
string KnowledgeBaseName

/// Knowledge base description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 200)
string KnowledgeBaseDescription

// ============================================================================
// Request Structures
// ============================================================================
structure ListKnowledgeBasesRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure CreateKnowledgeBaseRequest {
    @required
    name: KnowledgeBaseName

    @required
    type: KnowledgeBaseType

    description: KnowledgeBaseDescription

    response: KnowledgeBaseResponseConfig

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    metadataSchema: Document

    metadata: KnowledgeBaseMetadata
}

structure GetKnowledgeBaseRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4
}

structure UpdateKnowledgeBaseRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    name: KnowledgeBaseName

    type: KnowledgeBaseType

    description: KnowledgeBaseDescription

    response: KnowledgeBaseResponseConfig

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    metadataSchema: Document

    metadata: KnowledgeBaseMetadata
}

structure DeleteKnowledgeBaseRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4
}

structure CloneKnowledgeBaseRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    name: KnowledgeBaseName

    portTranslations: Boolean
}

structure PublishKnowledgeBaseRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    deploymentId: UUIDv4

    version: String

    description: KnowledgeBaseDescription
}

structure GetKnowledgeBasePublicationRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    deploymentId: UUIDv4
}

structure ListKnowledgeBasePublicationsRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

// ============================================================================
// Response Structures
// ============================================================================
structure ListKnowledgeBasesResponse {
    @required
    items: KnowledgeBaseList

    nextToken: String
}

structure ListKnowledgeBasePublicationsResponse {
    @required
    items: KnowledgeBaseDeploymentList

    nextToken: String
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full knowledge base resource.
structure KnowledgeBase {
    @required
    knowledgeBaseId: UUIDv4

    @required
    name: KnowledgeBaseName

    @required
    type: KnowledgeBaseType

    description: KnowledgeBaseDescription

    response: KnowledgeBaseResponseConfig

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    metadataSchema: Document

    creationStatus: KnowledgeBaseCreationStatus

    metadata: KnowledgeBaseMetadata

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

/// Knowledge base deployment record.
structure KnowledgeBaseDeployment {
    @required
    deploymentId: UUIDv4

    @required
    knowledgeBaseId: UUIDv4

    status: KnowledgeBaseDeploymentStatus

    version: String

    description: KnowledgeBaseDescription

    updatedBy: String
}

// ============================================================================
// Config Structures
// ============================================================================
/// Response behavior configuration for a knowledge base.
structure KnowledgeBaseResponseConfig {
    summarize: Boolean

    @range(min: 0, max: 100)
    minConfidenceScore: Float

    temperature: Float

    topP: Float

    k: Integer
}

/// Metadata for a knowledge base — path and classification tags.
structure KnowledgeBaseMetadata {
    @length(max: 512)
    path: String

    tags: KnowledgeBaseTagList
}

// ============================================================================
// Lists
// ============================================================================
list KnowledgeBaseList {
    member: KnowledgeBase
}

list KnowledgeBaseDeploymentList {
    member: KnowledgeBaseDeployment
}

@length(max: 5)
list KnowledgeBaseTagList {
    member: KnowledgeBaseTag
}

@length(min: 1, max: 256)
string KnowledgeBaseTag
