--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with Bot.Instances;
with VSS.Strings;
with VSS.Text_Streams.Standards;

procedure Bot.Driver is
   Standard_Error : VSS.Text_Streams.Output_Text_Stream'Class :=
     VSS.Text_Streams.Standards.Standard_Error;

   Ok : Boolean := True;
   Me : Bot.Instances.Bot_Instance;
   Error : VSS.Strings.Virtual_String;
begin
   Me.Initialize (Error);

   if Error.Is_Empty then
      Me.Run;
   else
      Standard_Error.Put_Line (Error, Ok);
   end if;
end Bot.Driver;
