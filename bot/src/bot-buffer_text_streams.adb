--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

package body Bot.Buffer_Text_Streams is

   ---------
   -- Get --
   ---------

   procedure Get
     (Self    : in out Buffer_Input_Text_Stream;
      Item    : out VSS.Characters.Virtual_Character'Base;
      Success : in out Boolean) is
   begin
      Success := Self.Cursor.Forward (Item);
   end Get;

end Bot.Buffer_Text_Streams;
