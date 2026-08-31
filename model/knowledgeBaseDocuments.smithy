// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Knowledge Base Documents
// ============================================================================
/// Lists all documents for a knowledge base.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/documents")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListKnowledgeBaseDocuments {
    input: ListKnowledgeBaseDocumentsRequest
    output: ListKnowledgeBaseDocumentsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Retrieves a pre-signed download URL for a knowledge base document.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/documents/{documentId}")
@readonly
operation GetKnowledgeBaseDocument {
    input: GetKnowledgeBaseDocumentRequest
    output: GetKnowledgeBaseDocumentResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Registers a document and returns a pre-signed upload URL.
@http(method: "PUT", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/documents/{documentId}")
@idempotent
operation PutKnowledgeBaseDocument {
    input: PutKnowledgeBaseDocumentRequest
    output: PutKnowledgeBaseDocumentResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Deletes a knowledge base document.
@http(method: "DELETE", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/documents/{documentId}", code: 204)
@idempotent
operation DeleteKnowledgeBaseDocument {
    input: DeleteKnowledgeBaseDocumentRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Enums — Knowledge Base Documents
// ============================================================================
/// Upload status of a document.
enum DocumentUploadStatus {
    PENDING = "PENDING"
    UPLOADED = "UPLOADED"
    DELETED = "DELETED"
}

// ============================================================================
// Request Structures
// ============================================================================
structure ListKnowledgeBaseDocumentsRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure GetKnowledgeBaseDocumentRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    @length(max: 255)
    documentId: String
}

structure PutKnowledgeBaseDocumentRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    @length(max: 255)
    documentId: String

    @required
    contentType: String

    customerMetadata: Document
}

structure DeleteKnowledgeBaseDocumentRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    @length(max: 255)
    documentId: String
}

// ============================================================================
// Response Structures
// ============================================================================
structure ListKnowledgeBaseDocumentsResponse {
    @required
    items: KnowledgeBaseDocumentSummaryList

    nextToken: String
}

structure GetKnowledgeBaseDocumentResponse {
    @required
    url: String
}

structure PutKnowledgeBaseDocumentResponse {
    @required
    url: String

    @required
    fields: Document
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Summary of a knowledge base document (returned in list responses).
structure KnowledgeBaseDocumentSummary {
    @required
    @length(max: 255)
    documentId: String

    uploadStatus: DocumentUploadStatus

    contentType: String

    customerMetadata: Document

    createdAt: DateTime
}

// ============================================================================
// Lists
// ============================================================================
list KnowledgeBaseDocumentSummaryList {
    member: KnowledgeBaseDocumentSummary
}
