
--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

with VSS.JSON.Content_Handlers;

package Ollama_API.Types.Outputs is

   procedure Output_ChatMessage_role
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatMessage_role);

   procedure Output_ChatRequest_think
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatRequest_think);

   procedure Output_GenerateRequest_think
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateRequest_think);

   procedure Output_ChatStreamEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatStreamEvent);

   procedure Output_ToolCall
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ToolCall);

   procedure Output_ChatMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatMessage);

   procedure Output_VersionResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : VersionResponse);

   procedure Output_ListResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ListResponse);

   procedure Output_ToolDefinition
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ToolDefinition);

   procedure Output_ChatResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatResponse);

   procedure Output_DeleteRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : DeleteRequest);

   procedure Output_PsResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PsResponse);

   procedure Output_EmbedResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : EmbedResponse);

   procedure Output_GenerateStreamEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateStreamEvent);

   procedure Output_ShowResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ShowResponse);

   procedure Output_CopyRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CopyRequest);

   procedure Output_WebFetchRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebFetchRequest);

   procedure Output_StatusEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : StatusEvent);

   procedure Output_ModelOptions
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelOptions);

   procedure Output_WebSearchResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchResponse);

   procedure Output_WebSearchResult
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchResult);

   procedure Output_EmbedRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : EmbedRequest);

   procedure Output_TokenLogprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : TokenLogprob);

   procedure Output_ModelSummary
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelSummary);

   procedure Output_ErrorResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ErrorResponse);

   procedure Output_WebSearchRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchRequest);

   procedure Output_CreateRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateRequest);

   procedure Output_ChatRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatRequest);

   procedure Output_GenerateResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateResponse);

   procedure Output_ShowRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ShowRequest);

   procedure Output_Logprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Logprob);

   procedure Output_WebFetchResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebFetchResponse);

   procedure Output_Ps
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Ps);

   procedure Output_StatusResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : StatusResponse);

   procedure Output_PushRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PushRequest);

   procedure Output_PullRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PullRequest);

   procedure Output_GenerateRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateRequest);

end Ollama_API.Types.Outputs;
