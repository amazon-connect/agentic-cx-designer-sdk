// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

@http(method: "POST", uri: "/sdk/translation-jobs", code: 202)
operation StartTranslationJob {
    input: StartTranslationJobRequest
    output: TranslationJob
    errors: [
        ValidationException
        ConflictException
        InternalServerException
        ThrottlingException
    ]
}

@http(method: "GET", uri: "/sdk/translation-jobs")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListTranslationJobs {
    input: ListTranslationJobsRequest
    output: ListTranslationJobsResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

@http(method: "GET", uri: "/sdk/translation-jobs/{jobIdentifier}")
@readonly
operation GetTranslationJob {
    input: GetTranslationJobRequest
    output: TranslationJob
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

enum TranslationJobStatus {
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
}

enum TranslationJobResourceStatus {
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
}

structure TranslationJobResource {
    @required
    resourceIdentifier: String

    @required
    resourceType: TranslatableResourceType
}

@uniqueItems
list TranslationJobResourceList {
    member: TranslationJobResource
}

@uniqueItems
list TranslationJobTagList {
    member: TranslationJobTag
}

@length(min: 1, max: 100)
string TranslationJobTag

structure TranslationJobResourceResult {
    resourceIdentifier: String
    resourceType: TranslatableResourceType
    status: TranslationJobResourceStatus
    failureReason: String
}

list TranslationJobResourceResultList {
    member: TranslationJobResourceResult
}

list TranslationJobList {
    member: TranslationJob
}

structure StartTranslationJobRequest {
    @required
    languageCodes: LanguageCodeList

    excludeMarkedTranslations: Boolean

    markAsTranslated: Boolean

    resources: TranslationJobResourceList

    applicationIdentifier: UUIDv4

    @length(max: 5)
    resourceTypes: TranslatableResourceTypeList

    @length(max: 5)
    tags: TranslationJobTagList

    @range(min: 1, max: 3600)
    throttleWaitTime: Integer
}

@uniqueItems
list TranslatableResourceTypeList {
    member: TranslatableResourceType
}

structure ListTranslationJobsRequest {
    @httpQuery("maxResults")
    @range(min: 1, max: 100)
    maxResults: Integer

    @httpQuery("nextToken")
    nextToken: String
}

structure ListTranslationJobsResponse {
    @required
    items: TranslationJobList

    nextToken: String
}

structure GetTranslationJobRequest {
    @required
    @httpLabel
    jobIdentifier: UUIDv4
}

structure TranslationJob {
    @required
    jobId: UUIDv4

    status: TranslationJobStatus

    languageCodes: LanguageCodeList

    resourceTypes: TranslatableResourceTypeList

    results: TranslationJobResourceResultList

    createdAt: DateTime

    updatedAt: DateTime
}
