--
--  Copyright (c) 2025-2026, Ollama
--
--  SPDX-License-Identifier: MIT
--

pragma Style_Checks ("M99");  --  suppress style warning unitl gnatpp is fixed
with Ada.Unchecked_Deallocation;

package body Ollama_API.Types is
   procedure Free is new
     Ada.Unchecked_Deallocation (Logprob_Array, Logprob_Array_Access);

   overriding
   procedure Adjust (Self : in out Logprob_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new Logprob_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Logprob_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return Logprob_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : Logprob_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : Logprob_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out Logprob_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out Logprob_Vector; Value : Logprob) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / Logprob'Size);
      Self_Data_Saved : Logprob_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new Logprob_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new Logprob_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_Logprob_Variable_Reference
     (Self : aliased in out Logprob_Vector; Index : Positive)
      return Logprob_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_Logprob_Constant_Reference
     (Self : aliased Logprob_Vector; Index : Positive)
      return Logprob_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (TokenLogprob_Array,
        TokenLogprob_Array_Access);

   overriding
   procedure Adjust (Self : in out TokenLogprob_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new TokenLogprob_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out TokenLogprob_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return TokenLogprob_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : TokenLogprob_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : TokenLogprob_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out TokenLogprob_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out TokenLogprob_Vector; Value : TokenLogprob)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / TokenLogprob'Size);
      Self_Data_Saved : TokenLogprob_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new TokenLogprob_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new TokenLogprob_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_TokenLogprob_Variable_Reference
     (Self : aliased in out TokenLogprob_Vector; Index : Positive)
      return TokenLogprob_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_TokenLogprob_Constant_Reference
     (Self : aliased TokenLogprob_Vector; Index : Positive)
      return TokenLogprob_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ToolDefinition_Array,
        ToolDefinition_Array_Access);

   overriding
   procedure Adjust (Self : in out ToolDefinition_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new ToolDefinition_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ToolDefinition_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ToolDefinition_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ToolDefinition_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ToolDefinition_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out ToolDefinition_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self : in out ToolDefinition_Vector; Value : ToolDefinition)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ToolDefinition'Size);
      Self_Data_Saved : ToolDefinition_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ToolDefinition_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new ToolDefinition_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ToolDefinition_Variable_Reference
     (Self : aliased in out ToolDefinition_Vector; Index : Positive)
      return ToolDefinition_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ToolDefinition_Constant_Reference
     (Self : aliased ToolDefinition_Vector; Index : Positive)
      return ToolDefinition_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (WebSearchResult_Array,
        WebSearchResult_Array_Access);

   overriding
   procedure Adjust (Self : in out WebSearchResult_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new WebSearchResult_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out WebSearchResult_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return WebSearchResult_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : WebSearchResult_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : WebSearchResult_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out WebSearchResult_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self : in out WebSearchResult_Vector; Value : WebSearchResult)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / WebSearchResult'Size);
      Self_Data_Saved : WebSearchResult_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new WebSearchResult_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new WebSearchResult_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_WebSearchResult_Variable_Reference
     (Self : aliased in out WebSearchResult_Vector; Index : Positive)
      return WebSearchResult_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_WebSearchResult_Constant_Reference
     (Self : aliased WebSearchResult_Vector; Index : Positive)
      return WebSearchResult_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (Ps_Array, Ps_Array_Access);

   overriding
   procedure Adjust (Self : in out Ps_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new Ps_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Ps_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return Ps_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : Ps_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : Ps_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out Ps_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out Ps_Vector; Value : Ps) is
      Init_Length     : constant Positive := Positive'Max (2, 256 / Ps'Size);
      Self_Data_Saved : Ps_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new Ps_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new Ps_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_Ps_Variable_Reference
     (Self : aliased in out Ps_Vector; Index : Positive)
      return Ps_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_Ps_Constant_Reference
     (Self : aliased Ps_Vector; Index : Positive) return Ps_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (ChatMessage_Array, ChatMessage_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatMessage_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new ChatMessage_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatMessage_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatMessage_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ChatMessage_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatMessage_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out ChatMessage_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out ChatMessage_Vector; Value : ChatMessage) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatMessage'Size);
      Self_Data_Saved : ChatMessage_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ChatMessage_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new ChatMessage_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatMessage_Variable_Reference
     (Self : aliased in out ChatMessage_Vector; Index : Positive)
      return ChatMessage_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatMessage_Constant_Reference
     (Self : aliased ChatMessage_Vector; Index : Positive)
      return ChatMessage_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (ToolCall_Array, ToolCall_Array_Access);

   overriding
   procedure Adjust (Self : in out ToolCall_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new ToolCall_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ToolCall_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ToolCall_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ToolCall_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ToolCall_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out ToolCall_Vector; Is_Null : Boolean := True)
   is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out ToolCall_Vector; Value : ToolCall) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ToolCall'Size);
      Self_Data_Saved : ToolCall_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ToolCall_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new ToolCall_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ToolCall_Variable_Reference
     (Self : aliased in out ToolCall_Vector; Index : Positive)
      return ToolCall_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ToolCall_Constant_Reference
     (Self : aliased ToolCall_Vector; Index : Positive)
      return ToolCall_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (Integer_64_Array, Integer_64_Array_Access);

   overriding
   procedure Adjust (Self : in out Integer_64_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new Integer_64_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Integer_64_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return Integer_64_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : Integer_64_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : Integer_64_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out Integer_64_Vector; Is_Null : Boolean := True)
   is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out Integer_64_Vector; Value : Integer_64) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / Integer_64'Size);
      Self_Data_Saved : Integer_64_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new Integer_64_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new Integer_64_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_Float_64_Variable_Reference
     (Self : aliased in out Float_64_Vector; Index : Positive)
      return Float_64_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_Float_64_Constant_Reference
     (Self : aliased Float_64_Vector; Index : Positive)
      return Float_64_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (Float_64_Array, Float_64_Array_Access);

   overriding
   procedure Adjust (Self : in out Float_64_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new Float_64_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Float_64_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return Float_64_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : Float_64_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : Float_64_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out Float_64_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out Float_64_Vector; Value : Float_64) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / Float_64'Size);
      Self_Data_Saved : Float_64_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new Float_64_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new Float_64_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_Integer_64_Variable_Reference
     (Self : aliased in out Integer_64_Vector; Index : Positive)
      return Integer_64_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_Integer_64_Constant_Reference
     (Self : aliased Integer_64_Vector; Index : Positive)
      return Integer_64_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ModelSummary_Array,
        ModelSummary_Array_Access);

   overriding
   procedure Adjust (Self : in out ModelSummary_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new ModelSummary_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ModelSummary_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ModelSummary_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ModelSummary_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ModelSummary_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out ModelSummary_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out ModelSummary_Vector; Value : ModelSummary)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ModelSummary'Size);
      Self_Data_Saved : ModelSummary_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ModelSummary_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new ModelSummary_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ModelSummary_Variable_Reference
     (Self : aliased in out ModelSummary_Vector; Index : Positive)
      return ModelSummary_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ModelSummary_Constant_Reference
     (Self : aliased ModelSummary_Vector; Index : Positive)
      return ModelSummary_Constant_Reference
   is (Element => Self.Data (Index)'Access);

end Ollama_API.Types;
