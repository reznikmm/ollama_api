--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.Strings;
with VSS.Strings.Character_Iterators;
with VSS.Text_Streams;
with VSS.Characters;

package Bot.Buffer_Text_Streams is

   type Buffer_Input_Text_Stream is
     limited new VSS.Text_Streams.Input_Text_Stream with record
        Text   : VSS.Strings.Virtual_String;
        Cursor : VSS.Strings.Character_Iterators.Character_Iterator;
   end record;

   overriding procedure Get
     (Self    : in out Buffer_Input_Text_Stream;
      Item    : out VSS.Characters.Virtual_Character'Base;
      Success : in out Boolean);

   overriding function Is_End_Of_Data
     (Self : Buffer_Input_Text_Stream) return Boolean is (False);

   overriding function Is_End_Of_Stream
     (Self : Buffer_Input_Text_Stream) return Boolean is
       (not Self.Cursor.Has_Element);

   overriding function Has_Error
     (Self : Buffer_Input_Text_Stream) return Boolean is (False);

   overriding function Error_Message
     (Self : Buffer_Input_Text_Stream) return VSS.Strings.Virtual_String is
       ("");

end Bot.Buffer_Text_Streams;
