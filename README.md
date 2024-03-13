# Mind - (WIP)
Mind - *tags for the sane*. A NIMble and efficient tag-based system for file and content management.

With a focus on simplicity, **Mind** allows users to effortlessley exploit the tagging system to create multiple layouts and structures (think quick semantic lookups, or even KANBAN for your terminal). All due to tags and a powerful boolean-based lookup DSL.

### Installation
Releasing this as a small package-manager-installable tool is still in the back of my mind but only to be done as soon as I finish with the todo list :point_down:.
For now, unfortunately, you need to go through this insufferable process (sorry again):
- [Install Nim](nim-lang.org/install_unix.html) (which in turn will install its package manager [Nimble](github.com/nim-lang/nimble)) and follow the required steps.
- Clone this project
- Go inside the project directory and run `nimble install --deepcopy:on`

Btw, never tried this on windows, it should work and even if it's not, it's probably for some dumb file path issues that I'll _make sure to debug_ if someone asks me to :eyes:.

### Usage example
<img src="./assets/screen.png" height="750">

### TODOs

- [x] Files and Tags logic
- [x] Make all removals deep for hard files
- [x] ~~Add hash/checksums support for duplicates detection~~ (replaced with `dev_t` & `ino_t` checks)
- [x] Synchronise sym links
- [x] Full Lookup DSL
- [ ] Backups (compression and auto-backups)
- [ ] Clean DSL syntax and better errors
- [ ] Full error-handling + code and usage documentation
- [ ] ORM-less, Cascade deletes? :thinking_face: (maybe SQL-less even)
- [ ] Optimization :running: and debugging time (memory leaks, anyone? + Ensure ARC)
- [ ] Testing :tired_face:
- [ ] Some CLI visual work (maybe some zsh completions)
