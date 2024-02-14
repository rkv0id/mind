import docopt
import docopt/dispatch

import app/[items, tags, queries, backups]


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management while also powering memos and todolist utilities.

Usage:
  mind --version
  mind (-h | --help)
  mind memo new [<text>] [--title=<title>]
  mind memo (open | rm) <id>
  mind task new <text>
  mind task mod <id> <newtext>
  mind task sub <id> <parent>
  mind task (do | undo | rm) <id>
  mind tag ls [--system]
  mind tag mod <tag> <newtag>
  mind tag add <tag> [--hard] <files>...
  mind tag rm <tag> [<files>...]
  mind find [-fmdp] [-t=<level>] [-q=<query>]
  mind reset [--clean]
  mind backup ls [<filename>]
  mind backup new [<filename>]
  mind backup rm [<filename>]
  mind backup restore [<filename>]

Options:
  -h --help               Show this screen.
  --version               Show version.
  -s --system             Show only system tags.
  -t TITLE --title=TITLE  Define title of new memo.
  -H --hard               Create a hard copy for file and tag that one.
  -r --remove             Remove tag from the listed files.
  -f --file               Show results for files.
  -m --memo               Show results for memos.
  -d --done               Show results for done tasks.
  -p --pending            Show results for pending tasks.
  -q QUERY --query=QUERY  Filter results using the provided QUERY.
  -T LEVEL --tree=LEVEL   Show results in tree mode until LEVEL then revert to list mode. [default: 0]
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  args.dispatchProc(newTask, "task", "new")
  args.dispatchProc(modifyTask, "task", "mod")
  args.dispatchProc(subTask, "task", "sub")
  args.dispatchProc(doTask, "task", "do")
  args.dispatchProc(undoTask, "task", "undo")
  args.dispatchProc(removeTask, "task", "rm")
  
  args.dispatchProc(newMemo, "memo", "new")
  args.dispatchProc(openMemo, "memo", "open")
  args.dispatchProc(removeMemo, "memo", "rm")

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