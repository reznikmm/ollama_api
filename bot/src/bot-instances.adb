--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------
pragma Ada_2022;

with Bot.Read_File;
with Bot.Tasks;

with Ollama_API.Chats;
with Ollama_API.Types;

with VSS.Text_Streams.Standards;
with VSS.Text_Streams;

package body Bot.Instances is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self  : in out Bot_Instance'Class;
      Error : out VSS.Strings.Virtual_String) is
   begin
      Self.Ollama.Set_Request_Handler (Self.HTTP'Unchecked_Access);
      Self.Tools.Register ("write_todo", Self.Todo'Unchecked_Access);
      Self.Tools.Register ("current_time", Self.Current_Time'Unchecked_Access);

      for J in Self.Prompts'Range loop
         Bot.Read_File (Bot.Prompts.File_Name (J), Self.Prompts (J), Error);
         exit when not Error.Is_Empty;
      end loop;
   end Initialize;

   ---------
   -- Run --
   ---------

   procedure Run (Self : in out Bot_Instance'Class) is
      use all type VSS.Strings.Virtual_String;
      use all type Bot.Prompts.Predefined_Prompt;

      Standard_Error : VSS.Text_Streams.Output_Text_Stream'Class :=
        VSS.Text_Streams.Standards.Standard_Error;

      Request  : VSS.Strings.Virtual_String;
      Error    : VSS.Strings.Virtual_String;
      Ok       : Boolean := True;
      Messages : Ollama_API.Types.ChatMessage_Vector;
      Response : Ollama_API.Types.ChatResponse;
      Bot_Task : Bot.Tasks.Bot_Task;
   begin
      Bot.Read_File ("request.txt", Request, Error);

      if not Error.Is_Empty then
         Standard_Error.Put_Line (Error, Ok);
         return;
      end if;

      Messages :=
        [(role    => Ollama_API.Types.user,
          content => Request,
          others  => <>)];

      Ollama_API.Chats.Chat
        (Self.Ollama,
         Model      => Self.Model,
         Messages   => Messages,
         Tools      => Self.Tools.All_Tools,
         Format     => Ollama_API.JSON_Format,
         Stream     => False,
         Keep_Alive => "15m",
         Response   => Response,
         Success    => Ok);

      Messages.Append
        ((role       => Ollama_API.Types.assistant,
          tool_calls => Response.message.Value.tool_calls,
          others     => <>));

      for J in 1 .. Response.message.Value.tool_calls.Length loop
         declare
            Message : Ollama_API.Types.ChatMessage;
         begin
            Self.Tools.Execute
              (Response.message.Value.tool_calls (J), Message);
            Messages.Append (Message);
         end;
      end loop;

      declare
         Response : Ollama_API.Types.ChatResponse;
      begin
         Ollama_API.Chats.Chat
           (Self.Ollama,
            Model        => Self.Model,
            Messages     => Messages,
            Tools        => Self.Tools.All_Tools,
            --  Format       => Ollama_API.JSON_Format,
            Stream       => False,
            Keep_Alive   => "15m",
            Response     => Response,
            Success      => Ok);
      end;
      --  if Ok and then Response.message.Is_Set then
      --     Bot.Tasks.Decode_JSON
      --       (JSON   => Response.message.Value.content,
      --        Result => Bot_Task,
      --        Error  => Error);
      --
      --     if Error.Is_Empty then
      --        Bot_Task.Description := Request;
      --
      --        Standard_Error.Put_Line
      --          ("Task decoded successfully", Ok);
      --        Standard_Error.Put ("Title: ", Ok);
      --        Standard_Error.Put_Line (Bot_Task.Title, Ok);
      --        Standard_Error.Put ("Description: ", Ok);
      --        Standard_Error.Put_Line (Bot_Task.Description, Ok);
      --        Standard_Error.Put ("Definition of Done: ", Ok);
      --        Standard_Error.Put_Line (Bot_Task.Definition_Of_Done, Ok);
      --        Standard_Error.Put ("Activation Condition: ", Ok);
      --        Standard_Error.Put_Line (Bot_Task.Activation_Condition, Ok);
      --
      --        for Item of Bot_Task.Categories loop
      --           Standard_Error.Put_Line ("Category: " & Item, Ok);
      --        end loop;
      --     else
      --        Standard_Error.Put_Line (Error, Ok);
      --     end if;
      --  end if;
   end Run;

end Bot.Instances;
