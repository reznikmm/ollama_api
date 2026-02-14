--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ollama_API;

with VSS.Strings;

with Bot.Prompts;

package Bot.Instances is

   type Bot_Instance is tagged limited private;

   procedure Initialize
     (Self  : in out Bot_Instance'Class;
      Error : out VSS.Strings.Virtual_String);

   procedure Run (Self : in out Bot_Instance'Class);

private

   type Prompt_List is
     array (Bot.Prompts.Predefined_Prompt) of VSS.Strings.Virtual_String;

   type Bot_Instance is tagged limited record
      Ollama  : Ollama_API.Server;
      Model   : VSS.Strings.Virtual_String := "llama3.1:8b";
      Prompts : Prompt_List;
   end record;

end Bot.Instances;
