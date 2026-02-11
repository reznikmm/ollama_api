--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with VSS.JSON.Pull_Readers.Simple;
with VSS.JSON.Push_Writers;
with VSS.JSON.Streams;
with VSS.Stream_Element_Vectors;
with VSS.Text_Streams.Memory_UTF8_Input;
with VSS.Text_Streams.Memory_UTF8_Output;

with Ollama_API.HTTP_Requests;
with Ollama_API.Types.Inputs;
with Ollama_API.Types.Outputs;

package body Ollama_API is

   ----------
   -- Chat --
   ----------

   procedure Chat
     (Self     : in out Server'Class;
      Request  : Ollama_API.Types.ChatRequest;
      Response : out Ollama_API.Types.ChatResponse;
      Success  : out Boolean)
   is
      Writer : VSS.JSON.Push_Writers.JSON_Simple_Push_Writer;
      Output : aliased
        VSS.Text_Streams.Memory_UTF8_Output.Memory_UTF8_Output_Stream;
      Data   : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Input  : aliased
        VSS.Text_Streams.Memory_UTF8_Input.Memory_UTF8_Input_Stream;
      Reader : VSS.JSON.Pull_Readers.Simple.JSON_Simple_Pull_Reader;
      Code   : Natural;
   begin
      Writer.Set_Stream (Output'Unchecked_Access);
      Writer.Start_Document;
      Ollama_API.Types.Outputs.Output_ChatRequest (Writer, Request);
      Writer.End_Document;
      Self.HTTP.Post
        (URL           => Self.URL,
         Content_Type  => "application/json",
         Authorization => "ollama",
         Output        => Output.Buffer,
         Response      => Data,
         Status_Code   => Code);

      if Code = 200 then
         Input.Set_Data (Data);
         Reader.Set_Stream (Input'Unchecked_Access);
         Reader.Read_Next;
         --  pragma Assert (Reader.Is_Start_Document);
         Success := Reader.Is_Start_Document;
         Reader.Read_Next;
         Ollama_API.Types.Inputs.Input_ChatResponse
           (Reader, Response, Success);
      end if;
   end Chat;

   -----------------
   -- JSON_Format --
   -----------------

   function JSON_Format return Ollama_API.Types.Any_Object is
     [(VSS.JSON.Streams.String_Value, "json")];

   -------------------------
   -- Set_Request_Handler --
   -------------------------

   procedure Set_Request_Handler
     (Self  : in out Server'Class;
      Value : not null HTTP_Request_Access) is
   begin
      Self.HTTP := Value;
   end Set_Request_Handler;

   -------------
   -- Set_URL --
   -------------

   procedure Set_URL
     (Self  : in out Server'Class;
      Value : VSS.IRIs.IRI) is
   begin
      Self.URL := Value;
   end Set_URL;

   -------------
   -- Set_URL --
   -------------

   procedure Set_URL
     (Self  : in out Server'Class;
      Value : VSS.Strings.Virtual_String) is
   begin
      Self.Set_URL (VSS.IRIs.To_IRI (Value));
   end Set_URL;

end Ollama_API;
