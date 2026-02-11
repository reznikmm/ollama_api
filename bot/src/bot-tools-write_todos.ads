--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Numerics.Discrete_Random;

with VSS.Strings;

with Ollama_API.Tools;
with Ollama_API.Types;

package Bot.Tools.Write_Todos is

   type Write_Todo_Tool is
     limited new Ollama_API.Tools.Simple_Tool with private;

private

   package Integer_Random is new Ada.Numerics.Discrete_Random (Positive);

   type Write_Todo_Tool is limited new Ollama_API.Tools.Simple_Tool with record
      Random : Integer_Random.Generator;
   end record;

   overriding function Get_Definition (Self : Write_Todo_Tool)
     return Ollama_API.Types.ToolDefinition;

   overriding function Calculate
     (Self : in out Write_Todo_Tool;
      Args : Ollama_API.Tools.String_Maps.Map)
        return VSS.Strings.Virtual_String;

end Bot.Tools.Write_Todos;
