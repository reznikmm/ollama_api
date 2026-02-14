--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ollama_API.Tools;
with Ollama_API.Types;
with VSS.Strings;

package Concat_Tools is
   use type VSS.Strings.Virtual_String;

   type Concat_Tool is new Ollama_API.Tools.Simple_Tool with null record;

   overriding function Get_Definition
     (Self : Concat_Tool) return Ollama_API.Types.ToolDefinition is
       (a_function =>
         (name        => "concat",
          description => "Concatinate two numbers",
          parameters  => Ollama_API.Tools.To_JSON_Scheme
            ([(Name => "a",
               Description => "The first number",
               Required    => True),
              (Name => "b",
               Description => "The second number",
               Required    => True)])));

   overriding function Calculate
     (Self : in out Concat_Tool;
      Args : Ollama_API.Tools.String_Maps.Map)
        return VSS.Strings.Virtual_String is
          (Args ("a") & Args ("b"));

   Tool : aliased Concat_Tool;

end Concat_Tools;
