# Claude Instruction File

Please keep responses concise and to the point. Avoid unnecessary explanations or elaborations. Focus only on essential information relevant to the question or task. Use short sentences and minimal tokens while maintaining clarity.

If code is requested, provide clean and minimal code snippets without extra comments unless explicitly asked. Prioritize brevity and accuracy in all replies.

If you are asked to be more specific then go more in-depth.

## Code Quality (CRITICAL)

- ALWAYS run IDE diagnostics after editing files
- Fix all linting and type errors before completing tasks
- This step must NEVER be skipped

## Documentation

- If you generate documents - use markdown, never use docx
- Create inline comments for complex logic
- Generate API docs for new endpoints
- For functions consisting of several steps, add comments with numbers and very short description of the logic
