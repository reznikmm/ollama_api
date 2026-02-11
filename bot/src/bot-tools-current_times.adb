--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ada.Calendar.Formatting;

with Ada.Calendar.Time_Zones;
with VSS.JSON.Streams;
with VSS.Strings.Conversions;
with VSS.Strings.Formatters.Strings;
with VSS.Strings.Templates;

package body Bot.Tools.Current_Times is

   Answer : constant VSS.Strings.Templates.Virtual_String_Template :=
     "Current local date and time is {}.";

   overriding function Calculate
     (Self : in out Current_Time_Tool;
      Args : Ollama_API.Tools.String_Maps.Map)
      return VSS.Strings.Virtual_String is
       (Answer.Format
         (VSS.Strings.Formatters.Strings.Image
           (VSS.Strings.Conversions.To_Virtual_String
             (Ada.Calendar.Formatting.Image
               (Date      => Ada.Calendar.Clock,
                Time_Zone => Ada.Calendar.Time_Zones.Local_Time_Offset)))));

   overriding function Get_Definition (Self : Current_Time_Tool)
     return Ollama_API.Types.ToolDefinition is
        (a_function => Ollama_API.Types.ToolDefinition_function'
           (name        => "current_time",
            description => "Return current local time and date",
            parameters  =>
              [(Kind => VSS.JSON.Streams.Start_Object),
               (Kind => VSS.JSON.Streams.End_Object)]));

end Bot.Tools.Current_Times;
