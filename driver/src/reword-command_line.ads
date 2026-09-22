--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

with VSS.Strings;

package Reword.Command_Line is

   function Input_File return VSS.Strings.Virtual_String;
   --  Parse the command line and return the path to the file with the
   --  text to translate, given as the sole positional argument.
   --
   --  Terminates the application with a usage message on standard error
   --  when the input file is missing, an unknown option is given, or
   --  --help is requested.

end Reword.Command_Line;
