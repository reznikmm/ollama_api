--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

package body Ollama_API.Chats is

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
      Success      : out Boolean)
   is
   begin
      Self.Chat
        (Ollama_API.Types.ChatRequest'
           (model      => Model,
            messages   => Messages,
            tools      => Tools,
            format     => Format,
            options    => Options,
            stream     => Stream,
            think      => Think,
            keep_alive =>
              (if Keep_Alive.Is_Empty then "0" else Keep_Alive),
            logprobs     => Logprobs,
            top_logprobs => Top_Logprobs),
         Response,
         Success);

   end Chat;


end Ollama_API.Chats;
