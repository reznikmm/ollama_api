with VSS.IRIs;
with VSS.Strings;
with VSS.Stream_Element_Vectors;

procedure HTTP_Post_Request
  (URL           : VSS.IRIs.IRI;
   Content_Type  : VSS.Strings.Virtual_String;
   Authorization : VSS.Strings.Virtual_String;
   Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
   Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
   Status_Code   : out Natural);
