// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

@http(method: "GET", uri: "/sdk/languages")
@readonly
operation GetWorkspaceLanguages {
    output: GetWorkspaceLanguagesResponse
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

@http(method: "PUT", uri: "/sdk/languages")
@idempotent
operation UpdateWorkspaceLanguages {
    input: UpdateWorkspaceLanguagesRequest
    output: UpdateWorkspaceLanguagesResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

@http(method: "POST", uri: "/sdk/languages/propagate")
operation PropagateWorkspaceLanguages {
    output: PropagateWorkspaceLanguagesResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

structure GetWorkspaceLanguagesResponse {
    @required
    languageCodes: LanguageCodeList
}

structure UpdateWorkspaceLanguagesRequest {
    @required
    @length(min: 1)
    languageCodes: LanguageCodeList
}

structure UpdateWorkspaceLanguagesResponse {
    @required
    languageCodes: LanguageCodeList
}

structure PropagateWorkspaceLanguagesResponse {
    @required
    status: OperationStatus
}

enum OperationStatus {
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
}
