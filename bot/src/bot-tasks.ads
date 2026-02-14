--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.String_Vectors;
with VSS.Strings;

package Bot.Tasks is

   type Bot_Task is record
      Id                   : Natural;
      Title                : VSS.Strings.Virtual_String;
      Description          : VSS.Strings.Virtual_String;
      Categories           : VSS.String_Vectors.Virtual_String_Vector;
      Definition_Of_Done   : VSS.Strings.Virtual_String;
      Activation_Condition : VSS.Strings.Virtual_String;
   end record;

   procedure Decode_JSON
     (JSON   : VSS.Strings.Virtual_String;
      Result : out Bot_Task;
      Error  : out VSS.Strings.Virtual_String);
--     {
--  "title": "Write Pulling STM32 drivers",
--  "categories": ["todo"],
--  "definition_of_done": "Todo file updated",
--  "activation_condition": "now"
--  }


end Bot.Tasks;
