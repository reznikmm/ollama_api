--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.IRIs;
with VSS.Strings;

limited with Ollama_API.HTTP_Requests;
limited with Ollama_API.Types;

package Ollama_API is

   type Server is tagged limited private;

   procedure Chat
     (Self     : in out Server'Class;
      Request  : Ollama_API.Types.ChatRequest;
      Response : out Ollama_API.Types.ChatResponse;
      Success  : out Boolean);
   --  Generate the next chat message in a conversation between a user and an
   --  assistant.

   procedure Set_URL
     (Self  : in out Server'Class;
      Value : VSS.IRIs.IRI);

   procedure Set_URL
     (Self  : in out Server'Class;
      Value : VSS.Strings.Virtual_String);

   type HTTP_Request_Access is
     access all Ollama_API.HTTP_Requests.HTTP_Request'Class
       with Storage_Size => 0;

   procedure Set_Request_Handler
     (Self  : in out Server'Class;
      Value : not null HTTP_Request_Access);

   function JSON_Format return Ollama_API.Types.Any_Object;
   --  Just encoded "json" string to pass as Format argument in Chat request

private

   type Server is tagged limited record
      HTTP : HTTP_Request_Access;
      URL  : VSS.IRIs.IRI :=
        VSS.IRIs.To_IRI ("http://localhost:11434/api/chat");
   end record;

end Ollama_API;
