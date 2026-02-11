--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ada.Wide_Wide_Text_IO;
with HTTP_Requests;
with Ollama_API.Types;
with Ollama_API.Chats;
with Ollama_API.Tools;
with VSS.JSON.Streams;
with VSS.Strings.Conversions;

with Concat_Tools;

procedure Demos is

   Concat : Concat_Tools.Concat_Tool renames Concat_Tools.Tool;

   Tools : Ollama_API.Tools.Tool_Register;

   procedure Print (Message : Ollama_API.Types.ChatResponse_message) is
      procedure Print (Call : Ollama_API.Types.ToolCall_function);

      procedure Print (Call : Ollama_API.Types.ToolCall_function) is
         use all type VSS.JSON.Streams.JSON_Stream_Element_Kind;
      begin
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String
              (Call.name));
         Ada.Wide_Wide_Text_IO.Put (" (");

         for Item of Call.arguments loop
            case Item.Kind is
               when String_Value =>
                  Ada.Wide_Wide_Text_IO.Put
                    (VSS.Strings.Conversions.To_Wide_Wide_String
                       (Item.String_Value));
                  Ada.Wide_Wide_Text_IO.Put (", ");
               when Key_Name =>
                  Ada.Wide_Wide_Text_IO.Put
                    (VSS.Strings.Conversions.To_Wide_Wide_String
                       (Item.Key_Name));
                  Ada.Wide_Wide_Text_IO.Put (" => ");
               when others =>
                  null;
            end case;
         end loop;
         Ada.Wide_Wide_Text_IO.Put (")");
      end Print;

   begin
      if not Message.content.Is_Empty then
         Ada.Wide_Wide_Text_IO.Put ("Content: ");
         Ada.Wide_Wide_Text_IO.Put
           (VSS.Strings.Conversions.To_Wide_Wide_String (Message.content));
      end if;

      if not Message.tool_calls.Is_Null then
         for J in 1 .. Message.tool_calls.Length
           when Message.tool_calls (J).a_function.Is_Set
         loop
            Ada.Wide_Wide_Text_IO.Put ("Tool call: ");

            if Message.tool_calls (J).a_function.Is_Set then
               Print (Message.tool_calls (J).a_function.Value);
            end if;

            Ada.Wide_Wide_Text_IO.Put (" [");
            Ada.Wide_Wide_Text_IO.Put
              (VSS.Strings.Conversions.To_Wide_Wide_String
                 (Message.tool_calls (J).id));
            Ada.Wide_Wide_Text_IO.Put_Line ("]");
         end loop;
      end if;
   end Print;

   Server   : Ollama_API.Server;
   HTTP     : aliased HTTP_Requests.HTTP_Request;
   Response : Ollama_API.Types.ChatResponse;
   Ok       : Boolean;
   Messages : Ollama_API.Types.ChatMessage_Vector :=
     [(role       => Ollama_API.Types.user,
       content    => "What is 765432 concatinated with 111222?",
       others     => <>)];
begin
   Server.Set_Request_Handler (HTTP'Unchecked_Access);
   Tools.Register ("concat", Concat'Unrestricted_Access);

   Ollama_API.Chats.Chat
     (Server,
      Model        => "llama3.1:8b",
      Messages     => Messages,
      Tools        => Tools.All_Tools,
      Stream       => False,
      Keep_Alive   => "15m",
      Response     => Response,
      Success      => Ok);

   Ada.Wide_Wide_Text_IO.Put_Line ("Response:");
   Print (Response.message.Value);

   Messages.Append
     ((role       => Ollama_API.Types.assistant,
       tool_calls => Response.message.Value.tool_calls,
       others     => <>));

   for J in 1 .. Response.message.Value.tool_calls.Length loop
      declare
         Message : Ollama_API.Types.ChatMessage;
      begin
         Tools.Execute (Response.message.Value.tool_calls (J), Message);
         Messages.Append (Message);
      end;
   end loop;

   declare
      Response : Ollama_API.Types.ChatResponse;
   begin
      Ollama_API.Chats.Chat
        (Server,
         Model        => "llama3.1:8b",
         Messages     => Messages,
         Format       => Ollama_API.JSON_Format,
         Stream       => False,
         Keep_Alive   => "15m",
         Response     => Response,
         Success      => Ok);

      Ada.Wide_Wide_Text_IO.Put_Line ("Response[2]:");
      Print (Response.message.Value);
   end;
end Demos;
