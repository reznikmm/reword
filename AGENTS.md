# AGENTS.md

## Purpose

Reword is an Ada library for machine translation with an LLM. It talks to
an OpenAI-compatible chat completions server (e.g. `llama.cpp`'s
`llama-server`) to translate plain text into a target language (Ukrainian
by default).

## Repository Map

- `source/`: Core library logic (`Reword.*` packages)
- `driver/`: Separate `reword-run` command-line crate. Reads text from
  `input.txt`, calls `Reword.Translate`, prints the result to standard
  output
- `testsuite/`: Separate test suite crate
- `config/`: Build-time configuration artifacts written by Alire (do not edit manually)
- `.obj/`, `.lib/`: Build outputs (do not edit manually)

## Ground Rules

- Don't introduce extra (sub-)type conversions, like Integer to Natural.
- Preserve existing style and naming conventions in nearby code. Don't use abbreviations.

## Build And Test Commands

Run from repository root unless noted otherwise.

- Compile core library:
  - `alr build`
- Compile/check one file (`<unit>.adb`):
  - `alr exec -- gprbuild -q -f -c -u -gnatc -P reword.gpr <unit>.adb '-cargs:ada' -gnatef`
- Fix code style warnings, force code style after edit:
  - `alr exec -- gnatformat --charset=utf-8 --no-subprojects -P reword.gpr`
- Build and run testsuite:
  - `alr -C testsuite/ run`
- Build the CLI driver (from `driver/`):
  - `alr build`
- Run the CLI driver (from `driver/`, reads `input.txt` in the current directory):
  - `alr run` or `./bin/reword-run`

## Change Workflow For Agents

1. Read relevant package spec/body before editing. Read `*.adb` only if reading of corresponding `*.ads` is not enough.
2. Implement the smallest viable patch.
3. Re-run compile check for touched units.
4. Run targeted runtime/test command when behavior changes.
5. Report exactly what changed and what was validated.

## Ada-Specific Notes

- Use predefined Ada container packages
  (for example, `Ada.Containers.Hashed_Sets`). Don't use Indefinite containers.
- Use Ada 2022 syntax if you can.
- Prefer `VSS.Strings.Templates.Virtual_String_Template` with
  `VSS.Strings.Formatters.*` over building a `Virtual_String` by
  concatenating pieces with `&`:
  - Plain string literals don't reliably convert to `Virtual_String` through
    `&`: the `String_Literal` aspect only kicks in when the expected type is
    known directly (an object initialization, a parameter, an aggregate
    component), not through operator overload resolution. In practice a
    literal `&` `Virtual_String` fails to compile without an explicit
    `VSS.Strings.Conversions.To_Virtual_String` call and a
    `use type VSS.Strings.Virtual_String;` in scope.
  - Multi-line text built with `&` degenerates into fragile
    character-by-character chains (`... & VSS.Characters.Latin.Line_Feed &
    VSS.Characters.Latin.Quotation_Mark & ...`), while a template keeps the
    literal text in one place with `{}` placeholders.
  - Example:
    ```ada
    with VSS.Strings.Formatters.Strings;
    with VSS.Strings.Templates;

    Template : constant VSS.Strings.Templates.Virtual_String_Template :=
      "Repository name: {}";
    Message  : constant VSS.Strings.Virtual_String :=
      Template.Format (VSS.Strings.Formatters.Strings.Image (Name));
    ```
  - Formatters exist for other types too (for example,
    `VSS.Strings.Formatters.Generic_Integers`), so numbers and other
    non-string values can be substituted directly without a manual
    `'Image` / `To_Virtual_String` round trip.

## Output And Error Handling Expectations

- Diagnostics should be actionable and include path/context when possible.

## When Unsure

- Prefer conservative changes.
- Ask for clarification before large architectural rewrites.
- Document assumptions in the final update.
