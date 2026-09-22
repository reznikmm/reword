--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

pragma Ada_2022;

with Markdown.Blocks;
with Markdown.Documents;
with Markdown.Parsers;
with Markdown.Parsers.Enable_GFM;
with VSS.String_Vectors;

package body Reword.Markdown_Files is

   ---------------
   -- Translate --
   ---------------

   procedure Translate
     (Text       : VSS.Strings.Virtual_String;
      Server_URL : VSS.Strings.Virtual_String;
      Result     : out VSS.Strings.Virtual_String;
      Error      : out VSS.Strings.Virtual_String)
   is
      Lines     : constant VSS.String_Vectors.Virtual_String_Vector :=
        Text.Split_Lines (Keep_Terminator => False);
      Parser    : Markdown.Parsers.Markdown_Parser;
      Output    : VSS.String_Vectors.Virtual_String_Vector;
      Next_Line : Positive := 1;

      procedure Append_Source_Lines (From : Positive; To : Natural);
      --  Append original Lines (From .. To) to Output unchanged

      procedure Translate_Block (Block : Markdown.Blocks.Block);
      --  Translate a single non-code block and append the result to Output;
      --  sets Error on failure

      -------------------------
      -- Append_Source_Lines --
      -------------------------

      procedure Append_Source_Lines (From : Positive; To : Natural) is
      begin
         if From <= To then
            Output.Append (Lines.Slice (From, To));
         end if;
      end Append_Source_Lines;

      ---------------------
      -- Translate_Block --
      ---------------------

      procedure Translate_Block (Block : Markdown.Blocks.Block) is
         Source     : constant VSS.Strings.Virtual_String :=
           Lines.Slice (Block.First_Line, Block.Last_Line).Join_Lines
             (VSS.Strings.LF, Terminate_Last => False);
         Translated : VSS.Strings.Virtual_String;
      begin
         Reword.Translate
           (Source,
            Server_URL => Server_URL,
            Result     => Translated,
            Error      => Error);

         if Error.Is_Empty then
            Output.Append (Translated.Split_Lines (Keep_Terminator => False));
         end if;
      end Translate_Block;

   begin
      Markdown.Parsers.Initialize;
      Markdown.Parsers.Enable_GFM (Parser);

      for Line of Lines loop
         Parser.Parse_Line (Line);
      end loop;

      declare
         Document : constant Markdown.Documents.Document := Parser.Document;
      begin
         for Block of Document loop
            Append_Source_Lines (Next_Line, Block.First_Line - 1);

            if Block.Is_Fenced_Code_Block or else Block.Is_Indented_Code_Block
            then
               Append_Source_Lines (Block.First_Line, Block.Last_Line);
            else
               Translate_Block (Block);

               exit when not Error.Is_Empty;
            end if;

            Next_Line := Block.Last_Line + 1;
         end loop;
      end;

      if not Error.Is_Empty then
         Result := VSS.Strings.Empty_Virtual_String;

         return;
      end if;

      Append_Source_Lines (Next_Line, Lines.Length);

      Result := Output.Join_Lines (VSS.Strings.LF, Terminate_Last => False);
      Error  := VSS.Strings.Empty_Virtual_String;
   end Translate;

end Reword.Markdown_Files;
