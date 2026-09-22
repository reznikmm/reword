--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

pragma Ada_2022;

with VSS.Command_Line;

package body Reword.Command_Line is

   Input_File_Option : constant VSS.Command_Line.Positional_Option :=
     (Name        => "input-file",
      Description => "Path to the file with the text to translate");

   Server_URL_Option : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "",
      Long_Name   => "server-url",
      Value_Name  => "url",
      Description =>
        "URL of the OpenAI-compatible chat completions endpoint");

   Default_Server_URL : constant VSS.Strings.Virtual_String :=
     "http://localhost:8080/v1/chat/completions";

   Processed : Boolean := False;

   procedure Parse_Command_Line
     with Post => Processed;
   --  Registers all options and parses the command line. Does nothing on
   --  subsequent calls, so it is safe to call from every accessor.

   -------------------------
   -- Parse_Command_Line --
   -------------------------

   procedure Parse_Command_Line is
   begin
      if Processed then
         return;
      end if;

      VSS.Command_Line.Add_Help_Option;
      VSS.Command_Line.Add_Option (Input_File_Option);
      VSS.Command_Line.Add_Option (Server_URL_Option);
      VSS.Command_Line.Process;

      if not VSS.Command_Line.Is_Specified (Input_File_Option) then
         VSS.Command_Line.Report_Error ("input file is not specified");
      end if;

      Processed := True;
   end Parse_Command_Line;

   ----------------
   -- Input_File --
   ----------------

   function Input_File return VSS.Strings.Virtual_String is
   begin
      Parse_Command_Line;

      return VSS.Command_Line.Value (Input_File_Option);
   end Input_File;

   ----------------
   -- Server_URL --
   ----------------

   function Server_URL return VSS.Strings.Virtual_String is
   begin
      Parse_Command_Line;

      if VSS.Command_Line.Is_Specified (Server_URL_Option) then
         return VSS.Command_Line.Value (Server_URL_Option);
      else
         return Default_Server_URL;
      end if;
   end Server_URL;

end Reword.Command_Line;
