--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

pragma Ada_2022;
pragma Style_Checks ("M999");  --  suppress style warning unitl gnatpp is fixed
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Finalization;
with Interfaces;
with VSS.JSON.Streams;
with VSS.Strings;
with VSS.String_Vectors;

package Ollama_API.Types is
   subtype Integer_64 is Interfaces.Integer_64;
   subtype Float_64 is Interfaces.IEEE_Float_64;
   package JSON_Event_Lists is new
     Ada.Containers.Doubly_Linked_Lists
       (VSS.JSON.Streams.JSON_Stream_Element,
        VSS.JSON.Streams."=");

   type Any_Value is new JSON_Event_Lists.List with null record;
   type Any_Object is new Any_Value with null record;

   type Optional_Integer_64 (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Integer_64;

         when False =>
            null;
      end case;
   end record;

   type Optional_Float_64 (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Float_64;

         when False =>
            null;
      end case;
   end record;

   type Integer_Or_String (Is_String : Boolean := False) is record
      case Is_String is
         when False =>
            Integer : Integer_64;

         when True =>
            String : VSS.Strings.Virtual_String;
      end case;
   end record;

   type Optional_Integer_Or_String (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Integer_Or_String;

         when False =>
            null;
      end case;
   end record;

   type Logprob_Vector is tagged private
   with
     Variable_Indexing => Get_Logprob_Variable_Reference,
     Constant_Indexing => Get_Logprob_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type TokenLogprob_Vector is tagged private
   with
     Variable_Indexing => Get_TokenLogprob_Variable_Reference,
     Constant_Indexing => Get_TokenLogprob_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type ToolDefinition_Vector is tagged private
   with
     Variable_Indexing => Get_ToolDefinition_Variable_Reference,
     Constant_Indexing => Get_ToolDefinition_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type WebSearchResult_Vector is tagged private
   with
     Variable_Indexing => Get_WebSearchResult_Variable_Reference,
     Constant_Indexing => Get_WebSearchResult_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type Ps_Vector is tagged private
   with
     Variable_Indexing => Get_Ps_Variable_Reference,
     Constant_Indexing => Get_Ps_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type ChatMessage_Vector is tagged private
   with
     Variable_Indexing => Get_ChatMessage_Variable_Reference,
     Constant_Indexing => Get_ChatMessage_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type ToolCall_Vector is tagged private
   with
     Variable_Indexing => Get_ToolCall_Variable_Reference,
     Constant_Indexing => Get_ToolCall_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type Float_64_Vector is tagged private
   with
     Variable_Indexing => Get_Float_64_Variable_Reference,
     Constant_Indexing => Get_Float_64_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type Integer_64_Vector is tagged private
   with
     Variable_Indexing => Get_Integer_64_Variable_Reference,
     Constant_Indexing => Get_Integer_64_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type ModelSummary_Vector is tagged private
   with
     Variable_Indexing => Get_ModelSummary_Variable_Reference,
     Constant_Indexing => Get_ModelSummary_Constant_Reference,
     Aggregate         => (Empty => Empty, Add_Unnamed => Append);

   type ChatMessage_role is (system, user, assistant, tool);

   type ChatRequest_think is (high, medium, low);

   type Optional_ChatRequest_think (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ChatRequest_think;

         when False =>
            null;
      end case;
   end record;

   type GenerateRequest_think is (high, medium, low);

   type Optional_GenerateRequest_think (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : GenerateRequest_think;

         when False =>
            null;
      end case;
   end record;

   type ChatStreamEvent_message is record
      role       : VSS.Strings.Virtual_String;
      --  Role of the message for this chunk
      content    : VSS.Strings.Virtual_String;
      --  Partial assistant message text
      thinking   : VSS.Strings.Virtual_String;
      --  Partial thinking text when `think` is enabled
      tool_calls : ToolCall_Vector;
      --  Partial tool calls, if any
      images     : VSS.String_Vectors.Virtual_String_Vector;
      --  Partial base64-encoded images, when present
   end record;

   type Optional_ChatStreamEvent_message (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ChatStreamEvent_message;

         when False =>
            null;
      end case;
   end record;

   type ChatStreamEvent is record
      model      : VSS.Strings.Virtual_String;
      --  Model name used for this stream event
      created_at : VSS.Strings.Virtual_String;
      --  When this chunk was created (ISO 8601)
      message    : Optional_ChatStreamEvent_message;
      done       : Boolean := Boolean'First;
      --  True for the final event in the stream
   end record;

   type ToolCall_function is record
      name        : VSS.Strings.Virtual_String;
      --  Name of the function to call
      description : VSS.Strings.Virtual_String;
      --  What the function does
      arguments   : Any_Object;
      --  JSON object of arguments to pass to the function
   end record;

   type Optional_ToolCall_function (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ToolCall_function;

         when False =>
            null;
      end case;
   end record;

   type ToolCall is record
      a_function : Optional_ToolCall_function;
   end record;

   type ChatMessage is record
      role       : ChatMessage_role;
      --  Author of the message.
      content    : VSS.Strings.Virtual_String;
      --  Message text content
      images     : VSS.String_Vectors.Virtual_String_Vector;
      --  Optional list of inline images for multimodal models
      tool_calls : ToolCall_Vector;
      --  Tool call requests produced by the model
   end record;

   type VersionResponse is record
      version : VSS.Strings.Virtual_String;
      --  Version of Ollama
   end record;

   type ListResponse is record
      models : ModelSummary_Vector;
   end record;

   type ToolDefinition_function is record
      name        : VSS.Strings.Virtual_String;
      --  Function name exposed to the model
      description : VSS.Strings.Virtual_String;
      --  Human-readable description of the function
      parameters  : Any_Object;
      --  JSON Schema for the function parameters
   end record;

   type ToolDefinition is record
      a_function : ToolDefinition_function;
   end record;

   type ChatResponse_message is record
      content    : VSS.Strings.Virtual_String;
      --  Assistant message text
      thinking   : VSS.Strings.Virtual_String;
      --  Optional deliberate thinking trace when `think` is enabled
      tool_calls : ToolCall_Vector;
      --  Tool calls requested by the assistant
      images     : VSS.String_Vectors.Virtual_String_Vector;
      --  Optional base64-encoded images in the response
   end record;

   type Optional_ChatResponse_message (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ChatResponse_message;

         when False =>
            null;
      end case;
   end record;

   type ChatResponse is record
      model                : VSS.Strings.Virtual_String;
      --  Model name used to generate this message
      created_at           : VSS.Strings.Virtual_String;
      --  Timestamp of response creation (ISO 8601)
      message              : Optional_ChatResponse_message;
      done                 : Boolean := Boolean'First;
      --  Indicates whether the chat response has finished
      done_reason          : VSS.Strings.Virtual_String;
      --  Reason the response finished
      total_duration       : Optional_Integer_64;
      --  Total time spent generating in nanoseconds
      load_duration        : Optional_Integer_64;
      --  Time spent loading the model in nanoseconds
      prompt_eval_count    : Optional_Integer_64;
      --  Number of tokens in the prompt
      prompt_eval_duration : Optional_Integer_64;
      --  Time spent evaluating the prompt in nanoseconds
      eval_count           : Optional_Integer_64;
      --  Number of tokens generated in the response
      eval_duration        : Optional_Integer_64;
      --  Time spent generating tokens in nanoseconds
      logprobs             : Logprob_Vector;
      --  Log probability information for the generated tokens when logprobs are enabled
   end record;

   type DeleteRequest is record
      model : VSS.Strings.Virtual_String;
      --  Model name to delete
   end record;

   type PsResponse is record
      models : Ps_Vector;
      --  Currently running models
   end record;

   type EmbedResponse is record
      model             : VSS.Strings.Virtual_String;
      --  Model that produced the embeddings
      embeddings        : Float_64_Vector;
      --  Array of vector embeddings
      total_duration    : Optional_Integer_64;
      --  Total time spent generating in nanoseconds
      load_duration     : Optional_Integer_64;
      --  Load time in nanoseconds
      prompt_eval_count : Optional_Integer_64;
      --  Number of input tokens processed to generate embeddings
   end record;

   type GenerateStreamEvent is record
      model                : VSS.Strings.Virtual_String;
      --  Model name
      created_at           : VSS.Strings.Virtual_String;
      --  ISO 8601 timestamp of response creation
      response             : VSS.Strings.Virtual_String;
      --  The model's generated text response for this chunk
      thinking             : VSS.Strings.Virtual_String;
      --  The model's generated thinking output for this chunk
      done                 : Boolean := Boolean'First;
      --  Indicates whether the stream has finished
      done_reason          : VSS.Strings.Virtual_String;
      --  Reason streaming finished
      total_duration       : Optional_Integer_64;
      --  Time spent generating the response in nanoseconds
      load_duration        : Optional_Integer_64;
      --  Time spent loading the model in nanoseconds
      prompt_eval_count    : Optional_Integer_64;
      --  Number of input tokens in the prompt
      prompt_eval_duration : Optional_Integer_64;
      --  Time spent evaluating the prompt in nanoseconds
      eval_count           : Optional_Integer_64;
      --  Number of output tokens generated in the response
      eval_duration        : Optional_Integer_64;
      --  Time spent generating tokens in nanoseconds
   end record;

   type ShowResponse is record
      parameters   : VSS.Strings.Virtual_String;
      --  Model parameter settings serialized as text
      license      : VSS.Strings.Virtual_String;
      --  The license of the model
      modified_at  : VSS.Strings.Virtual_String;
      --  Last modified timestamp in ISO 8601 format
      details      : Any_Object;
      --  High-level model details
      template     : VSS.Strings.Virtual_String;
      --  The template used by the model to render prompts
      capabilities : VSS.String_Vectors.Virtual_String_Vector;
      --  List of supported features
      model_info   : Any_Object;
      --  Additional model metadata
   end record;

   type CopyRequest is record
      source      : VSS.Strings.Virtual_String;
      --  Existing model name to copy from
      destination : VSS.Strings.Virtual_String;
      --  New model name to create
   end record;

   type WebFetchRequest is record
      url : VSS.Strings.Virtual_String;
      --  The URL to fetch
   end record;

   type StatusEvent is record
      status    : VSS.Strings.Virtual_String;
      --  Human-readable status message
      digest    : VSS.Strings.Virtual_String;
      --  Content digest associated with the status, if applicable
      total     : Optional_Integer_64;
      --  Total number of bytes expected for the operation
      completed : Optional_Integer_64;
      --  Number of bytes transferred so far
   end record;

   type ModelOptions is record
      seed        : Optional_Integer_64;
      --  Random seed used for reproducible outputs
      temperature : Optional_Float_64;
      --  Controls randomness in generation (higher = more random)
      top_k       : Optional_Integer_64;
      --  Limits next token selection to the K most likely
      top_p       : Optional_Float_64;
      --  Cumulative probability threshold for nucleus sampling
      min_p       : Optional_Float_64;
      --  Minimum probability threshold for token selection
      stop        : VSS.String_Vectors.Virtual_String_Vector;
      --  Stop sequences that will halt generation
      num_ctx     : Optional_Integer_64;
      --  Context length size (number of tokens)
      num_predict : Optional_Integer_64;
      --  Maximum number of tokens to generate
   end record;

   type Optional_ModelOptions (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ModelOptions;

         when False =>
            null;
      end case;
   end record;

   type WebSearchResponse is record
      results : WebSearchResult_Vector;
      --  Array of matching search results
   end record;

   type WebSearchResult is record
      title   : VSS.Strings.Virtual_String;
      --  Page title of the result
      url     : VSS.Strings.Virtual_String;
      --  Resolved URL for the result
      content : VSS.Strings.Virtual_String;
      --  Extracted text content snippet
   end record;

   type EmbedRequest is record
      model      : VSS.Strings.Virtual_String;
      --  Model name
      input      : VSS.String_Vectors.Virtual_String_Vector;
      --  Text or array of texts to generate embeddings for
      truncate   : Boolean := Boolean'Last;
      --  If true, truncate inputs that exceed the context window. If false, returns an error.
      dimensions : Optional_Integer_64;
      --  Number of dimensions to generate embeddings for
      keep_alive : VSS.Strings.Virtual_String;
      --  Model keep-alive duration
      options    : Optional_ModelOptions;
   end record;

   type TokenLogprob is record
      token   : VSS.Strings.Virtual_String;
      --  The text representation of the token
      logprob : Optional_Float_64;
      --  The log probability of this token
      bytes   : Integer_64_Vector;
      --  The raw byte representation of the token
   end record;

   type ModelSummary_details is record
      format             : VSS.Strings.Virtual_String;
      --  Model file format (for example `gguf`)
      family             : VSS.Strings.Virtual_String;
      --  Primary model family (for example `llama`)
      families           : VSS.String_Vectors.Virtual_String_Vector;
      --  All families the model belongs to, when applicable
      parameter_size     : VSS.Strings.Virtual_String;
      --  Approximate parameter count label (for example `7B`, `13B`)
      quantization_level : VSS.Strings.Virtual_String;
      --  Quantization level used (for example `Q4_0`)
   end record;

   type Optional_ModelSummary_details (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : ModelSummary_details;

         when False =>
            null;
      end case;
   end record;

   type ModelSummary is record
      name        : VSS.Strings.Virtual_String;
      --  Model name
      modified_at : VSS.Strings.Virtual_String;
      --  Last modified timestamp in ISO 8601 format
      size        : Optional_Integer_64;
      --  Total size of the model on disk in bytes
      digest      : VSS.Strings.Virtual_String;
      --  SHA256 digest identifier of the model contents
      details     : Optional_ModelSummary_details;
      --  Additional information about the model's format and family
   end record;

   type ErrorResponse is record
      error : VSS.Strings.Virtual_String;
      --  Error message describing what went wrong
   end record;

   type WebSearchRequest is record
      query       : VSS.Strings.Virtual_String;
      --  Search query string
      max_results : Optional_Integer_64;
      --  Maximum number of results to return
   end record;

   type CreateRequest is record
      model      : VSS.Strings.Virtual_String;
      --  Name for the model to create
      from       : VSS.Strings.Virtual_String;
      --  Existing model to create from
      template   : VSS.Strings.Virtual_String;
      --  Prompt template to use for the model
      license    : VSS.String_Vectors.Virtual_String_Vector;
      --  License string or list of licenses for the model
      system     : VSS.Strings.Virtual_String;
      --  System prompt to embed in the model
      parameters : Any_Object;
      --  Key-value parameters for the model
      messages   : ChatMessage_Vector;
      --  Message history to use for the model
      quantize   : VSS.Strings.Virtual_String;
      --  Quantization level to apply (e.g. `q4_K_M`, `q8_0`)
      stream     : Boolean := Boolean'Last;
      --  Stream status updates
   end record;

   type ChatRequest is record
      model        : VSS.Strings.Virtual_String;
      --  Model name
      messages     : ChatMessage_Vector;
      --  Chat history as an array of message objects (each with a role and content)
      tools        : ToolDefinition_Vector;
      --  Optional list of function tools the model may call during the chat
      format       : Any_Object;
      --  Format to return a response in. Can be `json` or a JSON schema
      options      : Optional_ModelOptions;
      stream       : Boolean := Boolean'Last;
      think        : Optional_ChatRequest_think;
      --  When true, returns separate thinking output in addition to content. Can be a boolean (true/false) or a string ("high", "medium", "low") for supported models.
      keep_alive   : VSS.Strings.Virtual_String;
      --  Model keep-alive duration (for example `5m` or `0` to unload immediately)
      logprobs     : Boolean := Boolean'First;
      --  Whether to return log probabilities of the output tokens
      top_logprobs : Optional_Integer_64;
      --  Number of most likely tokens to return at each token position when logprobs are enabled
   end record;

   type GenerateResponse is record
      model                : VSS.Strings.Virtual_String;
      --  Model name
      created_at           : VSS.Strings.Virtual_String;
      --  ISO 8601 timestamp of response creation
      response             : VSS.Strings.Virtual_String;
      --  The model's generated text response
      thinking             : VSS.Strings.Virtual_String;
      --  The model's generated thinking output
      done                 : Boolean := Boolean'First;
      --  Indicates whether generation has finished
      done_reason          : VSS.Strings.Virtual_String;
      --  Reason the generation stopped
      total_duration       : Optional_Integer_64;
      --  Time spent generating the response in nanoseconds
      load_duration        : Optional_Integer_64;
      --  Time spent loading the model in nanoseconds
      prompt_eval_count    : Optional_Integer_64;
      --  Number of input tokens in the prompt
      prompt_eval_duration : Optional_Integer_64;
      --  Time spent evaluating the prompt in nanoseconds
      eval_count           : Optional_Integer_64;
      --  Number of output tokens generated in the response
      eval_duration        : Optional_Integer_64;
      --  Time spent generating tokens in nanoseconds
      logprobs             : Logprob_Vector;
      --  Log probability information for the generated tokens when logprobs are enabled
   end record;

   type ShowRequest is record
      model   : VSS.Strings.Virtual_String;
      --  Model name to show
      verbose : Boolean := Boolean'First;
      --  If true, includes large verbose fields in the response.
   end record;

   type Logprob is record
      token        : VSS.Strings.Virtual_String;
      --  The text representation of the token
      logprob      : Optional_Float_64;
      --  The log probability of this token
      bytes        : Integer_64_Vector;
      --  The raw byte representation of the token
      top_logprobs : TokenLogprob_Vector;
      --  Most likely tokens and their log probabilities at this position
   end record;

   type WebFetchResponse is record
      title   : VSS.Strings.Virtual_String;
      --  Title of the fetched page
      content : VSS.Strings.Virtual_String;
      --  Extracted page content
      links   : VSS.String_Vectors.Virtual_String_Vector;
      --  Links found on the page
   end record;

   type Ps is record
      model          : VSS.Strings.Virtual_String;
      --  Name of the running model
      size           : Optional_Integer_64;
      --  Size of the model in bytes
      digest         : VSS.Strings.Virtual_String;
      --  SHA256 digest of the model
      details        : Any_Object;
      --  Model details such as format and family
      expires_at     : VSS.Strings.Virtual_String;
      --  Time when the model will be unloaded
      size_vram      : Optional_Integer_64;
      --  VRAM usage in bytes
      context_length : Optional_Integer_64;
      --  Context length for the running model
   end record;

   type StatusResponse is record
      status : VSS.Strings.Virtual_String;
      --  Current status message
   end record;

   type PushRequest is record
      model    : VSS.Strings.Virtual_String;
      --  Name of the model to publish
      insecure : Boolean := Boolean'First;
      --  Allow publishing over insecure connections
      stream   : Boolean := Boolean'Last;
      --  Stream progress updates
   end record;

   type PullRequest is record
      model    : VSS.Strings.Virtual_String;
      --  Name of the model to download
      insecure : Boolean := Boolean'First;
      --  Allow downloading over insecure connections
      stream   : Boolean := Boolean'Last;
      --  Stream progress updates
   end record;

   type GenerateRequest is record
      model        : VSS.Strings.Virtual_String;
      --  Model name
      prompt       : VSS.Strings.Virtual_String;
      --  Text for the model to generate a response from
      suffix       : VSS.Strings.Virtual_String;
      --  Used for fill-in-the-middle models, text that appears after the user prompt and before the model response
      images       : VSS.String_Vectors.Virtual_String_Vector;
      format       : Any_Object;
      --  Structured output format for the model to generate a response from. Supports either the string `"json"` or a JSON schema object.
      system       : VSS.Strings.Virtual_String;
      --  System prompt for the model to generate a response from
      stream       : Boolean := Boolean'Last;
      --  When true, returns a stream of partial responses
      think        : Optional_GenerateRequest_think;
      --  When true, returns separate thinking output in addition to content. Can be a boolean (true/false) or a string ("high", "medium", "low") for supported models.
      raw          : Boolean := Boolean'First;
      --  When true, returns the raw response from the model without any prompt templating
      keep_alive   : VSS.Strings.Virtual_String;
      --  Model keep-alive duration (for example `5m` or `0` to unload immediately)
      options      : Optional_ModelOptions;
      logprobs     : Boolean := Boolean'First;
      --  Whether to return log probabilities of the output tokens
      top_logprobs : Optional_Integer_64;
      --  Number of most likely tokens to return at each token position when logprobs are enabled
   end record;

   function Empty return Logprob_Vector;

   function Is_Null (Self : Logprob_Vector) return Boolean;

   function Length (Self : Logprob_Vector) return Natural;

   procedure Clear (Self : in out Logprob_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out Logprob_Vector; Value : Logprob);

   type Logprob_Variable_Reference (Element : not null access Logprob) is
   null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Logprob_Variable_Reference
     (Self : aliased in out Logprob_Vector; Index : Positive)
      return Logprob_Variable_Reference
   with Inline;

   type Logprob_Constant_Reference
     (Element : not null access constant Logprob)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Logprob_Constant_Reference
     (Self : aliased Logprob_Vector; Index : Positive)
      return Logprob_Constant_Reference
   with Inline;

   function Empty return TokenLogprob_Vector;

   function Is_Null (Self : TokenLogprob_Vector) return Boolean;

   function Length (Self : TokenLogprob_Vector) return Natural;

   procedure Clear
     (Self : in out TokenLogprob_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out TokenLogprob_Vector; Value : TokenLogprob);

   type TokenLogprob_Variable_Reference
     (Element : not null access TokenLogprob)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_TokenLogprob_Variable_Reference
     (Self : aliased in out TokenLogprob_Vector; Index : Positive)
      return TokenLogprob_Variable_Reference
   with Inline;

   type TokenLogprob_Constant_Reference
     (Element : not null access constant TokenLogprob)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_TokenLogprob_Constant_Reference
     (Self : aliased TokenLogprob_Vector; Index : Positive)
      return TokenLogprob_Constant_Reference
   with Inline;

   function Empty return ToolDefinition_Vector;

   function Is_Null (Self : ToolDefinition_Vector) return Boolean;

   function Length (Self : ToolDefinition_Vector) return Natural;

   procedure Clear
     (Self : in out ToolDefinition_Vector; Is_Null : Boolean := True);

   procedure Append
     (Self : in out ToolDefinition_Vector; Value : ToolDefinition);

   type ToolDefinition_Variable_Reference
     (Element : not null access ToolDefinition)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ToolDefinition_Variable_Reference
     (Self : aliased in out ToolDefinition_Vector; Index : Positive)
      return ToolDefinition_Variable_Reference
   with Inline;

   type ToolDefinition_Constant_Reference
     (Element : not null access constant ToolDefinition)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ToolDefinition_Constant_Reference
     (Self : aliased ToolDefinition_Vector; Index : Positive)
      return ToolDefinition_Constant_Reference
   with Inline;

   function Empty return WebSearchResult_Vector;

   function Is_Null (Self : WebSearchResult_Vector) return Boolean;

   function Length (Self : WebSearchResult_Vector) return Natural;

   procedure Clear
     (Self : in out WebSearchResult_Vector; Is_Null : Boolean := True);

   procedure Append
     (Self : in out WebSearchResult_Vector; Value : WebSearchResult);

   type WebSearchResult_Variable_Reference
     (Element : not null access WebSearchResult)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_WebSearchResult_Variable_Reference
     (Self : aliased in out WebSearchResult_Vector; Index : Positive)
      return WebSearchResult_Variable_Reference
   with Inline;

   type WebSearchResult_Constant_Reference
     (Element : not null access constant WebSearchResult)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_WebSearchResult_Constant_Reference
     (Self : aliased WebSearchResult_Vector; Index : Positive)
      return WebSearchResult_Constant_Reference
   with Inline;

   function Empty return Ps_Vector;

   function Is_Null (Self : Ps_Vector) return Boolean;

   function Length (Self : Ps_Vector) return Natural;

   procedure Clear (Self : in out Ps_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out Ps_Vector; Value : Ps);

   type Ps_Variable_Reference (Element : not null access Ps) is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Ps_Variable_Reference
     (Self : aliased in out Ps_Vector; Index : Positive)
      return Ps_Variable_Reference
   with Inline;

   type Ps_Constant_Reference (Element : not null access constant Ps) is
   null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Ps_Constant_Reference
     (Self : aliased Ps_Vector; Index : Positive) return Ps_Constant_Reference
   with Inline;

   function Empty return ChatMessage_Vector;

   function Is_Null (Self : ChatMessage_Vector) return Boolean;

   function Length (Self : ChatMessage_Vector) return Natural;

   procedure Clear
     (Self : in out ChatMessage_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out ChatMessage_Vector; Value : ChatMessage);

   type ChatMessage_Variable_Reference
     (Element : not null access ChatMessage)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ChatMessage_Variable_Reference
     (Self : aliased in out ChatMessage_Vector; Index : Positive)
      return ChatMessage_Variable_Reference
   with Inline;

   type ChatMessage_Constant_Reference
     (Element : not null access constant ChatMessage)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ChatMessage_Constant_Reference
     (Self : aliased ChatMessage_Vector; Index : Positive)
      return ChatMessage_Constant_Reference
   with Inline;

   function Empty return ToolCall_Vector;

   function Is_Null (Self : ToolCall_Vector) return Boolean;

   function Length (Self : ToolCall_Vector) return Natural;

   procedure Clear (Self : in out ToolCall_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out ToolCall_Vector; Value : ToolCall);

   type ToolCall_Variable_Reference (Element : not null access ToolCall) is
   null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ToolCall_Variable_Reference
     (Self : aliased in out ToolCall_Vector; Index : Positive)
      return ToolCall_Variable_Reference
   with Inline;

   type ToolCall_Constant_Reference
     (Element : not null access constant ToolCall)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ToolCall_Constant_Reference
     (Self : aliased ToolCall_Vector; Index : Positive)
      return ToolCall_Constant_Reference
   with Inline;

   function Empty return Integer_64_Vector;

   function Is_Null (Self : Integer_64_Vector) return Boolean;

   function Length (Self : Integer_64_Vector) return Natural;

   procedure Clear
     (Self : in out Integer_64_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out Integer_64_Vector; Value : Integer_64);

   function Empty return Float_64_Vector;

   function Is_Null (Self : Float_64_Vector) return Boolean;

   function Length (Self : Float_64_Vector) return Natural;

   procedure Clear (Self : in out Float_64_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out Float_64_Vector; Value : Float_64);

   type Integer_64_Variable_Reference (Element : not null access Integer_64) is
   null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Integer_64_Variable_Reference
     (Self : aliased in out Integer_64_Vector; Index : Positive)
      return Integer_64_Variable_Reference
   with Inline;

   type Integer_64_Constant_Reference
     (Element : not null access constant Integer_64)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Integer_64_Constant_Reference
     (Self : aliased Integer_64_Vector; Index : Positive)
      return Integer_64_Constant_Reference
   with Inline;

   type Float_64_Variable_Reference (Element : not null access Float_64) is
   null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Float_64_Variable_Reference
     (Self : aliased in out Float_64_Vector; Index : Positive)
      return Float_64_Variable_Reference
   with Inline;

   type Float_64_Constant_Reference
     (Element : not null access constant Float_64)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_Float_64_Constant_Reference
     (Self : aliased Float_64_Vector; Index : Positive)
      return Float_64_Constant_Reference
   with Inline;

   function Empty return ModelSummary_Vector;

   function Is_Null (Self : ModelSummary_Vector) return Boolean;

   function Length (Self : ModelSummary_Vector) return Natural;

   procedure Clear
     (Self : in out ModelSummary_Vector; Is_Null : Boolean := True);

   procedure Append (Self : in out ModelSummary_Vector; Value : ModelSummary);

   type ModelSummary_Variable_Reference
     (Element : not null access ModelSummary)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ModelSummary_Variable_Reference
     (Self : aliased in out ModelSummary_Vector; Index : Positive)
      return ModelSummary_Variable_Reference
   with Inline;

   type ModelSummary_Constant_Reference
     (Element : not null access constant ModelSummary)
   is null record
   with Implicit_Dereference => Element;

   not overriding
   function Get_ModelSummary_Constant_Reference
     (Self : aliased ModelSummary_Vector; Index : Positive)
      return ModelSummary_Constant_Reference
   with Inline;

private
   type Logprob_Array is array (Positive range <>) of aliased Logprob;
   type Logprob_Array_Access is access Logprob_Array;
   type Logprob_Vector is new Ada.Finalization.Controlled with record
      Data    : Logprob_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out Logprob_Vector);

   overriding
   procedure Finalize (Self : in out Logprob_Vector);

   type TokenLogprob_Array is
     array (Positive range <>) of aliased TokenLogprob;
   type TokenLogprob_Array_Access is access TokenLogprob_Array;
   type TokenLogprob_Vector is new Ada.Finalization.Controlled with record
      Data    : TokenLogprob_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out TokenLogprob_Vector);

   overriding
   procedure Finalize (Self : in out TokenLogprob_Vector);

   type Float_64_Array is array (Positive range <>) of aliased Float_64;
   type Float_64_Array_Access is access Float_64_Array;
   type Float_64_Vector is new Ada.Finalization.Controlled with record
      Data    : Float_64_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out Float_64_Vector);

   overriding
   procedure Finalize (Self : in out Float_64_Vector);

   type ToolDefinition_Array is
     array (Positive range <>) of aliased ToolDefinition;
   type ToolDefinition_Array_Access is access ToolDefinition_Array;
   type ToolDefinition_Vector is new Ada.Finalization.Controlled with record
      Data    : ToolDefinition_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out ToolDefinition_Vector);

   overriding
   procedure Finalize (Self : in out ToolDefinition_Vector);

   type WebSearchResult_Array is
     array (Positive range <>) of aliased WebSearchResult;
   type WebSearchResult_Array_Access is access WebSearchResult_Array;
   type WebSearchResult_Vector is new Ada.Finalization.Controlled with record
      Data    : WebSearchResult_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out WebSearchResult_Vector);

   overriding
   procedure Finalize (Self : in out WebSearchResult_Vector);

   type Ps_Array is array (Positive range <>) of aliased Ps;
   type Ps_Array_Access is access Ps_Array;
   type Ps_Vector is new Ada.Finalization.Controlled with record
      Data    : Ps_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out Ps_Vector);

   overriding
   procedure Finalize (Self : in out Ps_Vector);

   type ChatMessage_Array is array (Positive range <>) of aliased ChatMessage;
   type ChatMessage_Array_Access is access ChatMessage_Array;
   type ChatMessage_Vector is new Ada.Finalization.Controlled with record
      Data    : ChatMessage_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out ChatMessage_Vector);

   overriding
   procedure Finalize (Self : in out ChatMessage_Vector);

   type ToolCall_Array is array (Positive range <>) of aliased ToolCall;
   type ToolCall_Array_Access is access ToolCall_Array;
   type ToolCall_Vector is new Ada.Finalization.Controlled with record
      Data    : ToolCall_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out ToolCall_Vector);

   overriding
   procedure Finalize (Self : in out ToolCall_Vector);

   type Integer_64_Array is array (Positive range <>) of aliased Integer_64;
   type Integer_64_Array_Access is access Integer_64_Array;
   type Integer_64_Vector is new Ada.Finalization.Controlled with record
      Data    : Integer_64_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out Integer_64_Vector);

   overriding
   procedure Finalize (Self : in out Integer_64_Vector);

   type ModelSummary_Array is
     array (Positive range <>) of aliased ModelSummary;
   type ModelSummary_Array_Access is access ModelSummary_Array;
   type ModelSummary_Vector is new Ada.Finalization.Controlled with record
      Data    : ModelSummary_Array_Access;
      Length  : Natural := 0;
      Is_Null : Boolean := True;
   end record;

   overriding
   procedure Adjust (Self : in out ModelSummary_Vector);

   overriding
   procedure Finalize (Self : in out ModelSummary_Vector);

end Ollama_API.Types;
