--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Directories;

with Bot.JSON_Content_Buffers;

with VSS.JSON.Push_Readers.Simple;
with VSS.Strings.Conversions;
with VSS.Strings.Formatters.Integers;
with VSS.Strings.Templates;
with VSS.Text_Streams.File_Input;
with VSS.Text_Streams.File_Output;

package body Bot.Tools.Write_Todos is

   Path : constant VSS.Strings.Templates.Virtual_String_Template :=
     "work/todo/{}.txt";

   ---------------
   -- Calculate --
   ---------------

   overriding function Calculate
     (Self : in out Write_Todo_Tool;
      Args : Ollama_API.Tools.String_Maps.Map)
      return VSS.Strings.Virtual_String
   is
      Output  : aliased VSS.Text_Streams.File_Output.File_Output_Text_Stream;
      Key     : constant Ollama_API.Tools.String_Maps.Cursor := Args.First;
      Content : constant VSS.Strings.Virtual_String :=
        (if Ollama_API.Tools.String_Maps.Has_Element (Key) then Args (Key)
         else VSS.Strings.Empty_Virtual_String);

      Ok      : Boolean := True;
      Try     : Integer;
      Name    : VSS.Strings.Virtual_String;
   begin
      if Content.Is_Empty then
         return "Error: no (or empty) item text provided!";
      end if;

      for J in 1 .. 10 loop
         Try := Integer_Random.Random (Self.Random);
         Name := Path.Format (VSS.Strings.Formatters.Integers.Image (Try));

         if not Ada.Directories.Exists
           (VSS.Strings.Conversions.To_UTF_8_String (Name))
         then
            Output.Create (Name);
            exit when not Output.Has_Error;
         end if;
      end loop;

      if Output.Has_Error then
         return Output.Error_Message;
      end if;

      Output.Put_Line (Content, Ok);

      return "Successfully written!";
   end Calculate;

   --------------------
   -- Get_Definition --
   --------------------

   overriding function Get_Definition (Self : Write_Todo_Tool)
     return Ollama_API.Types.ToolDefinition
   is
      use type VSS.Strings.Virtual_String;
      Name : constant VSS.Strings.Virtual_String := "write_todo";
      Dir  : constant VSS.Strings.Virtual_String := "share/bot/tools/";
      Text : constant VSS.Strings.Virtual_String :=
        "Write new todo item in a file. Use this tool to save todo items.";

      Input : aliased VSS.Text_Streams.File_Input.File_Input_Text_Stream;
      Reader : VSS.JSON.Push_Readers.Simple.JSON_Simple_Push_Reader;
      Buffer : aliased Bot.JSON_Content_Buffers.JSON_Content_Buffer;
   begin
      Input.Open (Dir & Name & ".json");
      Reader.Set_Stream (Input'Unchecked_Access);
      Reader.Set_Content_Handler (Buffer'Unchecked_Access);
      Reader.Parse;

      return
        (a_function => Ollama_API.Types.ToolDefinition_function'
           (name        => Name,
            description => Text,
            parameters  => Buffer.Object));
   end Get_Definition;

end Bot.Tools.Write_Todos;
