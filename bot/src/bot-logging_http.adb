--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Calendar.Formatting;
with Ada.Streams.Stream_IO;
with VSS.Strings.Conversions;
with VSS.Strings.Formatters.Strings;
with VSS.Strings.Templates;

package body Bot.Logging_HTTP is

   Path : constant VSS.Strings.Templates.Virtual_String_Template :=
     "{}/{}{}{}.json";

   overriding procedure Post
     (Self          : in out HTTP_Request;
      URL           : VSS.IRIs.IRI;
      Content_Type  : VSS.Strings.Virtual_String;
      Authorization : VSS.Strings.Virtual_String;
      Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Status_Code   : out Natural)
   is
      use type Ada.Calendar.Time;

      Now : constant Ada.Calendar.Time := Ada.Calendar.Clock;
   begin
      if Self.Last = Now then
         Self.Count := Self.Count + 1;
      else
         Self.Last := Now;
         Self.Count := 0;
      end if;

      declare
         File   : Ada.Streams.Stream_IO.File_Type;
         Name   : VSS.Strings.Virtual_String;
         Dir    : VSS.Strings.Virtual_String;
         Time   : VSS.Strings.Virtual_String;
         Count  : VSS.Strings.Virtual_String;
         Buffer : Ada.Streams.Stream_Element_Array (1 .. Output.Length);
      begin
         for J in Buffer'Range loop
            Buffer (J) := Output (J);
         end loop;

         Dir := "_call";

         Time := VSS.Strings.Conversions.To_Virtual_String
           (Ada.Calendar.Formatting.Image (Self.Last));

         Count := VSS.Strings.Conversions.To_Virtual_String
           (if Self.Count = 0 then "" else Integer'Image (-Self.Count));

         Name := Path.Format
           (VSS.Strings.Formatters.Strings.Image (Self.Path),
            VSS.Strings.Formatters.Strings.Image (Time),
            VSS.Strings.Formatters.Strings.Image (Count),
            VSS.Strings.Formatters.Strings.Image (Dir));

         Ada.Streams.Stream_IO.Create
           (File,
            Name => VSS.Strings.Conversions.To_UTF_8_String (Name));
         Ada.Streams.Stream_IO.Write (File, Buffer);
         Ada.Streams.Stream_IO.Close (File);
      end;

      HTTP_Requests.HTTP_Request (Self).Post
        (URL, Content_Type, Authorization, Output, Response, Status_Code);

      declare
         File   : Ada.Streams.Stream_IO.File_Type;
         Name   : VSS.Strings.Virtual_String;
         Dir    : VSS.Strings.Virtual_String;
         Time   : VSS.Strings.Virtual_String;
         Count  : VSS.Strings.Virtual_String;
         Buffer : Ada.Streams.Stream_Element_Array (1 .. Response.Length);
      begin
         for J in Buffer'Range loop
            Buffer (J) := Response (J);
         end loop;

         Dir := "_resp";

         Time := VSS.Strings.Conversions.To_Virtual_String
           (Ada.Calendar.Formatting.Image (Self.Last));

         Count := VSS.Strings.Conversions.To_Virtual_String
           (if Self.Count = 0 then "" else Integer'Image (-Self.Count));

         Name := Path.Format
           (VSS.Strings.Formatters.Strings.Image (Self.Path),
            VSS.Strings.Formatters.Strings.Image (Time),
            VSS.Strings.Formatters.Strings.Image (Count),
            VSS.Strings.Formatters.Strings.Image (Dir));

         Ada.Streams.Stream_IO.Create
           (File,
            Name => VSS.Strings.Conversions.To_UTF_8_String (Name));
         Ada.Streams.Stream_IO.Write (File, Buffer);
         Ada.Streams.Stream_IO.Close (File);
      end;
   end Post;

   procedure Set_Log_Folder
     (Self : in out HTTP_Request'Class;
      Path : VSS.Strings.Virtual_String) is
   begin
      Self.Path := Path;
   end Set_Log_Folder;

end Bot.Logging_HTTP;
