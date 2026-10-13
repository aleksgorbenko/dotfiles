# Patterns

Every `{lang}-patterns.md` extends this file. Do not repeat this content there.

1. Inject dependencies via constructor/initializer parameters only. Never field injection, property injection, or a global/service locator.
2. Define the narrowest interface the consumer needs, next to the consumer. Never depend on an interface wider than what the call site uses.
3. Represent data crossing a process/layer boundary (network, database, UI) as an immutable value type. Convert explicitly between the boundary type and the internal type — never pass one in place of the other.
4. Use exactly one name per concept. Reuse that exact name at every layer it appears — parameter, field, config key, doc.
5. Use the user-facing term for a concept in code identifiers too (type, protocol, parameter).
6. Expose a CLI and automation actions (e.g. Shortcuts) through one shared service: same operations, parameters, defaults and result type.
7. Never apply a default result limit in a CLI or automation API; return every match unless the caller passes a limit.
8. Name build and release targets `<verb>-<channel>`, and name each script step exactly like the target that calls it.
9. Give each release channel the same step sequence: setup, publish, submit; keep submission for review a separate, deliberate step.
10. Mark platform-limited features in one place in the source copy (e.g. a marker) and let generators derive every channel's copy from it.
