// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Knowledge Base Articles
// ============================================================================
/// Lists all articles for a knowledge base.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/articles")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListKnowledgeBaseArticles {
    input: ListKnowledgeBaseArticlesRequest
    output: ListKnowledgeBaseArticlesResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Creates a new article in a knowledge base.
@http(method: "POST", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/articles", code: 201)
operation CreateKnowledgeBaseArticle {
    input: CreateKnowledgeBaseArticleRequest
    output: KnowledgeBaseArticle
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Retrieves a single knowledge base article by ID.
@http(method: "GET", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/articles/{articleId}")
@readonly
operation GetKnowledgeBaseArticle {
    input: GetKnowledgeBaseArticleRequest
    output: KnowledgeBaseArticle
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing knowledge base article.
@http(method: "PATCH", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/articles/{articleId}")
@idempotent
operation UpdateKnowledgeBaseArticle {
    input: UpdateKnowledgeBaseArticleRequest
    output: KnowledgeBaseArticle
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a knowledge base article by ID.
@http(method: "DELETE", uri: "/sdk/knowledge-bases/{knowledgeBaseId}/articles/{articleId}", code: 204)
@idempotent
operation DeleteKnowledgeBaseArticle {
    input: DeleteKnowledgeBaseArticleRequest
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

// ============================================================================
// Enums — Knowledge Base Articles
// ============================================================================
// ============================================================================
// Request Structures
// ============================================================================
structure ListKnowledgeBaseArticlesRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer
}

structure CreateKnowledgeBaseArticleRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    question: KnowledgeBaseArticleQuestion

    @required
    responses: MessageList

    articleMetadata: Document

    @length(max: 10000)
    payload: String

    tags: KnowledgeBaseArticleTagList
}

structure GetKnowledgeBaseArticleRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    articleId: UUIDv4
}

structure UpdateKnowledgeBaseArticleRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    articleId: UUIDv4

    question: KnowledgeBaseArticleQuestion

    responses: MessageList

    articleMetadata: Document

    @length(max: 10000)
    payload: String

    tags: KnowledgeBaseArticleTagList
}

structure DeleteKnowledgeBaseArticleRequest {
    @required
    @httpLabel
    knowledgeBaseId: UUIDv4

    @required
    @httpLabel
    articleId: UUIDv4
}

// ============================================================================
// Response Structures
// ============================================================================
structure ListKnowledgeBaseArticlesResponse {
    @required
    items: KnowledgeBaseArticleList

    nextToken: String
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full knowledge base article resource.
structure KnowledgeBaseArticle {
    @required
    knowledgeBaseId: UUIDv4

    @required
    articleId: UUIDv4

    @required
    question: KnowledgeBaseArticleQuestion

    @required
    responses: MessageList

    articleMetadata: Document

    @length(max: 10000)
    payload: String

    tags: KnowledgeBaseArticleTagList

    @required
    createdAt: DateTime

    @required
    updatedAt: DateTime

    updatedBy: String
}

// ============================================================================
// Lists
// ============================================================================
list KnowledgeBaseArticleList {
    member: KnowledgeBaseArticle
}

@length(max: 5)
list KnowledgeBaseArticleTagList {
    member: KnowledgeBaseArticleTag
}

@length(min: 1, max: 256)
string KnowledgeBaseArticleTag
