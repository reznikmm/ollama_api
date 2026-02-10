--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

pragma Ada_2022;
with Minimal_Perfect_Hash;

package body Ollama_API.Types.Inputs is
   pragma Style_Checks (Off);
   use type VSS.JSON.JSON_Number_Kind;
   use type VSS.Strings.Virtual_String;

   procedure Input_Any_Value
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Any_Value'Class;
      Success : in out Boolean)
   is
      use type VSS.JSON.Streams.JSON_Stream_Element_Kind;
   begin
      case Reader.Element_Kind is
         when VSS.JSON.Streams.Start_Array  =>
            Value.Append ((Kind => VSS.JSON.Streams.Start_Array));
            Reader.Read_Next;
            while Success and Reader.Element_Kind /= VSS.JSON.Streams.End_Array
            loop
               Input_Any_Value (Reader, Value, Success);
            end loop;
            Value.Append ((Kind => VSS.JSON.Streams.End_Array));

         when VSS.JSON.Streams.Start_Object =>
            Value.Append ((Kind => VSS.JSON.Streams.Start_Object));
            Reader.Read_Next;
            while Success and Reader.Element_Kind = VSS.JSON.Streams.Key_Name
            loop
               Value.Append (Reader.Element);
               Reader.Read_Next;
               Input_Any_Value (Reader, Value, Success);
            end loop;
            Value.Append ((Kind => VSS.JSON.Streams.End_Object));

         when VSS.JSON.Streams.String_Value
            | VSS.JSON.Streams.Number_Value
            | VSS.JSON.Streams.Boolean_Value
            | VSS.JSON.Streams.Null_Value   =>
            Value.Append (Reader.Element);

         when others                        =>
            Success := False;
      end case;
      if Success then
         Reader.Read_Next;
      end if;
   end Input_Any_Value;

   package ChatMessage_role_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["system", "user", "assistant", "tool"]);

   procedure Input_ChatMessage_role
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatMessage_role;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           ChatMessage_role_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := ChatMessage_role'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_ChatMessage_role;

   package ChatRequest_think_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["high", "medium", "low"]);

   procedure Input_ChatRequest_think
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatRequest_think;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           ChatRequest_think_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := ChatRequest_think'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_ChatRequest_think;

   package GenerateRequest_think_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["high", "medium", "low"]);

   procedure Input_GenerateRequest_think
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateRequest_think;
      Success : in out Boolean)
   is
      Index : constant Integer :=
        (if Reader.Is_String_Value
         then
           GenerateRequest_think_Minimal_Perfect_Hash.Get_Index
             (Reader.String_Value)
         else -1);
   begin
      if Index > 0 then
         Value := GenerateRequest_think'Val (Index - 1);
         Reader.Read_Next;
      else
         Success := False;
      end if;
   end Input_GenerateRequest_think;

   package ChatStreamEvent_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["model", "created_at", "message", "done"]);

   package ChatStreamEvent_message_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["role", "content", "thinking", "tool_calls", "images"]);

   procedure Input_ChatStreamEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatStreamEvent;
      Success : in out Boolean)
   is
      procedure Input_ChatStreamEvent_message
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ChatStreamEvent_message;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ChatStreamEvent_message_Minimal_Perfect_Hash.Get_Index
                      (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  role
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.role := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 2      =>
                        --  content
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.content := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 3      =>
                        --  thinking
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.thinking := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 4      =>
                        --  tool_calls
                        Reader.Read_Next;
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.tool_calls.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ToolCall;
                              begin
                                 Input_ToolCall (Reader, Item, Success);
                                 Value.tool_calls.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;

                     when 5      =>
                        --  images
                        Reader.Read_Next;
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.images.Clear;
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : VSS.Strings.Virtual_String;
                              begin
                                 if Reader.Is_String_Value then
                                    Item := Reader.String_Value;
                                    Reader.Read_Next;
                                 else
                                    Success := False;
                                 end if;
                                 Value.images.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ChatStreamEvent_message;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatStreamEvent_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  created_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.created_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  message
                     Reader.Read_Next;
                     Value.message := (Is_Set => True, Value => <>);
                     Input_ChatStreamEvent_message
                       (Reader, Value.message.Value, Success);

                  when 4      =>
                     --  done
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.done := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatStreamEvent;

   package ToolCall_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["function"]);

   package ToolCall_function_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["name", "description", "arguments"]);

   procedure Input_ToolCall
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ToolCall;
      Success : in out Boolean)
   is
      procedure Input_ToolCall_function
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ToolCall_function;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ToolCall_function_Minimal_Perfect_Hash.Get_Index
                      (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  name
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.name := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 2      =>
                        --  description
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.description := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 3      =>
                        --  arguments
                        Reader.Read_Next;
                        Input_Any_Value (Reader, Value.arguments, Success);

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ToolCall_function;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ToolCall_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  function
                     Reader.Read_Next;
                     Value.a_function := (Is_Set => True, Value => <>);
                     Input_ToolCall_function
                       (Reader, Value.a_function.Value, Success);

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ToolCall;

   package ChatMessage_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["role", "content", "images", "tool_calls"]);

   procedure Input_ChatMessage
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatMessage;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatMessage_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  role
                     Reader.Read_Next;
                     Input_ChatMessage_role (Reader, Value.role, Success);

                  when 2      =>
                     --  content
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.content := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  images
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.images.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.images.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  tool_calls
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.tool_calls.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : ToolCall;
                           begin
                              Input_ToolCall (Reader, Item, Success);
                              Value.tool_calls.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatMessage;

   package VersionResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["version"]);

   procedure Input_VersionResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out VersionResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 VersionResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  version
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.version := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_VersionResponse;

   package ListResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["models"]);

   procedure Input_ListResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ListResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ListResponse_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  models
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.models.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : ModelSummary;
                           begin
                              Input_ModelSummary (Reader, Item, Success);
                              Value.models.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ListResponse;

   package ToolDefinition_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["type", "function"]);

   package ToolDefinition_function_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["name", "description", "parameters"]);

   procedure Input_ToolDefinition
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ToolDefinition;
      Success : in out Boolean)
   is
      procedure Input_ToolDefinition_function
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ToolDefinition_function;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ToolDefinition_function_Minimal_Perfect_Hash.Get_Index
                      (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  name
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.name := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 2      =>
                        --  description
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.description := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 3      =>
                        --  parameters
                        Reader.Read_Next;
                        Input_Any_Value (Reader, Value.parameters, Success);

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ToolDefinition_function;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ToolDefinition_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  type
                     Reader.Read_Next;
                     if Reader.Is_String_Value
                       and then Reader.String_Value = "function"
                     then
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  function
                     Reader.Read_Next;
                     Input_ToolDefinition_function
                       (Reader, Value.a_function, Success);

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ToolDefinition;

   package ChatResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "created_at",
         "message",
         "done",
         "done_reason",
         "total_duration",
         "load_duration",
         "prompt_eval_count",
         "prompt_eval_duration",
         "eval_count",
         "eval_duration",
         "logprobs"]);

   package ChatResponse_message_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["role", "content", "thinking", "tool_calls", "images"]);

   procedure Input_ChatResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatResponse;
      Success : in out Boolean)
   is
      procedure Input_ChatResponse_message
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ChatResponse_message;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ChatResponse_message_Minimal_Perfect_Hash.Get_Index
                      (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  role
                        Reader.Read_Next;
                        if Reader.Is_String_Value
                          and then Reader.String_Value = "assistant"
                        then
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 2      =>
                        --  content
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.content := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 3      =>
                        --  thinking
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.thinking := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 4      =>
                        --  tool_calls
                        Reader.Read_Next;
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.tool_calls.Clear (Is_Null => False);
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : ToolCall;
                              begin
                                 Input_ToolCall (Reader, Item, Success);
                                 Value.tool_calls.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;

                     when 5      =>
                        --  images
                        Reader.Read_Next;
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.images.Clear;
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : VSS.Strings.Virtual_String;
                              begin
                                 if Reader.Is_String_Value then
                                    Item := Reader.String_Value;
                                    Reader.Read_Next;
                                 else
                                    Success := False;
                                 end if;
                                 Value.images.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ChatResponse_message;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatResponse_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  created_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.created_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  message
                     Reader.Read_Next;
                     Value.message := (Is_Set => True, Value => <>);
                     Input_ChatResponse_message
                       (Reader, Value.message.Value, Success);

                  when 4      =>
                     --  done
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.done := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  done_reason
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.done_reason := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  total_duration
                     Reader.Read_Next;
                     Value.total_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.total_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  load_duration
                     Reader.Read_Next;
                     Value.load_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.load_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  prompt_eval_count
                     Reader.Read_Next;
                     Value.prompt_eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 9      =>
                     --  prompt_eval_duration
                     Reader.Read_Next;
                     Value.prompt_eval_duration :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 10     =>
                     --  eval_count
                     Reader.Read_Next;
                     Value.eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 11     =>
                     --  eval_duration
                     Reader.Read_Next;
                     Value.eval_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 12     =>
                     --  logprobs
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.logprobs.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Logprob;
                           begin
                              Input_Logprob (Reader, Item, Success);
                              Value.logprobs.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatResponse;

   package DeleteRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["model"]);

   procedure Input_DeleteRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out DeleteRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 DeleteRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_DeleteRequest;

   package PsResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["models"]);

   procedure Input_PsResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PsResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 PsResponse_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  models
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.models.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Ps;
                           begin
                              Input_Ps (Reader, Item, Success);
                              Value.models.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_PsResponse;

   package EmbedResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "embeddings",
         "total_duration",
         "load_duration",
         "prompt_eval_count"]);

   procedure Input_EmbedResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out EmbedResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 EmbedResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  embeddings
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.embeddings.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Float_64;
                           begin
                              if Reader.Is_Number_Value then
                                 if Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Integer
                                 then
                                    Item :=
                                      Float_64
                                        (Reader.Number_Value.Integer_Value);
                                 elsif Reader.Number_Value.Kind
                                   = VSS.JSON.JSON_Float
                                 then
                                    Item := Reader.Number_Value.Float_Value;
                                 else
                                    Success := False;
                                 end if;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.embeddings.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  total_duration
                     Reader.Read_Next;
                     Value.total_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.total_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  load_duration
                     Reader.Read_Next;
                     Value.load_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.load_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  prompt_eval_count
                     Reader.Read_Next;
                     Value.prompt_eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_EmbedResponse;

   package GenerateStreamEvent_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "created_at",
         "response",
         "thinking",
         "done",
         "done_reason",
         "total_duration",
         "load_duration",
         "prompt_eval_count",
         "prompt_eval_duration",
         "eval_count",
         "eval_duration"]);

   procedure Input_GenerateStreamEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateStreamEvent;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 GenerateStreamEvent_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  created_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.created_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  response
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.response := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  thinking
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.thinking := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  done
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.done := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  done_reason
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.done_reason := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  total_duration
                     Reader.Read_Next;
                     Value.total_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.total_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  load_duration
                     Reader.Read_Next;
                     Value.load_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.load_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 9      =>
                     --  prompt_eval_count
                     Reader.Read_Next;
                     Value.prompt_eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 10     =>
                     --  prompt_eval_duration
                     Reader.Read_Next;
                     Value.prompt_eval_duration :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 11     =>
                     --  eval_count
                     Reader.Read_Next;
                     Value.eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 12     =>
                     --  eval_duration
                     Reader.Read_Next;
                     Value.eval_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_GenerateStreamEvent;

   package ShowResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["parameters",
         "license",
         "modified_at",
         "details",
         "template",
         "capabilities",
         "model_info"]);

   procedure Input_ShowResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ShowResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ShowResponse_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  parameters
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.parameters := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  license
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.license := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  modified_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.modified_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  details
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.details, Success);

                  when 5      =>
                     --  template
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.template := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  capabilities
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.capabilities.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.capabilities.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  model_info
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.model_info, Success);

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ShowResponse;

   package CopyRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["source", "destination"]);

   procedure Input_CopyRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CopyRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 CopyRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  source
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.source := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  destination
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.destination := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_CopyRequest;

   package WebFetchRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["url"]);

   procedure Input_WebFetchRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebFetchRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 WebFetchRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  url
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.url := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_WebFetchRequest;

   package StatusEvent_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["status", "digest", "total", "completed"]);

   procedure Input_StatusEvent
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out StatusEvent;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 StatusEvent_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  status
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.status := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  digest
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.digest := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  total
                     Reader.Read_Next;
                     Value.total := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.total.Value := Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  completed
                     Reader.Read_Next;
                     Value.completed := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.completed.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_StatusEvent;

   package ModelOptions_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["seed",
         "temperature",
         "top_k",
         "top_p",
         "min_p",
         "stop",
         "num_ctx",
         "num_predict"]);

   procedure Input_ModelOptions
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelOptions;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ModelOptions_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  seed
                     Reader.Read_Next;
                     Value.seed := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.seed.Value := Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  temperature
                     Reader.Read_Next;
                     Value.temperature := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value then
                        if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                        then
                           Value.temperature.Value :=
                             Float_64 (Reader.Number_Value.Integer_Value);
                        elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                        then
                           Value.temperature.Value :=
                             Reader.Number_Value.Float_Value;
                        else
                           Success := False;
                        end if;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  top_k
                     Reader.Read_Next;
                     Value.top_k := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.top_k.Value := Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  top_p
                     Reader.Read_Next;
                     Value.top_p := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value then
                        if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                        then
                           Value.top_p.Value :=
                             Float_64 (Reader.Number_Value.Integer_Value);
                        elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                        then
                           Value.top_p.Value :=
                             Reader.Number_Value.Float_Value;
                        else
                           Success := False;
                        end if;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  min_p
                     Reader.Read_Next;
                     Value.min_p := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value then
                        if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                        then
                           Value.min_p.Value :=
                             Float_64 (Reader.Number_Value.Integer_Value);
                        elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                        then
                           Value.min_p.Value :=
                             Reader.Number_Value.Float_Value;
                        else
                           Success := False;
                        end if;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  stop
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.stop.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.stop.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  num_ctx
                     Reader.Read_Next;
                     Value.num_ctx := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.num_ctx.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  num_predict
                     Reader.Read_Next;
                     Value.num_predict := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.num_predict.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ModelOptions;

   package WebSearchResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["results"]);

   procedure Input_WebSearchResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 WebSearchResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  results
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.results.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : WebSearchResult;
                           begin
                              Input_WebSearchResult (Reader, Item, Success);
                              Value.results.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_WebSearchResponse;

   package WebSearchResult_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["title", "url", "content"]);

   procedure Input_WebSearchResult
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchResult;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 WebSearchResult_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  title
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.title := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  url
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.url := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  content
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.content := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_WebSearchResult;

   package EmbedRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model", "input", "truncate", "dimensions", "keep_alive", "options"]);

   procedure Input_EmbedRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out EmbedRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 EmbedRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  input
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.input.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.input.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  truncate
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.truncate := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  dimensions
                     Reader.Read_Next;
                     Value.dimensions := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.dimensions.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  keep_alive
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.keep_alive := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  options
                     Reader.Read_Next;
                     Value.options := (Is_Set => True, Value => <>);
                     Input_ModelOptions (Reader, Value.options.Value, Success);

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_EmbedRequest;

   package TokenLogprob_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["token", "logprob", "bytes"]);

   procedure Input_TokenLogprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out TokenLogprob;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 TokenLogprob_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  token
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.token := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  logprob
                     Reader.Read_Next;
                     Value.logprob := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value then
                        if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                        then
                           Value.logprob.Value :=
                             Float_64 (Reader.Number_Value.Integer_Value);
                        elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                        then
                           Value.logprob.Value :=
                             Reader.Number_Value.Float_Value;
                        else
                           Success := False;
                        end if;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  bytes
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.bytes.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Integer_64;
                           begin
                              if Reader.Is_Number_Value
                                and then
                                  Reader.Number_Value.Kind
                                  = VSS.JSON.JSON_Integer
                              then
                                 Item := Reader.Number_Value.Integer_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.bytes.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_TokenLogprob;

   package ModelSummary_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["name", "modified_at", "size", "digest", "details"]);

   package ModelSummary_details_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["format",
         "family",
         "families",
         "parameter_size",
         "quantization_level"]);

   procedure Input_ModelSummary
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ModelSummary;
      Success : in out Boolean)
   is
      procedure Input_ModelSummary_details
        (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
         Value   : out ModelSummary_details;
         Success : in out Boolean) is
      begin
         if Success and Reader.Is_Start_Object then
            Reader.Read_Next;
         else
            Success := False;
         end if;

         while Success and not Reader.Is_End_Object loop
            if Reader.Is_Key_Name then
               declare
                  Index : constant Natural :=
                    ModelSummary_details_Minimal_Perfect_Hash.Get_Index
                      (Reader.Key_Name);
               begin

                  case Index is
                     when 1      =>
                        --  format
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.format := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 2      =>
                        --  family
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.family := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 3      =>
                        --  families
                        Reader.Read_Next;
                        if Success and Reader.Is_Start_Array then
                           Reader.Read_Next;
                           Value.families.Clear;
                           while Success and not Reader.Is_End_Array loop
                              declare
                                 Item : VSS.Strings.Virtual_String;
                              begin
                                 if Reader.Is_String_Value then
                                    Item := Reader.String_Value;
                                    Reader.Read_Next;
                                 else
                                    Success := False;
                                 end if;
                                 Value.families.Append (Item);
                              end;
                           end loop;
                           if Success then
                              Reader.Read_Next;  --  skip End_Array

                           end if;
                        else
                           Success := False;
                        end if;

                     when 4      =>
                        --  parameter_size
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.parameter_size := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when 5      =>
                        --  quantization_level
                        Reader.Read_Next;
                        if Reader.Is_String_Value then
                           Value.quantization_level := Reader.String_Value;
                           Reader.Read_Next;
                        else
                           Success := False;
                        end if;

                     when others =>
                        Reader.Read_Next;
                        Reader.Skip_Current_Value;
                  end case;
               end;
            else
               Success := False;
            end if;
         end loop;

         if Success then
            Reader.Read_Next;  --  skip End_Object

         end if;
      end Input_ModelSummary_details;

   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ModelSummary_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  name
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.name := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  modified_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.modified_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  size
                     Reader.Read_Next;
                     Value.size := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.size.Value := Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  digest
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.digest := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  details
                     Reader.Read_Next;
                     Value.details := (Is_Set => True, Value => <>);
                     Input_ModelSummary_details
                       (Reader, Value.details.Value, Success);

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ModelSummary;

   package ErrorResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["error"]);

   procedure Input_ErrorResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ErrorResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ErrorResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  error
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.error := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ErrorResponse;

   package WebSearchRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["query", "max_results"]);

   procedure Input_WebSearchRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebSearchRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 WebSearchRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  query
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.query := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  max_results
                     Reader.Read_Next;
                     Value.max_results := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.max_results.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_WebSearchRequest;

   package CreateRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "from",
         "template",
         "license",
         "system",
         "parameters",
         "messages",
         "quantize",
         "stream"]);

   procedure Input_CreateRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out CreateRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 CreateRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  from
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.from := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  template
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.template := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  license
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.license.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.license.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  system
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.system := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  parameters
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.parameters, Success);

                  when 7      =>
                     --  messages
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.messages.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : ChatMessage;
                           begin
                              Input_ChatMessage (Reader, Item, Success);
                              Value.messages.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  quantize
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.quantize := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 9      =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.stream := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_CreateRequest;

   package ChatRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "messages",
         "tools",
         "format",
         "options",
         "stream",
         "think",
         "keep_alive",
         "logprobs",
         "top_logprobs"]);

   procedure Input_ChatRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ChatRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ChatRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  messages
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.messages.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : ChatMessage;
                           begin
                              Input_ChatMessage (Reader, Item, Success);
                              Value.messages.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  tools
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.tools.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : ToolDefinition;
                           begin
                              Input_ToolDefinition (Reader, Item, Success);
                              Value.tools.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  format
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.format, Success);

                  when 5      =>
                     --  options
                     Reader.Read_Next;
                     Value.options := (Is_Set => True, Value => <>);
                     Input_ModelOptions (Reader, Value.options.Value, Success);

                  when 6      =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.stream := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  think
                     Reader.Read_Next;
                     Value.think := (Is_Set => True, Value => <>);
                     Input_ChatRequest_think
                       (Reader, Value.think.Value, Success);

                  when 8      =>
                     --  keep_alive
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.keep_alive := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 9      =>
                     --  logprobs
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.logprobs := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 10     =>
                     --  top_logprobs
                     Reader.Read_Next;
                     Value.top_logprobs := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.top_logprobs.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ChatRequest;

   package GenerateResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "created_at",
         "response",
         "thinking",
         "done",
         "done_reason",
         "total_duration",
         "load_duration",
         "prompt_eval_count",
         "prompt_eval_duration",
         "eval_count",
         "eval_duration",
         "logprobs"]);

   procedure Input_GenerateResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 GenerateResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  created_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.created_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  response
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.response := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  thinking
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.thinking := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  done
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.done := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  done_reason
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.done_reason := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  total_duration
                     Reader.Read_Next;
                     Value.total_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.total_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  load_duration
                     Reader.Read_Next;
                     Value.load_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.load_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 9      =>
                     --  prompt_eval_count
                     Reader.Read_Next;
                     Value.prompt_eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 10     =>
                     --  prompt_eval_duration
                     Reader.Read_Next;
                     Value.prompt_eval_duration :=
                       (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.prompt_eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 11     =>
                     --  eval_count
                     Reader.Read_Next;
                     Value.eval_count := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_count.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 12     =>
                     --  eval_duration
                     Reader.Read_Next;
                     Value.eval_duration := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.eval_duration.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 13     =>
                     --  logprobs
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.logprobs.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Logprob;
                           begin
                              Input_Logprob (Reader, Item, Success);
                              Value.logprobs.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_GenerateResponse;

   package ShowRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["model", "verbose"]);

   procedure Input_ShowRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out ShowRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 ShowRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  verbose
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.verbose := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_ShowRequest;

   package Logprob_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["token", "logprob", "bytes", "top_logprobs"]);

   procedure Input_Logprob
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Logprob;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 Logprob_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  token
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.token := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  logprob
                     Reader.Read_Next;
                     Value.logprob := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value then
                        if Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                        then
                           Value.logprob.Value :=
                             Float_64 (Reader.Number_Value.Integer_Value);
                        elsif Reader.Number_Value.Kind = VSS.JSON.JSON_Float
                        then
                           Value.logprob.Value :=
                             Reader.Number_Value.Float_Value;
                        else
                           Success := False;
                        end if;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  bytes
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.bytes.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : Integer_64;
                           begin
                              if Reader.Is_Number_Value
                                and then
                                  Reader.Number_Value.Kind
                                  = VSS.JSON.JSON_Integer
                              then
                                 Item := Reader.Number_Value.Integer_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.bytes.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  top_logprobs
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.top_logprobs.Clear (Is_Null => False);
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : TokenLogprob;
                           begin
                              Input_TokenLogprob (Reader, Item, Success);
                              Value.top_logprobs.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_Logprob;

   package WebFetchResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["title", "content", "links"]);

   procedure Input_WebFetchResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out WebFetchResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 WebFetchResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  title
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.title := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  content
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.content := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  links
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.links.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.links.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_WebFetchResponse;

   package Ps_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "size",
         "digest",
         "details",
         "expires_at",
         "size_vram",
         "context_length"]);

   procedure Input_Ps
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out Ps;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 Ps_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  size
                     Reader.Read_Next;
                     Value.size := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.size.Value := Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  digest
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.digest := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  details
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.details, Success);

                  when 5      =>
                     --  expires_at
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.expires_at := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 6      =>
                     --  size_vram
                     Reader.Read_Next;
                     Value.size_vram := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.size_vram.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  context_length
                     Reader.Read_Next;
                     Value.context_length := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.context_length.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_Ps;

   package StatusResponse_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["status"]);

   procedure Input_StatusResponse
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out StatusResponse;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 StatusResponse_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  status
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.status := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_StatusResponse;

   package PushRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["model", "insecure", "stream"]);

   procedure Input_PushRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PushRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 PushRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  insecure
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.insecure := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.stream := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_PushRequest;

   package PullRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash (["model", "insecure", "stream"]);

   procedure Input_PullRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out PullRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 PullRequest_Minimal_Perfect_Hash.Get_Index (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  insecure
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.insecure := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.stream := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_PullRequest;

   package GenerateRequest_Minimal_Perfect_Hash is new
     Minimal_Perfect_Hash
       (["model",
         "prompt",
         "suffix",
         "images",
         "format",
         "system",
         "stream",
         "think",
         "raw",
         "keep_alive",
         "options",
         "logprobs",
         "top_logprobs"]);

   procedure Input_GenerateRequest
     (Reader  : in out VSS.JSON.Pull_Readers.JSON_Pull_Reader'Class;
      Value   : out GenerateRequest;
      Success : in out Boolean) is
   begin
      if Success and Reader.Is_Start_Object then
         Reader.Read_Next;
      else
         Success := False;
      end if;

      while Success and not Reader.Is_End_Object loop
         if Reader.Is_Key_Name then
            declare
               Index : constant Natural :=
                 GenerateRequest_Minimal_Perfect_Hash.Get_Index
                   (Reader.Key_Name);
            begin

               case Index is
                  when 1      =>
                     --  model
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.model := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 2      =>
                     --  prompt
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.prompt := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 3      =>
                     --  suffix
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.suffix := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 4      =>
                     --  images
                     Reader.Read_Next;
                     if Success and Reader.Is_Start_Array then
                        Reader.Read_Next;
                        Value.images.Clear;
                        while Success and not Reader.Is_End_Array loop
                           declare
                              Item : VSS.Strings.Virtual_String;
                           begin
                              if Reader.Is_String_Value then
                                 Item := Reader.String_Value;
                                 Reader.Read_Next;
                              else
                                 Success := False;
                              end if;
                              Value.images.Append (Item);
                           end;
                        end loop;
                        if Success then
                           Reader.Read_Next;  --  skip End_Array

                        end if;
                     else
                        Success := False;
                     end if;

                  when 5      =>
                     --  format
                     Reader.Read_Next;
                     Input_Any_Value (Reader, Value.format, Success);

                  when 6      =>
                     --  system
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.system := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 7      =>
                     --  stream
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.stream := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 8      =>
                     --  think
                     Reader.Read_Next;
                     Value.think := (Is_Set => True, Value => <>);
                     Input_GenerateRequest_think
                       (Reader, Value.think.Value, Success);

                  when 9      =>
                     --  raw
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.raw := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 10     =>
                     --  keep_alive
                     Reader.Read_Next;
                     if Reader.Is_String_Value then
                        Value.keep_alive := Reader.String_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 11     =>
                     --  options
                     Reader.Read_Next;
                     Value.options := (Is_Set => True, Value => <>);
                     Input_ModelOptions (Reader, Value.options.Value, Success);

                  when 12     =>
                     --  logprobs
                     Reader.Read_Next;
                     if Reader.Is_Boolean_Value then
                        Value.logprobs := Reader.Boolean_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when 13     =>
                     --  top_logprobs
                     Reader.Read_Next;
                     Value.top_logprobs := (Is_Set => True, Value => <>);
                     if Reader.Is_Number_Value
                       and then
                         Reader.Number_Value.Kind = VSS.JSON.JSON_Integer
                     then
                        Value.top_logprobs.Value :=
                          Reader.Number_Value.Integer_Value;
                        Reader.Read_Next;
                     else
                        Success := False;
                     end if;

                  when others =>
                     Reader.Read_Next;
                     Reader.Skip_Current_Value;
               end case;
            end;
         else
            Success := False;
         end if;
      end loop;

      if Success then
         Reader.Read_Next;  --  skip End_Object

      end if;
   end Input_GenerateRequest;

end Ollama_API.Types.Inputs;
