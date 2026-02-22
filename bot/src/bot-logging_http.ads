--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Calendar;
with HTTP_Requests;
with Ollama_API.HTTP_Requests;
with VSS.IRIs;
with VSS.Stream_Element_Vectors;
with VSS.Strings;

package Bot.Logging_HTTP is

   type HTTP_Request is limited new Ollama_API.HTTP_Requests.HTTP_Request with
     private;

   procedure Set_Log_Folder
     (Self : in out HTTP_Request'Class;
      Path : VSS.Strings.Virtual_String);

private

   type HTTP_Request is limited new HTTP_Requests.HTTP_Request with record
      Path  : VSS.Strings.Virtual_String;
      Last  : Ada.Calendar.Time := Ada.Calendar.Clock;
      Count : Natural := 0;
   end record;

   overriding procedure Post
     (Self          : in out HTTP_Request;
      URL           : VSS.IRIs.IRI;
      Content_Type  : VSS.Strings.Virtual_String;
      Authorization : VSS.Strings.Virtual_String;
      Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Status_Code   : out Natural);

end Bot.Logging_HTTP;
