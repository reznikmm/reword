--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.String_Vectors;
with VSS.Strings;

package Reword is

   procedure Translate
     (Text            : VSS.Strings.Virtual_String;
      Target_Language : VSS.Strings.Virtual_String := "Ukrainian";
      Server_URL      : VSS.Strings.Virtual_String :=
        "http://host.containers.internal:8080/v1/chat/completions";
      Model           : VSS.Strings.Virtual_String := "Hy-MT2-30B-A3B";
      Stop            : VSS.String_Vectors.Virtual_String_Vector :=
        ["<eos:6124c78e>", "<｜hy_User｜>", "<｜hy_Assistant｜>"];
      Result          : out VSS.Strings.Virtual_String;
      Error           : out VSS.Strings.Virtual_String);
   --  Translate Text into Target_Language using an OpenAI-compatible chat
   --  completions server (such as llama.cpp's llama-server) reachable at
   --  Server_URL.
   --
   --  * @param Text - Plain text to translate
   --  * @param Target_Language - Full name of the target language, in
   --    English (as expected by the Hy-MT2 translation prompt template)
   --  * @param Server_URL - URL of the `/v1/chat/completions` endpoint
   --  * @param Model - Model name to send in the request
   --  * @param Stop - Sequences where the server should stop generating
   --    further tokens; defaults to the Hy-MT2-30B-A3B GGUF conversion's
   --    end-of-sequence and chat-turn markers
   --  * @param Result - Translated text; empty when Error is not empty
   --  * @param Error - Empty on success, or a description of what went
   --    wrong with the request

end Reword;
