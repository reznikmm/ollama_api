--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.Strings;
with VSS.Strings.Formatters.Generic_Enumerations;
with VSS.Strings.Templates;

package Bot.Prompts is

   type Predefined_Prompt is (Analyze_Task);

   function File_Name
     (Prompt : Predefined_Prompt) return VSS.Strings.Virtual_String;

private
   Path : VSS.Strings.Templates.Virtual_String_Template :=
     "share/bot/prompts/{}.txt";

   package Prompt_Formatters is new
     VSS.Strings.Formatters.Generic_Enumerations (Predefined_Prompt);

   function File_Name
     (Prompt : Predefined_Prompt) return VSS.Strings.Virtual_String is
       (Path.Format (Prompt_Formatters.Image (Prompt)));

end Bot.Prompts;
