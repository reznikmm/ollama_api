--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

with VSS.JSON.Pull_Readers;

package Ollama_API.Types.Inputs is

   procedure Input_ChatMessage_role
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatMessage_role;
      Success : in out Boolean);

   procedure Input_ChatRequest_think
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatRequest_think;
      Success : in out Boolean);

   procedure Input_GenerateRequest_think
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateRequest_think;
      Success : in out Boolean);

   procedure Input_ChatStreamEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatStreamEvent;
      Success : in out Boolean);

   procedure Input_ToolCall
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ToolCall;
      Success : in out Boolean);

   procedure Input_ChatMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatMessage;
      Success : in out Boolean);

   procedure Input_VersionResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out VersionResponse;
      Success : in out Boolean);

   procedure Input_ListResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ListResponse;
      Success : in out Boolean);

   procedure Input_ToolDefinition
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ToolDefinition;
      Success : in out Boolean);

   procedure Input_ChatResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatResponse;
      Success : in out Boolean);

   procedure Input_DeleteRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out DeleteRequest;
      Success : in out Boolean);

   procedure Input_PsResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PsResponse;
      Success : in out Boolean);

   procedure Input_EmbedResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out EmbedResponse;
      Success : in out Boolean);

   procedure Input_GenerateStreamEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateStreamEvent;
      Success : in out Boolean);

   procedure Input_ShowResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ShowResponse;
      Success : in out Boolean);

   procedure Input_CopyRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CopyRequest;
      Success : in out Boolean);

   procedure Input_WebFetchRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebFetchRequest;
      Success : in out Boolean);

   procedure Input_StatusEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out StatusEvent;
      Success : in out Boolean);

   procedure Input_ModelOptions
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelOptions;
      Success : in out Boolean);

   procedure Input_WebSearchResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchResponse;
      Success : in out Boolean);

   procedure Input_WebSearchResult
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchResult;
      Success : in out Boolean);

   procedure Input_EmbedRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out EmbedRequest;
      Success : in out Boolean);

   procedure Input_TokenLogprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out TokenLogprob;
      Success : in out Boolean);

   procedure Input_ModelSummary
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelSummary;
      Success : in out Boolean);

   procedure Input_ErrorResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ErrorResponse;
      Success : in out Boolean);

   procedure Input_WebSearchRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchRequest;
      Success : in out Boolean);

   procedure Input_CreateRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateRequest;
      Success : in out Boolean);

   procedure Input_ChatRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatRequest;
      Success : in out Boolean);

   procedure Input_GenerateResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateResponse;
      Success : in out Boolean);

   procedure Input_ShowRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ShowRequest;
      Success : in out Boolean);

   procedure Input_Logprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Logprob;
      Success : in out Boolean);

   procedure Input_WebFetchResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebFetchResponse;
      Success : in out Boolean);

   procedure Input_Ps
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Ps;
      Success : in out Boolean);

   procedure Input_StatusResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out StatusResponse;
      Success : in out Boolean);

   procedure Input_PushRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PushRequest;
      Success : in out Boolean);

   procedure Input_PullRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PullRequest;
      Success : in out Boolean);

   procedure Input_GenerateRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateRequest;
      Success : in out Boolean);

end Ollama_API.Types.Inputs;
