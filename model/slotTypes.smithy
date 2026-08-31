// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — SlotTypes
// ============================================================================
/// Lists all slot types for the workspace, paginated.
@http(method: "GET", uri: "/sdk/slot-types")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListSlotTypes {
    input: ListSlotTypesRequest
    output: ListSlotTypesResponse
    errors: [
        ValidationException
        InternalServerException
    ]
}

/// Creates a new slot type.
@http(method: "POST", uri: "/sdk/slot-types", code: 201)
operation CreateSlotType {
    input: CreateSlotTypeRequest
    output: SlotType
    errors: [
        ValidationException
        ConflictException
        InternalServerException
    ]
}

/// Retrieves a single slot type by ID.
@http(method: "GET", uri: "/sdk/slot-types/{slotTypeIdentifier}")
@readonly
operation GetSlotType {
    input: GetSlotTypeRequest
    output: SlotType
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

/// Updates an existing slot type.
@http(method: "PATCH", uri: "/sdk/slot-types/{slotTypeIdentifier}")
@idempotent
operation UpdateSlotType {
    input: UpdateSlotTypeRequest
    output: SlotType
    errors: [
        ResourceNotFoundException
        ValidationException
        InternalServerException
    ]
}

/// Deletes a slot type by ID.
@http(method: "DELETE", uri: "/sdk/slot-types/{slotTypeIdentifier}", code: 204)
@idempotent
operation DeleteSlotType {
    input: DeleteSlotTypeRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
    ]
}

// ============================================================================
// Custom Types — SlotTypes
// ============================================================================
/// Slot type identifier — alphabetic characters only.
@pattern("^[A-Za-z]+$")
@length(min: 3, max: 100)
string SlotTypeId

/// Slot type description — printable ASCII text.
@pattern("^[ -~]*$")
@length(max: 200)
string SlotTypeDescription

// ============================================================================
// Request/Response Structures
// ============================================================================
structure ListSlotTypesRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListSlotTypesResponse {
    @required
    items: SlotTypeList

    nextToken: String
}

structure CreateSlotTypeRequest {
    @required
    slotTypeId: SlotTypeId

    @required
    values: SlotTypeValueList

    sensitive: Boolean

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    description: SlotTypeDescription

    metadata: SlotTypeMetadata
}

structure GetSlotTypeRequest {
    @required
    @httpLabel
    slotTypeIdentifier: SlotTypeId

    @httpQuery("languageCode")
    languageCode: LanguageCode
}

structure UpdateSlotTypeRequest {
    @required
    @httpLabel
    slotTypeIdentifier: SlotTypeId

    values: SlotTypeValueList

    sensitive: Boolean

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    description: SlotTypeDescription

    metadata: SlotTypeMetadata
}

structure DeleteSlotTypeRequest {
    @required
    @httpLabel
    slotTypeIdentifier: SlotTypeId
}

// ============================================================================
// Resource Shapes
// ============================================================================
/// Full slot type resource.
structure SlotType {
    @required
    slotTypeId: SlotTypeId

    @required
    values: SlotTypeValueList

    sensitive: Boolean

    mainLanguageCode: LanguageCode

    languageCodes: LanguageCodeList

    description: SlotTypeDescription

    metadata: SlotTypeMetadata

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure SlotTypeMetadata {
    @length(max: 512)
    path: String

    tags: SlotTypeTagList
}

/// A value entry in a slot type.
structure SlotTypeValue {
    @required
    @length(min: 1, max: 256)
    value: String

    valueId: String

    synonyms: SlotTypeSynonymList

    skipTraining: Boolean

    skipTranslation: Boolean

    translated: Boolean

    @length(max: 200)
    choicePayload: String
}

// ============================================================================
// Lists
// ============================================================================
list SlotTypeList {
    member: SlotType
}

list SlotTypeValueList {
    member: SlotTypeValue
}

list SlotTypeSynonymList {
    member: SlotTypeSynonym
}

@length(min: 1, max: 256)
string SlotTypeSynonym

@length(max: 5)
list SlotTypeTagList {
    member: SlotTypeTag
}

@length(min: 1, max: 256)
string SlotTypeTag
