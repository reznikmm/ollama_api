--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ollama_API.Types;

package Ollama_API.Chats is

   procedure Chat
     (Self         : in out Server'Class;
      Model        : VSS.Strings.Virtual_String;
      Messages     : Ollama_API.Types.ChatMessage_Vector;
      Tools        : Ollama_API.Types.ToolDefinition_Vector := [];
      Format       : Ollama_API.Types.Any_Object := [];
      Options      : Ollama_API.Types.Optional_ModelOptions :=
                       (Is_Set => False);
      Stream       : Boolean := True;
      Think        : Ollama_API.Types.Optional_ChatRequest_think :=
                       (Is_Set => False);
      Keep_Alive   : VSS.Strings.Virtual_String :=
                       VSS.Strings.Empty_Virtual_String;
      Logprobs     : Boolean := False;
      Top_Logprobs : Ollama_API.Types.Optional_Integer_64 := (Is_Set => False);
      Response     : out Ollama_API.Types.ChatResponse;
      Success      : out Boolean);
   --  Generate the next chat message in a conversation between a user and an
   --  assistant.
   --
   --  * @param Model - Model name
   --  * @param Messages - Chat history as an array of message objects (each
   --    with a role and content)
   --  * @param Tools - Optional list of function tools the model may call
   --    during the chat
   --  * @param Format - Format to return a response in. Can be `json` or a
   --    JSON schema
   --  * @param Options - When true, returns separate thinking output in
   --    addition to content. Can be a boolean (true/false) or a string
   --  * @param Think - ("high", "medium", "low") for supported models.
   --  * @param Keep_alive - Model keep-alive duration (for example `5m` or `0`
   --    to unload immediately)
   --  * @param Keep_alive - Whether to return log probabilities of the output
   --    tokens
   --  * @param Top_Logprobs - Number of most likely tokens to return at each
   --    token position when logprobs are enabled



end Ollama_API.Chats;
