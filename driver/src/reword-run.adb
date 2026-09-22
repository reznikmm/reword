--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

pragma Ada_2022;

with Ada.Command_Line;

with VSS.Characters;
with VSS.Strings;
with VSS.Text_Streams.File_Input;
with VSS.Text_Streams.Standards;

with Reword.Command_Line;
with Reword.Markdown_Files;

procedure Reword.Run is
   Input_File  : constant VSS.Strings.Virtual_String :=
     Reword.Command_Line.Input_File;
   Input       : VSS.Text_Streams.File_Input.File_Input_Text_Stream;
   Output      : VSS.Text_Streams.Output_Text_Stream'Class :=
     VSS.Text_Streams.Standards.Standard_Output;
   Error_Sink  : VSS.Text_Streams.Output_Text_Stream'Class :=
     VSS.Text_Streams.Standards.Standard_Error;
   Text        : VSS.Strings.Virtual_String;
   Item        : VSS.Characters.Virtual_Character;
   Ok          : Boolean := True;
   Translation : VSS.Strings.Virtual_String;
   Error       : VSS.Strings.Virtual_String;
begin
   Input.Open (Input_File);

   while not Input.Is_End_Of_Stream loop
      Input.Get (Item, Ok);
      exit when not Ok;
      Text.Append (Item);
   end loop;

   if Input.Has_Error then
      Error_Sink.Put_Line (Input.Error_Message, Ok);
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   Input.Close;

   if Input_File.Ends_With (".md") then
      Reword.Markdown_Files.Translate
        (Text,
         Server_URL => Reword.Command_Line.Server_URL,
         Result     => Translation,
         Error      => Error);
   else
      Reword.Translate
        (Text,
         Server_URL => Reword.Command_Line.Server_URL,
         Result     => Translation,
         Error      => Error);
   end if;

   if not Error.Is_Empty then
      Error_Sink.Put_Line (Error, Ok);
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   Output.Put_Line (Translation, Ok);
end Reword.Run;
