--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Ada.Exceptions;

with Ollama_API.Types;
with VSS.JSON.Streams;
with VSS.Strings.Conversions;

package body Ollama_API.Tools is

   procedure Execute
     (Self    : Tool_Register'Class;
      Call    : Ollama_API.Types.ToolCall_function;
      Result  : out VSS.Strings.Virtual_String;
      Error   : out VSS.Strings.Virtual_String);

   ---------------
   -- All_Tools --
   ---------------

   function All_Tools (Self : Tool_Register'Class)
      return Ollama_API.Types.ToolDefinition_Vector is
   begin
      return Result : Ollama_API.Types.ToolDefinition_Vector do
         for Item of Self.Map loop
            Result.Append (Item.Get_Definition);
         end loop;
      end return;
   end All_Tools;

   -------------
   -- Execute --
   -------------

   procedure Execute
     (Self    : Tool_Register'Class;
      Call    : Ollama_API.Types.ToolCall_function;
      Result  : out VSS.Strings.Virtual_String;
      Error   : out VSS.Strings.Virtual_String)
   is
      Cursor : constant Tool_Maps.Cursor := Self.Map.Find (Call.name);
   begin
      if Tool_Maps.Has_Element (Cursor) then
         Tool_Maps.Element (Cursor).Execute (Call.arguments, Result, Error);
      else
         Error.Append ("Call to unknown function: ");
         Error.Append (Call.name);
      end if;
   exception
      when E : others =>
         Error.Append ("Function raised exception: ");
         Error.Append
           (VSS.Strings.Conversions.To_Virtual_String
              (Ada.Exceptions.Exception_Name (E)));
         Error.Append (". ");
         Error.Append
           (VSS.Strings.Conversions.To_Virtual_String
              (Ada.Exceptions.Exception_Message (E)));
   end Execute;

   -------------
   -- Execute --
   -------------

   procedure Execute
     (Self   : Tool_Register'Class;
      Call   : Ollama_API.Types.ToolCall;
      Result : out Ollama_API.Types.ChatMessage;
      Error  : out VSS.Strings.Virtual_String)
   is
      Text : VSS.Strings.Virtual_String;
   begin
      if Call.a_function.Is_Set then
         Self.Execute (Call.a_function.Value, Text, Error);

         Result :=
           (role         => Ollama_API.Types.tool,
            content      => Text,
            tool_name    => Call.a_function.Value.name,
            tool_call_id => Call.id,
            others       => <>);
      else
         Error.Append ("No function object in ToolCall");
      end if;
   end Execute;

   -------------
   -- Execute --
   -------------

   procedure Execute
     (Self    : Tool_Register'Class;
      Call    : Ollama_API.Types.ToolCall;
      Result  : out Ollama_API.Types.ChatMessage)
   is
      use type VSS.Strings.Virtual_String;

      Error : VSS.Strings.Virtual_String;
   begin
      Self.Execute (Call, Result, Error);

      if not Error.Is_Empty then
         Result :=
           (role         => Ollama_API.Types.tool,
            content      => "Error on function call: " & Error,
            tool_name    => Call.a_function.Value.name,
            tool_call_id => Call.id,
            others       => <>);
      end if;
   end Execute;

   -------------
   -- Execute --
   -------------

   procedure Execute
     (Self      : in out Simple_Tool;
      Arguments : Ollama_API.Types.Any_Object;
      Result    : out VSS.Strings.Virtual_String;
      Error     : out VSS.Strings.Virtual_String)
   is
      pragma Unreferenced (Error);
   begin
      Result := Simple_Tool'Class (Self).Calculate (To_String_Map (Arguments));
   end Execute;

   --------------
   -- Register --
   --------------

   procedure Register
     (Self : in out Tool_Register'Class;
      Name : VSS.Strings.Virtual_String;
      Tool : not null Tool_Access) is
   begin
      Self.Map.Insert (Name, Tool);
   end Register;

   --------------------
   -- To_JSON_Scheme --
   --------------------

   function To_JSON_Scheme
     (String_Parameters : String_Parameter_Array)
        return Ollama_API.Types.Any_Object
   is
      use all type VSS.JSON.Streams.JSON_Stream_Element_Kind;

      subtype Element is VSS.JSON.Streams.JSON_Stream_Element;
   begin
      return Result : Ollama_API.Types.Any_Object do
         Result.Append (Element'(Kind => Start_Object));
         Result.Append (Element'(Key_Name, "type"));
         Result.Append (Element'(String_Value, "object"));
         Result.Append (Element'(Key_Name, "required"));
         Result.Append (Element'(Kind => Start_Array));

         for Item of String_Parameters loop
            if Item.Required then
               Result.Append (Element'(String_Value, Item.Name));
            end if;
         end loop;

         Result.Append (Element'(Kind => End_Array));
         Result.Append (Element'(Key_Name, "properties"));
         Result.Append (Element'(Kind => Start_Object));

         for Item of String_Parameters loop
            Result.Append (Element'(Key_Name, Item.Name));
            Result.Append (Element'(Kind => Start_Object));
            Result.Append (Element'(Key_Name, "type"));
            Result.Append (Element'(String_Value, "string"));
            Result.Append (Element'(Key_Name, "description"));
            Result.Append (Element'(String_Value, Item.Description));
            Result.Append (Element'(Kind => End_Object));
         end loop;

         Result.Append (Element'(Kind => End_Object));
         Result.Append (Element'(Kind => End_Object));
      end return;
   end To_JSON_Scheme;

   -------------------
   -- To_String_Map --
   -------------------

   function To_String_Map
     (Arguments : Ollama_API.Types.Any_Object) return String_Maps.Map
   is
      use all type VSS.JSON.Streams.JSON_Stream_Element_Kind;

      Name   : VSS.Strings.Virtual_String;
   begin
      return Result : String_Maps.Map do
         for Item of Arguments loop
            case Item.Kind is
               when Key_Name =>
                  Name := Item.Key_Name;
               when String_Value =>
                  Result.Insert (Name, Item.String_Value);
               when others =>
                  null;
            end case;
         end loop;
      end return;
   end To_String_Map;

end Ollama_API.Tools;
