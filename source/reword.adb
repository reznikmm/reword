--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ada.Characters.Wide_Wide_Latin_1;
with Chat_Completions_API.Chats;
with Chat_Completions_API.Types;
with VSS.Strings.Formatters.Strings;
with VSS.Strings.Templates;

with Reword.HTTP_Requests;

package body Reword is

   -----------------
   -- Translate --
   -----------------

   procedure Translate
     (Text            : VSS.Strings.Virtual_String;
      Target_Language : VSS.Strings.Virtual_String := "Ukrainian";
      Server_URL      : VSS.Strings.Virtual_String :=
        "http://host.containers.internal:8080/v1/chat/completions";
      Model           : VSS.Strings.Virtual_String := "Hy-MT2-30B-A3B";
      Stop            : VSS.String_Vectors.Virtual_String_Vector :=
        ["<eos:6124c78e>", "<｜hy_User｜>", "<｜hy_Assistant｜>"];
      Result          : out VSS.Strings.Virtual_String;
      Error           : out VSS.Strings.Virtual_String)
   is
      use type VSS.Strings.Virtual_String;

      Line_Feed renames Ada.Characters.Wide_Wide_Latin_1.LF;
      --  Prompt template recommended by the Hy-MT2 model card: a single
      --  user turn, no system prompt, asking for the translation alone.
      Prompt_Template :
        constant VSS.Strings.Templates.Virtual_String_Template :=
          VSS.Strings.Templates.To_Virtual_String_Template
      ("### Task" & Line_Feed &
         "Translate the user-facing text within the following Markdown data" &
         " into {}." & Line_Feed &
         Line_Feed &
         "### Strict Rules" & Line_Feed &
         "1. Structure Preservation: You MUST preserve the original Markdown" &
         " data structure, nesting, hierarchy, and indentation exactly as" &
         " they are." & Line_Feed &
         "2. Selective Translation: Translate ONLY the visible, user-facing" &
         " text content/values." & Line_Feed &
         "3. Strict Non-Translation: NEVER translate or alter code tags," &
         " keys, properties, object names, or variable placeholders. Leave" &
         " them exactly in their original English/code form." & Line_Feed &
         "### Source Data" & Line_Feed &
         "{}");

      Prompt : constant VSS.Strings.Virtual_String :=
        Prompt_Template.Format
          (VSS.Strings.Formatters.Strings.Image (Target_Language),
           VSS.Strings.Formatters.Strings.Image (Text));

      Server   : Chat_Completions_API.Server;
      HTTP     : aliased Reword.HTTP_Requests.HTTP_Request;
      Messages :
        constant Chat_Completions_API
                   .Types
                   .ChatCompletionRequestMessage_Vector :=
          [(role    => Chat_Completions_API.Types.user,
            content => Prompt,
            others  => <>)];
      Response : Chat_Completions_API.Types.CreateChatCompletionResponse;
      Success  : Boolean;
   begin
      Server.Set_Request_Handler (HTTP'Unchecked_Access);
      Server.Set_URL (Server_URL);

      Chat_Completions_API.Chats.Chat
        (Server,
         Model                 => Model,
         Messages              => Messages,
         Stop                  => Stop,
         --  Parameters recommended by the Hy-MT2-30B-A3B model card.
         --  top_k and repetition_penalty are also recommended (-1 and 1.0,
         --  i.e. both disabled) but chat_completions_api has no fields for
         --  them: they aren't part of the standard OpenAI schema it is
         --  generated from, only llama.cpp-specific extensions to it.
         Temperature           => (Is_Set => True, Value => 0.7),
         Top_P                 => (Is_Set => True, Value => 1.0),
         Max_Completion_Tokens => (Is_Set => True, Value => 4_096),
         Response              => Response,
         Success               => Success);

      if not Success or else Response.choices.Length = 0 then
         Result := VSS.Strings.Empty_Virtual_String;
         Error := "Translation request to " & Server_URL & " failed";

         return;
      end if;

      Result := Response.choices (1).message.content;
      Error := VSS.Strings.Empty_Virtual_String;
   end Translate;

end Reword;
