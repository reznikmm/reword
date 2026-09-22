--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

with VSS.Strings;

package Reword.Markdown_Files is

   procedure Translate
     (Text       : VSS.Strings.Virtual_String;
      Server_URL : VSS.Strings.Virtual_String;
      Result     : out VSS.Strings.Virtual_String;
      Error      : out VSS.Strings.Virtual_String);
   --  Translate a Markdown document block by block, leaving fenced and
   --  indented code blocks untouched.
   --
   --  * @param Text - Markdown source text
   --  * @param Server_URL - URL of the `/v1/chat/completions` endpoint used
   --    to translate each non-code block, see Reword.Translate
   --  * @param Result - Translated Markdown text; empty when Error is not
   --    empty
   --  * @param Error - Empty on success, or a description of what went
   --    wrong translating one of the blocks

end Reword.Markdown_Files;
