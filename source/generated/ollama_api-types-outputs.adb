--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

package body Ollama_API.Types.Outputs is
   pragma Style_Checks (Off);
   procedure Output_Any_Value
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Any_Value'Class) is
   begin
      for Item of Value loop
         case Item.Kind is
            when VSS.JSON.Streams.Start_Array    =>
               Handler.Start_Array;

            when VSS.JSON.Streams.End_Array      =>
               Handler.End_Array;

            when VSS.JSON.Streams.Start_Object   =>
               Handler.Start_Object;

            when VSS.JSON.Streams.End_Object     =>
               Handler.End_Object;

            when VSS.JSON.Streams.Key_Name       =>
               Handler.Key_Name (Item.Key_Name);

            when VSS.JSON.Streams.String_Value   =>
               Handler.String_Value (Item.String_Value);

            when VSS.JSON.Streams.Number_Value   =>
               Handler.Number_Value (Item.Number_Value);

            when VSS.JSON.Streams.Boolean_Value  =>
               Handler.Boolean_Value (Item.Boolean_Value);

            when VSS.JSON.Streams.Null_Value     =>
               Handler.Null_Value;

            when VSS.JSON.Streams.None           =>
               null;

            when VSS.JSON.Streams.Invalid        =>
               raise Program_Error;

            when VSS.JSON.Streams.Start_Document =>
               raise Program_Error;

            when VSS.JSON.Streams.End_Document   =>
               raise Program_Error;

            when VSS.JSON.Streams.Comment        =>
               raise Program_Error;
         end case;
      end loop;
   end Output_Any_Value;

   procedure Output_ChatMessage_role
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatMessage_role) is
   begin
      case Value is
         when system    =>
            Handler.String_Value ("system");

         when user      =>
            Handler.String_Value ("user");

         when assistant =>
            Handler.String_Value ("assistant");

         when tool      =>
            Handler.String_Value ("tool");
      end case;
   end Output_ChatMessage_role;

   procedure Output_ChatRequest_think
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatRequest_think) is
   begin
      case Value is
         when high   =>
            Handler.String_Value ("high");

         when medium =>
            Handler.String_Value ("medium");

         when low    =>
            Handler.String_Value ("low");
      end case;
   end Output_ChatRequest_think;

   procedure Output_GenerateRequest_think
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateRequest_think) is
   begin
      case Value is
         when high   =>
            Handler.String_Value ("high");

         when medium =>
            Handler.String_Value ("medium");

         when low    =>
            Handler.String_Value ("low");
      end case;
   end Output_GenerateRequest_think;

   procedure Output_ChatStreamEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatStreamEvent)
   is
      procedure Output_ChatStreamEvent_message
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ChatStreamEvent_message) is
      begin
         Handler.Start_Object;
         if not Value.role.Is_Null then
            Handler.Key_Name ("role");
            Handler.String_Value (Value.role);
         end if;
         if not Value.content.Is_Null then
            Handler.Key_Name ("content");
            Handler.String_Value (Value.content);
         end if;
         if not Value.thinking.Is_Null then
            Handler.Key_Name ("thinking");
            Handler.String_Value (Value.thinking);
         end if;
         if not Value.tool_calls.Is_Null then
            Handler.Key_Name ("tool_calls");
            Handler.Start_Array;
            for J in 1 .. Value.tool_calls.Length loop
               Output_ToolCall (Handler, Value.tool_calls (J));
            end loop;
            Handler.End_Array;
         end if;
         if not Value.images.Is_Empty then
            Handler.Key_Name ("images");
            Handler.Start_Array;
            for J in 1 .. Value.images.Length loop
               Handler.String_Value (Value.images (J));
            end loop;
            Handler.End_Array;
         end if;
         Handler.End_Object;
      end Output_ChatStreamEvent_message;

   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if not Value.created_at.Is_Null then
         Handler.Key_Name ("created_at");
         Handler.String_Value (Value.created_at);
      end if;
      if Value.message.Is_Set then
         Handler.Key_Name ("message");
         Output_ChatStreamEvent_message (Handler, Value.message.Value);
      end if;
      if Value.done then
         Handler.Key_Name ("done");
         Handler.Boolean_Value (Value.done);
      end if;
      Handler.End_Object;
   end Output_ChatStreamEvent;

   procedure Output_ToolCall
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ToolCall)
   is
      procedure Output_ToolCall_function
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ToolCall_function) is
      begin
         Handler.Start_Object;
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
         if not Value.description.Is_Null then
            Handler.Key_Name ("description");
            Handler.String_Value (Value.description);
         end if;
         if not Value.arguments.Is_Empty then
            Handler.Key_Name ("arguments");
            Output_Any_Value (Handler, Value.arguments);
         end if;
         Handler.End_Object;
      end Output_ToolCall_function;

   begin
      Handler.Start_Object;
      if not Value.id.Is_Null then
         Handler.Key_Name ("id");
         Handler.String_Value (Value.id);
      end if;
      if Value.a_function.Is_Set then
         Handler.Key_Name ("function");
         Output_ToolCall_function (Handler, Value.a_function.Value);
      end if;
      Handler.End_Object;
   end Output_ToolCall;

   procedure Output_ChatMessage
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatMessage) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("role");
      Output_ChatMessage_role (Handler, Value.role);
      Handler.Key_Name ("content");
      Handler.String_Value (Value.content);
      if not Value.images.Is_Empty then
         Handler.Key_Name ("images");
         Handler.Start_Array;
         for J in 1 .. Value.images.Length loop
            Handler.String_Value (Value.images (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.tool_calls.Is_Null then
         Handler.Key_Name ("tool_calls");
         Handler.Start_Array;
         for J in 1 .. Value.tool_calls.Length loop
            Output_ToolCall (Handler, Value.tool_calls (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.tool_name.Is_Null then
         Handler.Key_Name ("tool_name");
         Handler.String_Value (Value.tool_name);
      end if;
      if not Value.tool_call_id.Is_Null then
         Handler.Key_Name ("tool_call_id");
         Handler.String_Value (Value.tool_call_id);
      end if;
      Handler.End_Object;
   end Output_ChatMessage;

   procedure Output_VersionResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : VersionResponse) is
   begin
      Handler.Start_Object;
      if not Value.version.Is_Null then
         Handler.Key_Name ("version");
         Handler.String_Value (Value.version);
      end if;
      Handler.End_Object;
   end Output_VersionResponse;

   procedure Output_ListResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ListResponse) is
   begin
      Handler.Start_Object;
      if not Value.models.Is_Null then
         Handler.Key_Name ("models");
         Handler.Start_Array;
         for J in 1 .. Value.models.Length loop
            Output_ModelSummary (Handler, Value.models (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_ListResponse;

   procedure Output_ToolDefinition
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ToolDefinition)
   is
      procedure Output_ToolDefinition_function
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ToolDefinition_function) is
      begin
         Handler.Start_Object;
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
         if not Value.description.Is_Null then
            Handler.Key_Name ("description");
            Handler.String_Value (Value.description);
         end if;
         Handler.Key_Name ("parameters");
         Output_Any_Value (Handler, Value.parameters);
         Handler.End_Object;
      end Output_ToolDefinition_function;

   begin
      Handler.Start_Object;
      Handler.Key_Name ("type");
      Handler.String_Value ("function");
      Handler.Key_Name ("function");
      Output_ToolDefinition_function (Handler, Value.a_function);
      Handler.End_Object;
   end Output_ToolDefinition;

   procedure Output_ChatResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatResponse)
   is
      procedure Output_ChatResponse_message
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ChatResponse_message) is
      begin
         Handler.Start_Object;
         Handler.Key_Name ("role");
         Handler.String_Value ("assistant");
         if not Value.content.Is_Null then
            Handler.Key_Name ("content");
            Handler.String_Value (Value.content);
         end if;
         if not Value.thinking.Is_Null then
            Handler.Key_Name ("thinking");
            Handler.String_Value (Value.thinking);
         end if;
         if not Value.tool_calls.Is_Null then
            Handler.Key_Name ("tool_calls");
            Handler.Start_Array;
            for J in 1 .. Value.tool_calls.Length loop
               Output_ToolCall (Handler, Value.tool_calls (J));
            end loop;
            Handler.End_Array;
         end if;
         if not Value.images.Is_Empty then
            Handler.Key_Name ("images");
            Handler.Start_Array;
            for J in 1 .. Value.images.Length loop
               Handler.String_Value (Value.images (J));
            end loop;
            Handler.End_Array;
         end if;
         Handler.End_Object;
      end Output_ChatResponse_message;

   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if not Value.created_at.Is_Null then
         Handler.Key_Name ("created_at");
         Handler.String_Value (Value.created_at);
      end if;
      if Value.message.Is_Set then
         Handler.Key_Name ("message");
         Output_ChatResponse_message (Handler, Value.message.Value);
      end if;
      if Value.done then
         Handler.Key_Name ("done");
         Handler.Boolean_Value (Value.done);
      end if;
      if not Value.done_reason.Is_Null then
         Handler.Key_Name ("done_reason");
         Handler.String_Value (Value.done_reason);
      end if;
      if Value.total_duration.Is_Set then
         Handler.Key_Name ("total_duration");
         Handler.Integer_Value (Value.total_duration.Value);
      end if;
      if Value.load_duration.Is_Set then
         Handler.Key_Name ("load_duration");
         Handler.Integer_Value (Value.load_duration.Value);
      end if;
      if Value.prompt_eval_count.Is_Set then
         Handler.Key_Name ("prompt_eval_count");
         Handler.Integer_Value (Value.prompt_eval_count.Value);
      end if;
      if Value.prompt_eval_duration.Is_Set then
         Handler.Key_Name ("prompt_eval_duration");
         Handler.Integer_Value (Value.prompt_eval_duration.Value);
      end if;
      if Value.eval_count.Is_Set then
         Handler.Key_Name ("eval_count");
         Handler.Integer_Value (Value.eval_count.Value);
      end if;
      if Value.eval_duration.Is_Set then
         Handler.Key_Name ("eval_duration");
         Handler.Integer_Value (Value.eval_duration.Value);
      end if;
      if not Value.logprobs.Is_Null then
         Handler.Key_Name ("logprobs");
         Handler.Start_Array;
         for J in 1 .. Value.logprobs.Length loop
            Output_Logprob (Handler, Value.logprobs (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_ChatResponse;

   procedure Output_DeleteRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : DeleteRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      Handler.End_Object;
   end Output_DeleteRequest;

   procedure Output_PsResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PsResponse) is
   begin
      Handler.Start_Object;
      if not Value.models.Is_Null then
         Handler.Key_Name ("models");
         Handler.Start_Array;
         for J in 1 .. Value.models.Length loop
            Output_Ps (Handler, Value.models (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_PsResponse;

   procedure Output_EmbedResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : EmbedResponse) is
   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if not Value.embeddings.Is_Null then
         Handler.Key_Name ("embeddings");
         Handler.Start_Array;
         for J in 1 .. Value.embeddings.Length loop
            Handler.Float_Value (Value.embeddings (J));
         end loop;
         Handler.End_Array;
      end if;
      if Value.total_duration.Is_Set then
         Handler.Key_Name ("total_duration");
         Handler.Integer_Value (Value.total_duration.Value);
      end if;
      if Value.load_duration.Is_Set then
         Handler.Key_Name ("load_duration");
         Handler.Integer_Value (Value.load_duration.Value);
      end if;
      if Value.prompt_eval_count.Is_Set then
         Handler.Key_Name ("prompt_eval_count");
         Handler.Integer_Value (Value.prompt_eval_count.Value);
      end if;
      Handler.End_Object;
   end Output_EmbedResponse;

   procedure Output_GenerateStreamEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateStreamEvent) is
   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if not Value.created_at.Is_Null then
         Handler.Key_Name ("created_at");
         Handler.String_Value (Value.created_at);
      end if;
      if not Value.response.Is_Null then
         Handler.Key_Name ("response");
         Handler.String_Value (Value.response);
      end if;
      if not Value.thinking.Is_Null then
         Handler.Key_Name ("thinking");
         Handler.String_Value (Value.thinking);
      end if;
      if Value.done then
         Handler.Key_Name ("done");
         Handler.Boolean_Value (Value.done);
      end if;
      if not Value.done_reason.Is_Null then
         Handler.Key_Name ("done_reason");
         Handler.String_Value (Value.done_reason);
      end if;
      if Value.total_duration.Is_Set then
         Handler.Key_Name ("total_duration");
         Handler.Integer_Value (Value.total_duration.Value);
      end if;
      if Value.load_duration.Is_Set then
         Handler.Key_Name ("load_duration");
         Handler.Integer_Value (Value.load_duration.Value);
      end if;
      if Value.prompt_eval_count.Is_Set then
         Handler.Key_Name ("prompt_eval_count");
         Handler.Integer_Value (Value.prompt_eval_count.Value);
      end if;
      if Value.prompt_eval_duration.Is_Set then
         Handler.Key_Name ("prompt_eval_duration");
         Handler.Integer_Value (Value.prompt_eval_duration.Value);
      end if;
      if Value.eval_count.Is_Set then
         Handler.Key_Name ("eval_count");
         Handler.Integer_Value (Value.eval_count.Value);
      end if;
      if Value.eval_duration.Is_Set then
         Handler.Key_Name ("eval_duration");
         Handler.Integer_Value (Value.eval_duration.Value);
      end if;
      Handler.End_Object;
   end Output_GenerateStreamEvent;

   procedure Output_ShowResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ShowResponse) is
   begin
      Handler.Start_Object;
      if not Value.parameters.Is_Null then
         Handler.Key_Name ("parameters");
         Handler.String_Value (Value.parameters);
      end if;
      if not Value.license.Is_Null then
         Handler.Key_Name ("license");
         Handler.String_Value (Value.license);
      end if;
      if not Value.modified_at.Is_Null then
         Handler.Key_Name ("modified_at");
         Handler.String_Value (Value.modified_at);
      end if;
      if not Value.details.Is_Empty then
         Handler.Key_Name ("details");
         Output_Any_Value (Handler, Value.details);
      end if;
      if not Value.template.Is_Null then
         Handler.Key_Name ("template");
         Handler.String_Value (Value.template);
      end if;
      if not Value.capabilities.Is_Empty then
         Handler.Key_Name ("capabilities");
         Handler.Start_Array;
         for J in 1 .. Value.capabilities.Length loop
            Handler.String_Value (Value.capabilities (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.model_info.Is_Empty then
         Handler.Key_Name ("model_info");
         Output_Any_Value (Handler, Value.model_info);
      end if;
      Handler.End_Object;
   end Output_ShowResponse;

   procedure Output_CopyRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CopyRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("source");
      Handler.String_Value (Value.source);
      Handler.Key_Name ("destination");
      Handler.String_Value (Value.destination);
      Handler.End_Object;
   end Output_CopyRequest;

   procedure Output_WebFetchRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebFetchRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("url");
      Handler.String_Value (Value.url);
      Handler.End_Object;
   end Output_WebFetchRequest;

   procedure Output_StatusEvent
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : StatusEvent) is
   begin
      Handler.Start_Object;
      if not Value.status.Is_Null then
         Handler.Key_Name ("status");
         Handler.String_Value (Value.status);
      end if;
      if not Value.digest.Is_Null then
         Handler.Key_Name ("digest");
         Handler.String_Value (Value.digest);
      end if;
      if Value.total.Is_Set then
         Handler.Key_Name ("total");
         Handler.Integer_Value (Value.total.Value);
      end if;
      if Value.completed.Is_Set then
         Handler.Key_Name ("completed");
         Handler.Integer_Value (Value.completed.Value);
      end if;
      Handler.End_Object;
   end Output_StatusEvent;

   procedure Output_ModelOptions
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelOptions) is
   begin
      Handler.Start_Object;
      if Value.seed.Is_Set then
         Handler.Key_Name ("seed");
         Handler.Integer_Value (Value.seed.Value);
      end if;
      if Value.temperature.Is_Set then
         Handler.Key_Name ("temperature");
         Handler.Float_Value (Value.temperature.Value);
      end if;
      if Value.top_k.Is_Set then
         Handler.Key_Name ("top_k");
         Handler.Integer_Value (Value.top_k.Value);
      end if;
      if Value.top_p.Is_Set then
         Handler.Key_Name ("top_p");
         Handler.Float_Value (Value.top_p.Value);
      end if;
      if Value.min_p.Is_Set then
         Handler.Key_Name ("min_p");
         Handler.Float_Value (Value.min_p.Value);
      end if;
      if not Value.stop.Is_Empty then
         Handler.Key_Name ("stop");
         Handler.Start_Array;
         for J in 1 .. Value.stop.Length loop
            Handler.String_Value (Value.stop (J));
         end loop;
         Handler.End_Array;
      end if;
      if Value.num_ctx.Is_Set then
         Handler.Key_Name ("num_ctx");
         Handler.Integer_Value (Value.num_ctx.Value);
      end if;
      if Value.num_predict.Is_Set then
         Handler.Key_Name ("num_predict");
         Handler.Integer_Value (Value.num_predict.Value);
      end if;
      Handler.End_Object;
   end Output_ModelOptions;

   procedure Output_WebSearchResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchResponse) is
   begin
      Handler.Start_Object;
      if not Value.results.Is_Null then
         Handler.Key_Name ("results");
         Handler.Start_Array;
         for J in 1 .. Value.results.Length loop
            Output_WebSearchResult (Handler, Value.results (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_WebSearchResponse;

   procedure Output_WebSearchResult
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchResult) is
   begin
      Handler.Start_Object;
      if not Value.title.Is_Null then
         Handler.Key_Name ("title");
         Handler.String_Value (Value.title);
      end if;
      if not Value.url.Is_Null then
         Handler.Key_Name ("url");
         Handler.String_Value (Value.url);
      end if;
      if not Value.content.Is_Null then
         Handler.Key_Name ("content");
         Handler.String_Value (Value.content);
      end if;
      Handler.End_Object;
   end Output_WebSearchResult;

   procedure Output_EmbedRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : EmbedRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      Handler.Key_Name ("input");
      Handler.Start_Array;
      for J in 1 .. Value.input.Length loop
         Handler.String_Value (Value.input (J));
      end loop;
      Handler.End_Array;
      if not Value.truncate then
         Handler.Key_Name ("truncate");
         Handler.Boolean_Value (Value.truncate);
      end if;
      if Value.dimensions.Is_Set then
         Handler.Key_Name ("dimensions");
         Handler.Integer_Value (Value.dimensions.Value);
      end if;
      if not Value.keep_alive.Is_Null then
         Handler.Key_Name ("keep_alive");
         Handler.String_Value (Value.keep_alive);
      end if;
      if Value.options.Is_Set then
         Handler.Key_Name ("options");
         Output_ModelOptions (Handler, Value.options.Value);
      end if;
      Handler.End_Object;
   end Output_EmbedRequest;

   procedure Output_TokenLogprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : TokenLogprob) is
   begin
      Handler.Start_Object;
      if not Value.token.Is_Null then
         Handler.Key_Name ("token");
         Handler.String_Value (Value.token);
      end if;
      if Value.logprob.Is_Set then
         Handler.Key_Name ("logprob");
         Handler.Float_Value (Value.logprob.Value);
      end if;
      if not Value.bytes.Is_Null then
         Handler.Key_Name ("bytes");
         Handler.Start_Array;
         for J in 1 .. Value.bytes.Length loop
            Handler.Integer_Value (Value.bytes (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_TokenLogprob;

   procedure Output_ModelSummary
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ModelSummary)
   is
      procedure Output_ModelSummary_details
        (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
         Value   : ModelSummary_details) is
      begin
         Handler.Start_Object;
         if not Value.format.Is_Null then
            Handler.Key_Name ("format");
            Handler.String_Value (Value.format);
         end if;
         if not Value.family.Is_Null then
            Handler.Key_Name ("family");
            Handler.String_Value (Value.family);
         end if;
         if not Value.families.Is_Empty then
            Handler.Key_Name ("families");
            Handler.Start_Array;
            for J in 1 .. Value.families.Length loop
               Handler.String_Value (Value.families (J));
            end loop;
            Handler.End_Array;
         end if;
         if not Value.parameter_size.Is_Null then
            Handler.Key_Name ("parameter_size");
            Handler.String_Value (Value.parameter_size);
         end if;
         if not Value.quantization_level.Is_Null then
            Handler.Key_Name ("quantization_level");
            Handler.String_Value (Value.quantization_level);
         end if;
         Handler.End_Object;
      end Output_ModelSummary_details;

   begin
      Handler.Start_Object;
      if not Value.name.Is_Null then
         Handler.Key_Name ("name");
         Handler.String_Value (Value.name);
      end if;
      if not Value.modified_at.Is_Null then
         Handler.Key_Name ("modified_at");
         Handler.String_Value (Value.modified_at);
      end if;
      if Value.size.Is_Set then
         Handler.Key_Name ("size");
         Handler.Integer_Value (Value.size.Value);
      end if;
      if not Value.digest.Is_Null then
         Handler.Key_Name ("digest");
         Handler.String_Value (Value.digest);
      end if;
      if Value.details.Is_Set then
         Handler.Key_Name ("details");
         Output_ModelSummary_details (Handler, Value.details.Value);
      end if;
      Handler.End_Object;
   end Output_ModelSummary;

   procedure Output_ErrorResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ErrorResponse) is
   begin
      Handler.Start_Object;
      if not Value.error.Is_Null then
         Handler.Key_Name ("error");
         Handler.String_Value (Value.error);
      end if;
      Handler.End_Object;
   end Output_ErrorResponse;

   procedure Output_WebSearchRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebSearchRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("query");
      Handler.String_Value (Value.query);
      if Value.max_results.Is_Set then
         Handler.Key_Name ("max_results");
         Handler.Integer_Value (Value.max_results.Value);
      end if;
      Handler.End_Object;
   end Output_WebSearchRequest;

   procedure Output_CreateRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : CreateRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if not Value.from.Is_Null then
         Handler.Key_Name ("from");
         Handler.String_Value (Value.from);
      end if;
      if not Value.template.Is_Null then
         Handler.Key_Name ("template");
         Handler.String_Value (Value.template);
      end if;
      if not Value.license.Is_Empty then
         Handler.Key_Name ("license");
         Handler.Start_Array;
         for J in 1 .. Value.license.Length loop
            Handler.String_Value (Value.license (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.system.Is_Null then
         Handler.Key_Name ("system");
         Handler.String_Value (Value.system);
      end if;
      if not Value.parameters.Is_Empty then
         Handler.Key_Name ("parameters");
         Output_Any_Value (Handler, Value.parameters);
      end if;
      if not Value.messages.Is_Null then
         Handler.Key_Name ("messages");
         Handler.Start_Array;
         for J in 1 .. Value.messages.Length loop
            Output_ChatMessage (Handler, Value.messages (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.quantize.Is_Null then
         Handler.Key_Name ("quantize");
         Handler.String_Value (Value.quantize);
      end if;
      if not Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      Handler.End_Object;
   end Output_CreateRequest;

   procedure Output_ChatRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ChatRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      Handler.Key_Name ("messages");
      Handler.Start_Array;
      for J in 1 .. Value.messages.Length loop
         Output_ChatMessage (Handler, Value.messages (J));
      end loop;
      Handler.End_Array;
      if not Value.tools.Is_Null then
         Handler.Key_Name ("tools");
         Handler.Start_Array;
         for J in 1 .. Value.tools.Length loop
            Output_ToolDefinition (Handler, Value.tools (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.format.Is_Empty then
         Handler.Key_Name ("format");
         Output_Any_Value (Handler, Value.format);
      end if;
      if Value.options.Is_Set then
         Handler.Key_Name ("options");
         Output_ModelOptions (Handler, Value.options.Value);
      end if;
      if not Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      if Value.think.Is_Set then
         Handler.Key_Name ("think");
         Output_ChatRequest_think (Handler, Value.think.Value);
      end if;
      if not Value.keep_alive.Is_Null then
         Handler.Key_Name ("keep_alive");
         Handler.String_Value (Value.keep_alive);
      end if;
      if Value.logprobs then
         Handler.Key_Name ("logprobs");
         Handler.Boolean_Value (Value.logprobs);
      end if;
      if Value.top_logprobs.Is_Set then
         Handler.Key_Name ("top_logprobs");
         Handler.Integer_Value (Value.top_logprobs.Value);
      end if;
      Handler.End_Object;
   end Output_ChatRequest;

   procedure Output_GenerateResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateResponse) is
   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if not Value.created_at.Is_Null then
         Handler.Key_Name ("created_at");
         Handler.String_Value (Value.created_at);
      end if;
      if not Value.response.Is_Null then
         Handler.Key_Name ("response");
         Handler.String_Value (Value.response);
      end if;
      if not Value.thinking.Is_Null then
         Handler.Key_Name ("thinking");
         Handler.String_Value (Value.thinking);
      end if;
      if Value.done then
         Handler.Key_Name ("done");
         Handler.Boolean_Value (Value.done);
      end if;
      if not Value.done_reason.Is_Null then
         Handler.Key_Name ("done_reason");
         Handler.String_Value (Value.done_reason);
      end if;
      if Value.total_duration.Is_Set then
         Handler.Key_Name ("total_duration");
         Handler.Integer_Value (Value.total_duration.Value);
      end if;
      if Value.load_duration.Is_Set then
         Handler.Key_Name ("load_duration");
         Handler.Integer_Value (Value.load_duration.Value);
      end if;
      if Value.prompt_eval_count.Is_Set then
         Handler.Key_Name ("prompt_eval_count");
         Handler.Integer_Value (Value.prompt_eval_count.Value);
      end if;
      if Value.prompt_eval_duration.Is_Set then
         Handler.Key_Name ("prompt_eval_duration");
         Handler.Integer_Value (Value.prompt_eval_duration.Value);
      end if;
      if Value.eval_count.Is_Set then
         Handler.Key_Name ("eval_count");
         Handler.Integer_Value (Value.eval_count.Value);
      end if;
      if Value.eval_duration.Is_Set then
         Handler.Key_Name ("eval_duration");
         Handler.Integer_Value (Value.eval_duration.Value);
      end if;
      if not Value.logprobs.Is_Null then
         Handler.Key_Name ("logprobs");
         Handler.Start_Array;
         for J in 1 .. Value.logprobs.Length loop
            Output_Logprob (Handler, Value.logprobs (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_GenerateResponse;

   procedure Output_ShowRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : ShowRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if Value.verbose then
         Handler.Key_Name ("verbose");
         Handler.Boolean_Value (Value.verbose);
      end if;
      Handler.End_Object;
   end Output_ShowRequest;

   procedure Output_Logprob
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Logprob) is
   begin
      Handler.Start_Object;
      if not Value.token.Is_Null then
         Handler.Key_Name ("token");
         Handler.String_Value (Value.token);
      end if;
      if Value.logprob.Is_Set then
         Handler.Key_Name ("logprob");
         Handler.Float_Value (Value.logprob.Value);
      end if;
      if not Value.bytes.Is_Null then
         Handler.Key_Name ("bytes");
         Handler.Start_Array;
         for J in 1 .. Value.bytes.Length loop
            Handler.Integer_Value (Value.bytes (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.top_logprobs.Is_Null then
         Handler.Key_Name ("top_logprobs");
         Handler.Start_Array;
         for J in 1 .. Value.top_logprobs.Length loop
            Output_TokenLogprob (Handler, Value.top_logprobs (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_Logprob;

   procedure Output_WebFetchResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : WebFetchResponse) is
   begin
      Handler.Start_Object;
      if not Value.title.Is_Null then
         Handler.Key_Name ("title");
         Handler.String_Value (Value.title);
      end if;
      if not Value.content.Is_Null then
         Handler.Key_Name ("content");
         Handler.String_Value (Value.content);
      end if;
      if not Value.links.Is_Empty then
         Handler.Key_Name ("links");
         Handler.Start_Array;
         for J in 1 .. Value.links.Length loop
            Handler.String_Value (Value.links (J));
         end loop;
         Handler.End_Array;
      end if;
      Handler.End_Object;
   end Output_WebFetchResponse;

   procedure Output_Ps
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : Ps) is
   begin
      Handler.Start_Object;
      if not Value.model.Is_Null then
         Handler.Key_Name ("model");
         Handler.String_Value (Value.model);
      end if;
      if Value.size.Is_Set then
         Handler.Key_Name ("size");
         Handler.Integer_Value (Value.size.Value);
      end if;
      if not Value.digest.Is_Null then
         Handler.Key_Name ("digest");
         Handler.String_Value (Value.digest);
      end if;
      if not Value.details.Is_Empty then
         Handler.Key_Name ("details");
         Output_Any_Value (Handler, Value.details);
      end if;
      if not Value.expires_at.Is_Null then
         Handler.Key_Name ("expires_at");
         Handler.String_Value (Value.expires_at);
      end if;
      if Value.size_vram.Is_Set then
         Handler.Key_Name ("size_vram");
         Handler.Integer_Value (Value.size_vram.Value);
      end if;
      if Value.context_length.Is_Set then
         Handler.Key_Name ("context_length");
         Handler.Integer_Value (Value.context_length.Value);
      end if;
      Handler.End_Object;
   end Output_Ps;

   procedure Output_StatusResponse
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : StatusResponse) is
   begin
      Handler.Start_Object;
      if not Value.status.Is_Null then
         Handler.Key_Name ("status");
         Handler.String_Value (Value.status);
      end if;
      Handler.End_Object;
   end Output_StatusResponse;

   procedure Output_PushRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PushRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if Value.insecure then
         Handler.Key_Name ("insecure");
         Handler.Boolean_Value (Value.insecure);
      end if;
      if not Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      Handler.End_Object;
   end Output_PushRequest;

   procedure Output_PullRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : PullRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if Value.insecure then
         Handler.Key_Name ("insecure");
         Handler.Boolean_Value (Value.insecure);
      end if;
      if not Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      Handler.End_Object;
   end Output_PullRequest;

   procedure Output_GenerateRequest
     (Handler : in out VSS.JSON.Content_Handlers.JSON_Content_Handler'Class;
      Value   : GenerateRequest) is
   begin
      Handler.Start_Object;
      Handler.Key_Name ("model");
      Handler.String_Value (Value.model);
      if not Value.prompt.Is_Null then
         Handler.Key_Name ("prompt");
         Handler.String_Value (Value.prompt);
      end if;
      if not Value.suffix.Is_Null then
         Handler.Key_Name ("suffix");
         Handler.String_Value (Value.suffix);
      end if;
      if not Value.images.Is_Empty then
         Handler.Key_Name ("images");
         Handler.Start_Array;
         for J in 1 .. Value.images.Length loop
            Handler.String_Value (Value.images (J));
         end loop;
         Handler.End_Array;
      end if;
      if not Value.format.Is_Empty then
         Handler.Key_Name ("format");
         Output_Any_Value (Handler, Value.format);
      end if;
      if not Value.system.Is_Null then
         Handler.Key_Name ("system");
         Handler.String_Value (Value.system);
      end if;
      if not Value.stream then
         Handler.Key_Name ("stream");
         Handler.Boolean_Value (Value.stream);
      end if;
      if Value.think.Is_Set then
         Handler.Key_Name ("think");
         Output_GenerateRequest_think (Handler, Value.think.Value);
      end if;
      if Value.raw then
         Handler.Key_Name ("raw");
         Handler.Boolean_Value (Value.raw);
      end if;
      if not Value.keep_alive.Is_Null then
         Handler.Key_Name ("keep_alive");
         Handler.String_Value (Value.keep_alive);
      end if;
      if Value.options.Is_Set then
         Handler.Key_Name ("options");
         Output_ModelOptions (Handler, Value.options.Value);
      end if;
      if Value.logprobs then
         Handler.Key_Name ("logprobs");
         Handler.Boolean_Value (Value.logprobs);
      end if;
      if Value.top_logprobs.Is_Set then
         Handler.Key_Name ("top_logprobs");
         Handler.Integer_Value (Value.top_logprobs.Value);
      end if;
      Handler.End_Object;
   end Output_GenerateRequest;

end Ollama_API.Types.Outputs;
