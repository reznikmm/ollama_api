--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.Characters;
with VSS.Strings;
with VSS.Text_Streams.File_Input;

procedure Bot.Read_File
  (Name  : VSS.Strings.Virtual_String;
   Text  : out VSS.Strings.Virtual_String;
   Error : out VSS.Strings.Virtual_String)
is
   Input : VSS.Text_Streams.File_Input.File_Input_Text_Stream;
   Next  : VSS.Characters.Virtual_Character;
   Ok    : Boolean := True;
begin
   Input.Open (Name);
   Text.Clear;

   if Input.Has_Error then
      Error := Input.Error_Message;
   else
      while not Input.Is_End_Of_Stream loop
         Input.Get (Next, Ok);
         exit when not Ok;
         Text.Append (Next);
      end loop;
   end if;

   Input.Close;
end Bot.Read_File;
