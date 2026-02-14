--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.JSON.Pull_Readers.Simple;
with VSS.JSON.Streams;
with Bot.Buffer_Text_Streams;

package body Bot.Tasks is

   -----------------
   -- Decode_JSON --
   -----------------

   procedure Decode_JSON
     (JSON   : VSS.Strings.Virtual_String;
      Result : out Bot_Task;
      Error  : out VSS.Strings.Virtual_String)
   is
      --  Parse JSON string and fill the Result record.
      --  {
      --  "title": "Write Pulling STM32 drivers",
      --  "categories": ["todo"],
      --  "definition_of_done": "Todo file updated",
      --  "activation_condition": "now"
      --  }
      use all type VSS.Strings.Virtual_String;
      use all type VSS.JSON.Streams.JSON_Stream_Element_Kind;
      Input  : aliased Bot.Buffer_Text_Streams.Buffer_Input_Text_Stream;
      Reader : VSS.JSON.Pull_Readers.Simple.JSON_Simple_Pull_Reader;
   begin
      Input.Text := JSON;
      Input.Cursor.Set_Before_First (Input.Text);
      Reader.Set_Stream (Input'Unchecked_Access);
      Reader.Read_Next;
      if not Reader.Is_Start_Document then
         Error.Append ("Wrong JSON format");
         return;
      end if;

      Reader.Read_Next;

      if not Reader.Is_Start_Object then
         Error.Append ("Wrong JSON format");
         return;
      end if;

      Reader.Read_Next;

      while Reader.Element_Kind = Key_Name loop
         if Reader.Key_Name = "title" then
            Reader.Read_Next;

            if not Reader.Is_String_Value then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Result.Title := Reader.String_Value;
            Reader.Read_Next;
         elsif Reader.Key_Name = "description" then
            Reader.Read_Next;

            if not Reader.Is_String_Value then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Result.Description := Reader.String_Value;
            Reader.Read_Next;
         elsif Reader.Key_Name = "categories" then
            Reader.Read_Next;
            if not Reader.Is_Start_Array then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Reader.Read_Next;
            while Reader.Is_String_Value loop
               Result.Categories.Append (Reader.String_Value);
               Reader.Read_Next;
            end loop;

            if not Reader.Is_End_Array then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Reader.Read_Next;
         elsif Reader.Key_Name = "definition_of_done" then
            Reader.Read_Next;

            if not Reader.Is_String_Value then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Result.Definition_Of_Done := Reader.String_Value;
            Reader.Read_Next;
         elsif Reader.Key_Name = "activation_condition" then
            Reader.Read_Next;

            if not Reader.Is_String_Value then
               Error.Append ("Wrong JSON format");
               return;
            end if;

            Result.Activation_Condition := Reader.String_Value;
            Reader.Read_Next;
         else
            Reader.Read_Next;
            Reader.Skip_Current_Value;
         end if;
      end loop;

      if not Reader.Is_End_Object then
         Error.Append ("Wrong JSON format");
         return;
      end if;
   end Decode_JSON;

end Bot.Tasks;
