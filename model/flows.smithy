// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
$version: "2"

namespace com.amazon.connect.acxd.sdk

// ============================================================================
// Operations — Flows
// ============================================================================
/// Lists all flows for the workspace, paginated.
@http(method: "GET", uri: "/sdk/flows")
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "maxResults")
operation ListFlows {
    input: ListFlowsRequest
    output: ListFlowsResponse
    errors: [
        ValidationException
        InternalServerException
        ThrottlingException
    ]
}

/// Creates a new flow.
@http(method: "POST", uri: "/sdk/flows", code: 201)
operation CreateFlow {
    input: CreateFlowRequest
    output: Flow
    errors: [
        ValidationException
        ConflictException
        InternalServerException
        ThrottlingException
    ]
}

/// Retrieves a single flow by ID.
@http(method: "GET", uri: "/sdk/flows/{flowIdentifier}")
@readonly
operation GetFlow {
    input: GetFlowRequest
    output: Flow
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

/// Updates an existing flow.
@http(method: "PATCH", uri: "/sdk/flows/{flowIdentifier}")
@idempotent
operation UpdateFlow {
    input: UpdateFlowRequest
    output: Flow
    errors: [
        ValidationException
        ResourceNotFoundException
        ConflictException
        InternalServerException
        ThrottlingException
    ]
}

/// Deletes a flow by ID.
@http(method: "DELETE", uri: "/sdk/flows/{flowIdentifier}", code: 204)
@idempotent
operation DeleteFlow {
    input: DeleteFlowRequest
    errors: [
        ValidationException
        ResourceNotFoundException
        InternalServerException
        ThrottlingException
    ]
}

// ============================================================================
// Custom Types — Flows
// ============================================================================
@pattern("^[A-Za-z]+$")
@length(min: 3, max: 64)
string FlowId

@pattern("^[ -~]*$")
@length(max: 200)
string FlowDescription

@pattern("^[ -~]*$")
@length(max: 1000)
string FlowAiDescription

enum FlowNodeType {
    BASIC = "basic"
    APPLICATION_HANDOFF = "application_handoff"
    CHOICE = "choice"
    DATA_REQUEST = "data_request"
    END = "end"
    ESCALATE = "escalate"
    GENERATIVE_TEXT = "generative_text"
    GENERATIVE_TASK = "generative_task"
    GENERATIVE_JOURNEY = "generative_journey"
    INTENT_CAPTURE = "intent_capture"
    LOOP = "loop"
    MULTIMODAL = "multimodal"
    REDIRECT = "redirect"
    SPLIT = "split"
    START = "start"
    NOTE = "note"
    USER_CHOICE = "user_choice"
    USER_INPUT = "user_input"
    KNOWLEDGE_BASE = "knowledge_base"
    DEFINE = "define"
    WAIT = "wait"
    TRANSFORM = "transform"
}

enum ConditionOperator {
    EXISTS = "exists"
    NOT_EXISTS = "not_exists"
    EQ = "eq"
    NEQ = "neq"
    LT = "lt"
    LTE = "lte"
    GT = "gt"
    GTE = "gte"
    PREFIX = "prefix"
    SUFFIX = "suffix"
    CONTAINS = "contains"
    NOT_CONTAINS = "not_contains"
    MATCHES_REGEX = "matches_regex"
    SIMILAR = "similar"
}

enum ChoiceSource {
    DATA_REQUEST = "dataRequest"
    SLOT_TYPE = "slotType"
    LOCAL = "local"
    CONTEXT = "context"
}

enum ChoiceDisplayFormat {
    DEFAULT = "default"
    DROPDOWN = "dropdown"
}

enum GroundingType {
    WEB = "web"
    DATASTORE = "datastore"
    NONE = "none"
}

enum GenerativeJourneyModalityTriggerType {
    MCP_FLOW = "mcpFlow"
    DATA_REQUEST = "dataRequest"
    KNOWLEDGE_BASE = "knowledgeBase"
}

structure GenerativeJourneyModalityTrigger {
    type: GenerativeJourneyModalityTriggerType
    variableId: String
    action: String
    provider: String
    flowId: FlowId
    knowledgeBaseId: String
}

list GenerativeJourneyModalityTriggerList {
    member: GenerativeJourneyModalityTrigger
}

enum GenerativeJourneyToolType {
    MCP_FLOW = "mcpFlow"
    DATA_REQUEST = "dataRequest"
    FLOW = "flow"
    KNOWLEDGE_BASE = "knowledgeBase"
    MODALITY = "modality"
}

enum MultimodalActionType {
    NAVIGATION = "navigation"
    FORM_FILL = "formFill"
    CUSTOM = "custom"
}

enum MultimodalType {
    SCRIPTED = "scripted"
    INTERACTIVE = "interactive"
    AGENTIC = "agentic"
}

enum RedirectType {
    FLOW = "flow"
    PAGE = "page"
    PARENT_APPLICATION = "parent_application"
}

enum LoopType {
    RANGE = "range"
    LIST = "list"
}

enum GenerativeModelType {
    AMAZON_NOVA_MICRO = "amazon-nova-micro"
    AMAZON_NOVA_2_LITE = "amazon-nova-2-lite"
    ANTHROPIC_HAIKU_4_5 = "anthropic.claude-haiku-4-5"
    ANTHROPIC_SONNET_5 = "anthropic.claude-sonnet-5"
}

enum FlowStateModificationType {
    CONTEXT = "context"
    SLOT = "slot"
    LOCAL = "local"
    VARIABLE = "variable"
    VARIABLE_SELECTION = "variable_selection"
    SYSTEM = "system"
}

enum FlowStateModificationAction {
    CLEAR = "clear"
    SET = "set"
    INCREMENT = "increment"
    DECREMENT = "decrement"
    PUSH = "push"
    POP = "pop"
    CUSTOM = "custom"
    SHIFT = "shift"
}

// ============================================================================
// Request/Response Structures
// ============================================================================
structure ListFlowsRequest {
    @httpQuery("nextToken")
    nextToken: String

    @httpQuery("maxResults")
    @range(min: 1, max: 500)
    maxResults: Integer
}

structure ListFlowsResponse {
    @required
    items: FlowSummaryList

    nextToken: String
}

structure CreateFlowRequest {
    @required
    flowId: FlowId

    description: FlowDescription

    aiDescription: FlowAiDescription

    untrained: Boolean

    mainLanguageCode: LanguageCode

    languageCode: LanguageCode

    languageCodes: LanguageCodeList

    slotTypes: AttachedSlotList

    contextVariables: FlowContextVariableList

    mcp: McpConfig

    metadata: FlowMetadata

    @required
    nodes: FlowNodeMap
}

structure GetFlowRequest {
    @required
    @httpLabel
    flowIdentifier: FlowId

    @httpQuery("languageCode")
    languageCode: LanguageCode
}

structure UpdateFlowRequest {
    @required
    @httpLabel
    flowIdentifier: FlowId

    utterances: UtteranceList

    nodes: FlowNodeMap

    description: FlowDescription

    aiDescription: FlowAiDescription

    untrained: Boolean

    mainLanguageCode: LanguageCode

    languageCode: LanguageCode

    languageCodes: LanguageCodeList

    slotTypes: AttachedSlotList

    contextVariables: FlowContextVariableList

    mcp: McpConfig

    metadata: FlowMetadata
}

structure DeleteFlowRequest {
    @required
    @httpLabel
    flowIdentifier: FlowId
}

// ============================================================================
// Resource Shapes
// ============================================================================
structure Flow {
    @required
    flowId: FlowId

    description: FlowDescription

    aiDescription: FlowAiDescription

    untrained: Boolean

    mainLanguageCode: LanguageCode

    languageCode: LanguageCode

    languageCodes: LanguageCodeList

    utterances: UtteranceList

    slotTypes: AttachedSlotList

    contextVariables: FlowContextVariableList

    mcp: McpConfig

    metadata: FlowMetadata

    nodes: FlowNodeMap

    saveId: String

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

structure FlowMetadata {
    tags: FlowTagList
    path: String
}

// ============================================================================
// Flow Core Structures
// ============================================================================
structure Utterance {
    @required
    @length(min: 2, max: 128)
    text: String

    @length(min: 2)
    valueId: String

    skipTraining: Boolean

    skipTranslation: Boolean

    translated: Boolean
}

structure AttachedSlot {
    @required
    @pattern("^[A-Za-z]+$")
    @length(min: 3, max: 30)
    name: String

    @required
    type: String

    sensitive: Boolean

    examples: SlotExampleList

    aiDescription: FlowAiDescription

    @length(max: 300)
    regex: String
}

structure FlowContextVariable {
    name: String
    type: FlowContextVariableType
}

enum FlowContextVariableType {
    TEXT = "text"
    NUMBER = "number"
    BOOLEAN = "boolean"
}

structure McpConfig {
    input: McpEndpoint
    output: McpEndpoint
}

structure McpEndpoint {
    name: String
    schema: Document
}

// ============================================================================
// Node Structures
// ============================================================================
map FlowNodeMap {
    key: UUIDv4
    value: FlowNode
}

structure FlowNode {
    @required
    nodeId: UUIDv4

    @required
    type: FlowNodeType

    childNodes: ChildNodeList

    dataRequests: NodeDataRequestList

    messages: MessageList

    modalities: Document

    canvasMetadata: CanvasMetadata

    metadata: FlowNodeMetadata
}

structure ChildNode {
    nodeId: UUIDv4
    name: String
    conditions: ConditionList
    generativeCondition: GenerativeCondition
}

structure GenerativeCondition {
    prompt: String
}

structure Condition {
    conditionId: String

    @required
    left: Operand

    right: Operand

    @required
    operator: ConditionOperator
}

structure CanvasMetadata {
    x: Double
    y: Double
    width: Double
    height: Double
    isMinimized: Boolean
    color: String
    pageId: String
    pageName: String
    pageIndex: Integer
}

structure FlowNodeMetadata {
    payload: Document

    nodePayload: Operand

    flowId: FlowId

    applicationHandoff: ApplicationHandoffConfig

    code: CodeConfig

    choice: ChoiceConfig

    define: DefineConfig

    generativeText: GenerativeTextConfig

    generativeJourney: GenerativeJourneyConfig

    agenticTask: AgenticTaskConfig

    knowledgeBase: KnowledgeBaseNodeConfig

    loop: LoopConfig

    multimodal: MultimodalConfig

    note: NoteConfig

    redirect: RedirectConfig

    transform: TransformConfig

    tags: NodeAnalyticsTagList

    name: String

    interimMessages: InterimMessageList

    stateModifications: FlowStateModificationList

    sendContext: Boolean

    @range(max: 30000)
    timeout: Integer

    enableInProgressEdge: Boolean
}

structure NodeAnalyticsTag {
    label: String
}

structure FlowStateModification {
    type: FlowStateModificationType
    name: String
    modification: FlowStateModificationAction
    functionName: String
    value: Operand
}

structure NodeDataRequest {
    dataRequestId: String
    urlParams: Document
    headers: Document
    payload: Document
    alwaysRetrigger: Boolean
    name: String
    provider: String
    action: String
}

// ============================================================================
// Node Metadata Sub-Configs
// ============================================================================
structure ApplicationHandoffConfig {
    applicationId: String
    flowId: FlowId
    channelId: String
    channelType: String
    deploymentStage: DeploymentStage
}

enum DeploymentStage {
    STAGING = "staging"
    PRODUCTION = "production"
}

structure CodeConfig {
    code: String
    name: String
    input: Operand
    outputSchema: Document
    outputSchemaId: Document
    timeout: Integer
}

structure ChoiceConfig {
    source: ChoiceSource
    dataRequestId: String
    slotTypeId: String
    localId: String
    contextVariableKey: String
    selectedChoiceLabel: String
    showChoices: Boolean
    disableSingleChoiceAutotraverse: Boolean
    choiceDisplayFormat: ChoiceDisplayFormat
    associatedSlotTypeIds: FlowStringList
    idField: String
    labelField: String
}

structure DefineConfig {
    name: String
    schema: Document
    schemaId: Document
    value: Operand
}

structure GenerativeTextConfig {
    name: String

    prompt: String

    includeTranscript: Boolean

    groundingType: GroundingType

    timeout: Integer

    autoTranslate: Boolean

    @range(min: 0, max: 2)
    temperature: Double

    maxTokens: Integer
}

structure GenerativeJourneyConfig {
    tools: GenerativeJourneyToolList

    dataCapture: DataCaptureConfig

    prompt: String

    modelType: GenerativeModelType

    exitConditions: ExitConditionList

    enableZeroTurnMode: Boolean

    maxTokens: Integer

    maxSteps: Integer

    @range(min: 0, max: 2)
    temperature: Double

    timeout: Integer
}

structure GenerativeJourneyTool {
    type: GenerativeJourneyToolType
    interimMessages: InterimMessageList
    dataRequest: NodeDataRequest
    flowId: FlowId
    triggers: GenerativeJourneyModalityTriggerList
    scopeTags: FlowStringList
    knowledgeBaseId: String
    modalityId: String
    prompt: String
    payload: Document
}

structure DataCaptureConfig {
    data: CapturedDataList
    prompt: String
    exitEnabled: Boolean
}

structure CapturedData {
    name: String
    type: CapturedDataType
    required: Boolean
    schema: Document
}

enum CapturedDataType {
    LOCAL = "local"
    SLOT = "slot"
}

structure ExitCondition {
    name: String
    prompt: String
}

structure AgenticTaskConfig {
    prompt: String
    exitCondition: String
    enableZeroTurnMode: Boolean
    includeTranscript: Boolean
    variableIds: FlowStringList
    timeout: Integer
}

structure KnowledgeBaseNodeConfig {
    name: String

    @required
    knowledgeBaseId: String

    prompt: String

    question: String

    includeCitation: Boolean

    timeout: Integer

    minConfidenceScore: Double

    brandId: String

    filters: Document
}

structure LoopConfig {
    type: LoopType
    start: Integer
    end: Integer
    localId: String
    variableId: String
    name: String
}

structure MultimodalConfig {
    modelType: GenerativeModelType

    actions: MultimodalActionList

    exitConditions: ExitConditionList

    scopeTagColors: Document

    automatedTags: NodeAnalyticsTagList

    bidirectionalMode: Boolean

    scopeTags: FlowStringList

    @range(max: 1200000)
    inactivityTimeout: Integer

    knowledgeBaseId: String

    @range(min: 1, max: 65536)
    maxTokens: Integer

    @range(min: 1, max: 20)
    maxSteps: Integer

    @range(min: 0, max: 1)
    temperature: Double

    piiMode: Boolean

    prompt: String

    @range(min: 5000, max: 120000)
    sessionStartTimeout: Integer

    smallTalk: Boolean

    tools: GenerativeJourneyToolList

    dataCapture: DataCaptureConfig

    type: MultimodalType
}

structure MultimodalAction {
    @required
    type: MultimodalActionType

    name: String

    prompt: String

    inputSchema: Document

    inputSchemaId: Document

    outputSchema: Document

    outputSchemaId: Document

    schema: Document

    scopeTags: FlowStringList
}

structure NoteConfig {
    titleImage: String
    body: String
}

structure RedirectConfig {
    @required
    type: RedirectType

    flowId: FlowId

    nodeId: UUIDv4

    pageName: String
}

structure TransformConfig {
    input: Operand
    name: String
    transformations: TransformationList
}

structure Transformation {
    type: String
    prompt: String
    field: Operand
    sortOrder: String
    outputSchema: Document
    outputSchemaId: Document
    filters: Document
}

// ============================================================================
// Lists
// ============================================================================
list FlowSummaryList {
    member: FlowSummary
}

structure FlowSummary {
    @required
    flowId: FlowId

    description: FlowDescription

    aiDescription: FlowAiDescription

    untrained: Boolean

    mainLanguageCode: LanguageCode

    languageCode: LanguageCode

    languageCodes: LanguageCodeList

    metadata: FlowMetadata

    saveId: String

    createdAt: DateTime

    updatedAt: DateTime

    updatedBy: String
}

@length(max: 5)
list FlowTagList {
    member: String
}

list UtteranceList {
    member: Utterance
}

@length(max: 100)
list AttachedSlotList {
    member: AttachedSlot
}

list SlotExampleList {
    member: String
}

list FlowContextVariableList {
    member: FlowContextVariable
}

list ChildNodeList {
    member: ChildNode
}

list ConditionList {
    member: Condition
}

list NodeAnalyticsTagList {
    member: NodeAnalyticsTag
}

list FlowStateModificationList {
    member: FlowStateModification
}

@length(max: 10)
list NodeDataRequestList {
    member: NodeDataRequest
}

list GenerativeJourneyToolList {
    member: GenerativeJourneyTool
}

list CapturedDataList {
    member: CapturedData
}

list ExitConditionList {
    member: ExitCondition
}

list MultimodalActionList {
    member: MultimodalAction
}

list TransformationList {
    member: Transformation
}

list FlowStringList {
    member: String
}
