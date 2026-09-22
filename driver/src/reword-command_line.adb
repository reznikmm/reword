--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

pragma Ada_2022;

with VSS.Command_Line;

package body Reword.Command_Line is

   Input_File_Option : constant VSS.Command_Line.Positional_Option :=
     (Name        => "input-file",
      Description => "Path to the file with the text to translate");

   ----------------
   -- Input_File --
   ----------------

   function Input_File return VSS.Strings.Virtual_String is
   begin
      VSS.Command_Line.Add_Help_Option;
      VSS.Command_Line.Add_Option (Input_File_Option);
      VSS.Command_Line.Process;

      if not VSS.Command_Line.Is_Specified (Input_File_Option) then
         VSS.Command_Line.Report_Error ("input file is not specified");
      end if;

      return VSS.Command_Line.Value (Input_File_Option);
   end Input_File;

end Reword.Command_Line;
