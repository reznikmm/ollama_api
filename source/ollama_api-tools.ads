--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Containers.Hashed_Maps;
with VSS.Strings.Hash;

package Ollama_API.Tools is

   type Abstract_Tool is limited interface;

   procedure Execute
     (Self      : in out Abstract_Tool;
      Arguments : Ollama_API.Types.Any_Object;
      Result    : out VSS.Strings.Virtual_String;
      Error     : out VSS.Strings.Virtual_String) is abstract;

   function Get_Definition (Self : Abstract_Tool)
     return Ollama_API.Types.ToolDefinition is abstract;

   package String_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => VSS.Strings.Virtual_String,
      Element_Type    => VSS.Strings.Virtual_String,
      Hash            => VSS.Strings.Hash,
      Equivalent_Keys => VSS.Strings."=",
      "="             => VSS.Strings."=");

   type Simple_Tool is abstract limited new Abstract_Tool with null record;

   procedure Execute
     (Self      : in out Simple_Tool;
      Arguments : Ollama_API.Types.Any_Object;
      Result    : out VSS.Strings.Virtual_String;
      Error     : out VSS.Strings.Virtual_String);

   function Calculate
     (Self : in out Simple_Tool;
      Args : String_Maps.Map) return VSS.Strings.Virtual_String is abstract;

   type Tool_Register is tagged limited private;

   type Tool_Access is access all Abstract_Tool'Class with Storage_Size => 0;

   procedure Register
     (Self : in out Tool_Register'Class;
      Name : VSS.Strings.Virtual_String;
      Tool : not null Tool_Access);

   function All_Tools (Self : Tool_Register'Class)
      return Ollama_API.Types.ToolDefinition_Vector;

   procedure Execute
     (Self   : Tool_Register'Class;
      Call   : Ollama_API.Types.ToolCall;
      Result : out Ollama_API.Types.ChatMessage;
      Error  : out VSS.Strings.Virtual_String);

   procedure Execute
     (Self    : Tool_Register'Class;
      Call    : Ollama_API.Types.ToolCall;
      Result  : out Ollama_API.Types.ChatMessage);

   function To_String_Map
     (Arguments : Ollama_API.Types.Any_Object) return String_Maps.Map;

   type String_Parameter is record
      Name        : VSS.Strings.Virtual_String;
      Description : VSS.Strings.Virtual_String;
      Required    : Boolean;
   end record;

   type String_Parameter_Array is
     array (Positive range <>) of String_Parameter;

   function To_JSON_Scheme
     (String_Parameters : String_Parameter_Array)
        return Ollama_API.Types.Any_Object;

private

   package Tool_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => VSS.Strings.Virtual_String,
      Element_Type    => Tool_Access,
      Hash            => VSS.Strings.Hash,
      Equivalent_Keys => VSS.Strings."=");

   type Tool_Register is tagged limited record
      Map : Tool_Maps.Map;
   end record;

end Ollama_API.Tools;
