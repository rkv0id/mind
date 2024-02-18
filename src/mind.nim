import docopt
import docopt/dispatch

import app/[tags, queries, backups]


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management.

Usage:
  mind -h
  mind -v
  mind sync [-y]
  mind ls [-q]
  mind tag mod <tag> <newtag>
  mind tag add <tag> [-h] <files>...
  mind tag rm <tag> [<files>...]
  mind find [-t=<level>] <query>

Options:
  -h --help               Show this screen.
  -v --version            Show version.
  -y --yes                Silently auto-confirm synchronisation of tags without reporting loaded changes.
  -a --all                Show tags from all contexts.
  -c CTX --context=CTX    Show tags from context CTX.
  -q --quiet              Show a shorter more concise version of the output.
  -s --system             Show only system tags.
  -h --hard               Create a hard copy for a file and tag that one.
  -t LEVEL --tree=LEVEL   Show results in tree mode until LEVEL then revert to list mode. [default: 0]
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  args.dispatchProc(listTag, "tag", "ls")
  args.dispatchProc(modifyTag, "tag", "mod")
  args.dispatchProc(addTag, "tag", "add")
  args.dispatchProc(removeTag, "tag", "rm")
  args.dispatchProc(find, "find")

  args.dispatchProc(reset, "reset")
  args.dispatchProc(listBackup, "backup", "ls")
  args.dispatchProc(newBackup, "backup", "new")
  args.dispatchProc(removeBackup, "backup", "rm")
  args.dispatchProc(restoreBackup, "backup", "restore")