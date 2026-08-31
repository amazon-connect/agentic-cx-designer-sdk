// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

use aws.api#service
use aws.protocols#restJson1
use smithy.rules#endpointRuleSet

/// Agentic CX Designer SDK Service — provides programmatic access to workspace resources.
@restJson1
@service(sdkId: "AgenticCXDesigner")
@httpApiKeyAuth(name: "x-api-key", in: "header")
@title("Agentic CX Designer SDK Service")
@endpointRuleSet({
    version: "1.0"
    serviceId: "AgenticCXDesigner"
    parameters: {
        Region: { type: "String", builtIn: "AWS::Region", required: true, documentation: "The AWS region to send requests to" }
    }
    rules: [
        {
            documentation: "Default regional endpoint"
            type: "endpoint"
            conditions: []
            endpoint: { url: "https://api.acxd.connect.{Region}.amazonaws.com" }
        }
    ]
})
service AgenticCXDesignerService {
    version: "2025-01-01"
    operations: [
        ListSecrets
        CreateSecret
        GetSecret
        UpdateSecret
        DeleteSecret
        ListContextVariables
        CreateContextVariable
        UpdateContextVariable
        DeleteContextVariable
        ListApplications
        CreateApplication
        GetApplication
        UpdateApplication
        DeleteApplication
        ListApplicationBuilds
        CreateApplicationBuild
        GetApplicationBuild
        GetApplicationBuildDiff
        ListApplicationDeployments
        CreateApplicationDeployment
        GetApplicationDeployment
        UpdateApplicationDeployment
        DeleteApplicationDeployment
        GetDownload
        CreateGuardrail
        GetGuardrail
        UpdateGuardrail
        DeleteGuardrail
        TestGuardrail
        ListGuardrails
        ListGuardrailEvents
        GetConversation
        ListConversations
        ListModalities
        CreateModality
        GetModality
        UpdateModality
        DeleteModality
        ListSlotTypes
        CreateSlotType
        GetSlotType
        UpdateSlotType
        DeleteSlotType
        ListDataRequests
        CreateDataRequest
        GetDataRequest
        UpdateDataRequest
        DeleteDataRequest
        CreateAnalyticsTag
        ListAnalyticsTags
        UpdateAnalyticsTag
        DeleteAnalyticsTag
        StartTrailQuery
        GetTrailQueryResults
        ListResourceVersions
        GetResourceVersion
        QueryLogs
        ListFlows
        CreateFlow
        GetFlow
        UpdateFlow
        DeleteFlow
        ListLiveSyncScripts
        CreateLiveSyncScript
        GetLiveSyncScript
        UpdateLiveSyncScript
        DeleteLiveSyncScript
        ListLiveSyncScriptBuilds
        CreateLiveSyncScriptBuild
        GetLiveSyncScriptBuild
        ListLiveSyncScriptDeployments
        CreateLiveSyncScriptDeployment
        GetLiveSyncScriptDeployment
        UpdateLiveSyncScriptDeployment
        DeleteLiveSyncScriptDeployment
        ListKnowledgeBases
        CreateKnowledgeBase
        GetKnowledgeBase
        UpdateKnowledgeBase
        DeleteKnowledgeBase
        CloneKnowledgeBase
        PublishKnowledgeBase
        GetKnowledgeBasePublication
        ListKnowledgeBasePublications
        ListKnowledgeBaseArticles
        CreateKnowledgeBaseArticle
        GetKnowledgeBaseArticle
        UpdateKnowledgeBaseArticle
        DeleteKnowledgeBaseArticle
        ListKnowledgeBaseDocuments
        GetKnowledgeBaseDocument
        PutKnowledgeBaseDocument
        DeleteKnowledgeBaseDocument
        CreateApiToken
        ListApiTokens
        DeleteApiToken
        CreateProgrammaticUser
        ListProgrammaticUsers
        GetProgrammaticUser
        UpdateProgrammaticUser
        DeleteProgrammaticUser
        ListUsers
        CreateUser
        GetUser
        UpdateUser
        DeleteUser
        ListRoles
        CreateRole
        GetRole
        UpdateRole
        DeleteRole
        GetRolePermissions
        GetTeam
        ListWorkspaces
        CreateWorkspace
        GetWorkspace
        UpdateWorkspace
        DeleteWorkspace
    ]
    errors: [
        ValidationException
        ResourceNotFoundException
        ConflictException
        InternalServerException
        ThrottlingException
    ]
}

// --- Common Error Shapes ---
@error("client")
@httpError(400)
structure ValidationException {
    @required
    message: String

    fieldList: ValidationExceptionFieldList
}

list ValidationExceptionFieldList {
    member: ValidationExceptionField
}

structure ValidationExceptionField {
    @required
    name: String

    @required
    message: String
}

@error("client")
@httpError(404)
structure ResourceNotFoundException {
    @required
    message: String

    resourceId: String

    resourceType: String
}

@error("client")
@httpError(409)
structure ConflictException {
    @required
    message: String

    resourceId: String

    resourceType: String
}

@error("server")
@httpError(500)
@retryable
structure InternalServerException {
    @required
    message: String

    retryAfterSeconds: Integer
}

@error("client")
@httpError(429)
@retryable(throttling: true)
structure ThrottlingException {
    @required
    message: String

    retryAfterSeconds: Integer
}
