pragma Ada_2022;

with Ada.Wide_Wide_Text_IO;
with HTTP_Post_Request;
with Ollama_API.Types;
with Ollama_API.Chats;
with VSS.JSON.Streams;
with VSS.Strings.Conversions;

procedure Demos is
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
   Response : Ollama_API.Types.ChatResponse;
   Ok       : Boolean;
   Messages : Ollama_API.Types.ChatMessage_Vector :=
     [(role       => Ollama_API.Types.user,
       content    => "What is 765432 minus 111222?",
       others     => <>)];
begin
   Server.Set_Request_Handler (HTTP_Post_Request'Access);
   Ollama_API.Chats.Chat
     (Server,
      Model        => "llama3.1:8b",
      Messages     => Messages,
      Tools        =>
        [(a_function =>
              (name        => "sub_two_numbers",
               description => "Subtract two numbers",
               parameters  => Server.To_JSON_Scheme
                 ([(Name => "a",
                    Description => "The first number",
                    Required    => True),
                   (Name => "b",
                    Description => "The second number",
                    Required    => True)])))],
      Stream       => False,
      Keep_Alive   => "15m",
      Response     => Response,
      Success      => Ok);

   if Response.message.Is_Set then
      Ada.Wide_Wide_Text_IO.Put_Line ("Response:");
      Print (Response.message.Value);

      Messages.Append
        ((role       => Ollama_API.Types.assistant,
          tool_calls => Response.message.Value.tool_calls,
          others     => <>));
   end if;

   Messages.Append
     ((role         => Ollama_API.Types.tool,
       content      => "654210",
       tool_name    => "sub_two_numbers",
       tool_call_id => Response.message.Value.tool_calls (1).id,
       others       => <>));

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
