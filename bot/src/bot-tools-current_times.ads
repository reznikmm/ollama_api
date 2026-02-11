--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.Strings;

with Ollama_API.Tools;
with Ollama_API.Types;

package Bot.Tools.Current_Times is

   type Current_Time_Tool is
     limited new Ollama_API.Tools.Simple_Tool with null record;

   overriding function Get_Definition (Self : Current_Time_Tool)
     return Ollama_API.Types.ToolDefinition;

   overriding function Calculate
     (Self : in out Current_Time_Tool;
      Args : Ollama_API.Tools.String_Maps.Map)
        return VSS.Strings.Virtual_String;

end Bot.Tools.Current_Times;
