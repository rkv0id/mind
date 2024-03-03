# Mind - (WIP)
Mind - *tags for the sane*. A NIMble and efficient tag-based system for file and content management.

With a focus on simplicity, **Mind** allows users to effortlessley exploit the tagging system to create multiple layouts and structures (think quick semantic lookups, or even KANBAN for your terminal). All due to tags and a powerful boolean-based lookup DSL.

### Usage example
<img src="./assets/screen.png" height="750">

### TODOs

- [x] Files and Tags logic
- [x] Make all removals deep for hard files
- [x] ~~Add hash/checksums support for duplicates detection~~ (replaced with `dev_t` & `ino_t` checks)
- [x] Synchronise sym links
- [x] Full Lookup DSL
- [ ] ORM-less (maybe SQL-less too)
- [ ] Full exception handling + Documentation
- [ ] Some CLI visual work (maybe some zsh completions)
- [ ] Backups (compression and auto-backups)
- [ ] Testing :tired_face:
- [ ] Memos support
- [ ] Tasks and TODO lists
- [ ] Key-value store (with optional encryption)
- [ ] Behaviour configuration and defaults
