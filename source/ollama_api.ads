--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.IRIs;
with VSS.Strings;
with VSS.Stream_Element_Vectors;

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

   type HTTP_Post_Request is access
     procedure
       (URL           : VSS.IRIs.IRI;
        Content_Type  : VSS.Strings.Virtual_String;
        Authorization : VSS.Strings.Virtual_String;
        Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
        Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
        Status_Code   : out Natural);

   procedure Set_Request_Handler
     (Self  : in out Server'Class;
      Value : HTTP_Post_Request);

   function JSON_Format return Ollama_API.Types.Any_Object;
   --  Just encoded "json" string to pass as Format argument in Chat request

private

   type Server is tagged limited record
      HTTP : HTTP_Post_Request;
      URL  : VSS.IRIs.IRI :=
        VSS.IRIs.To_IRI ("http://localhost:11434/api/chat");
   end record;

end Ollama_API;
