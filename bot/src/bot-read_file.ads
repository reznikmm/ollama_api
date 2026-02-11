--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.Strings;

procedure Bot.Read_File
  (Name  : VSS.Strings.Virtual_String;
   Text  : out VSS.Strings.Virtual_String;
   Error : out VSS.Strings.Virtual_String);
