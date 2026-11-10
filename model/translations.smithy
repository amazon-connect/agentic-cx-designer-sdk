// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

@http(method: "GET", uri: "/sdk/translations")
@readonly
operation GetResourceTranslations {
    input: GetResourceTranslationsRequest
    output: GetResourceTranslationsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

@http(method: "PUT", uri: "/sdk/translations")
@idempotent
operation PutResourceTranslations {
    input: PutResourceTranslationsRequest
    output: PutResourceTranslationsResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

enum TranslatableResourceType {
    FLOW = "flow"
    SLOT_TYPE = "slotType"
    JOURNEY = "journey"
    KNOWLEDGE_BASE = "knowledgeBase"
}

@length(min: 1, max: 256)
string TranslatableResourceIdentifier

structure GetResourceTranslationsRequest {
    @required
    @httpQuery("resourceType")
    resourceType: TranslatableResourceType

    @required
    @httpQuery("resourceIdentifier")
    resourceIdentifier: TranslatableResourceIdentifier

    @required
    @httpQuery("languageCode")
    languageCode: LanguageCode
}

structure GetResourceTranslationsResponse {
    @required
    translations: ResourceTranslations
}

structure PutResourceTranslationsRequest {
    @required
    resourceType: TranslatableResourceType

    @required
    resourceIdentifier: TranslatableResourceIdentifier

    @required
    languageCode: LanguageCode

    @required
    translations: ResourceTranslations
}

structure PutResourceTranslationsResponse {
    @required
    status: OperationStatus
}

union ResourceTranslations {
    flow: FlowTranslations
    slotType: SlotTypeValueTranslationList
    journey: JourneyStepTranslationList
    knowledgeBase: KnowledgeBaseArticleTranslationList
}

map FlowTranslations {
    key: UUIDv4
    value: FlowNodeMessageTranslations
}

map FlowNodeMessageTranslations {
    key: UUIDv4
    value: FlowMessageTranslation
}

structure FlowMessageTranslation {
    @required
    @length(max: 2000)
    text: String

    skipTranslation: Boolean

    translated: Boolean
}

@uniqueItems
list SlotTypeValueTranslationList {
    member: SlotTypeValueTranslation
}

structure SlotTypeValueTranslation {
    @length(min: 2, max: 128)
    valueId: String

    @required
    @length(min: 1, max: 2000)
    value: String

    synonyms: SlotTypeSynonymTranslationList

    skipTranslation: Boolean

    translated: Boolean
}

@uniqueItems
list SlotTypeSynonymTranslationList {
    member: SlotTypeSynonymTranslation
}

@length(min: 1)
string SlotTypeSynonymTranslation

@uniqueItems
list JourneyStepTranslationList {
    member: JourneyStepTranslation
}

structure JourneyStepTranslation {
    @required
    @length(min: 36, max: 36)
    stepId: String

    @required
    @length(max: 1000)
    body: String

    sort: Integer

    translated: Boolean
}

@uniqueItems
list KnowledgeBaseArticleTranslationList {
    member: KnowledgeBaseArticleTranslation
}

structure KnowledgeBaseArticleTranslation {
    @required
    articleId: UUIDv4

    @required
    question: KnowledgeBaseArticleQuestionTranslation

    @required
    responses: KnowledgeBaseArticleResponseTranslationList

    skipTranslation: Boolean

    translated: Boolean
}

structure KnowledgeBaseArticleQuestionTranslation {
    @required
    @length(max: 240)
    text: String
}

list KnowledgeBaseArticleResponseTranslationList {
    member: KnowledgeBaseArticleResponseTranslation
}

structure KnowledgeBaseArticleResponseTranslation {
    type: MessageType

    @required
    body: String
}
