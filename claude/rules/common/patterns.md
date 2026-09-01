# Patterns

Every `{lang}-patterns.md` extends this file. Do not repeat this content there.

1. Inject dependencies via constructor/initializer parameters only. Never field injection, property injection, or a global/service locator.
2. Define the narrowest interface the consumer needs, next to the consumer. Never depend on an interface wider than what the call site uses.
3. Represent data crossing a process/layer boundary (network, database, UI) as an immutable value type. Convert explicitly between the boundary type and the internal type — never pass one in place of the other.
4. Use exactly one name per concept. Reuse that exact name at every layer it appears — parameter, field, config key, doc.
