--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ollama_API;

with Ollama_API.Tools;
with VSS.Strings;

with Bot.Prompts;
with Bot.Logging_HTTP;

with Bot.Tools.Current_Times;
with Bot.Tools.Write_Todos;

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
      HTTP    : aliased Bot.Logging_HTTP.HTTP_Request;
      Model   : VSS.Strings.Virtual_String := "llama3.1:8b";
      Prompts : Prompt_List;
      Tools   : Ollama_API.Tools.Tool_Register;

      --  Tools:
      Current_Time : aliased Bot.Tools.Current_Times.Current_Time_Tool;
      Todo         : aliased Bot.Tools.Write_Todos.Write_Todo_Tool;
   end record;

end Bot.Instances;
