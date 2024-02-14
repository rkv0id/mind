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
  mind memo new [<text>]
  mind memo (open | del) <id>
  mind task new <text>
  mind task <id> edit <newtext>
  mind task <id> sub <parent>
  mind task (do | undo | del) <id>
  mind tag list [--system]
  mind tag del <tag>
  mind tag edit <tag> <newtag>
  mind tag [--remove | --hard] <tag> <files>...
  mind find [-fmdp] [-t=<level>] [-q=<query>]
  mind reset [--clean]
  mind backup list [<filename>]
  mind backup new [<filename>]
  mind backup del [<filename>]
  mind backup restore [<filename>]

Options:
  -h --help               Show this screen.
  --version               Show version.
  --system                Show only system tags.
  -r --remove             Remove tag from the listed files.
  -f --file               Show results for files.
  -m --memo               Show results for memos.
  -d --done               Show results for done tasks.
  -p --pending            Show results for pending tasks.
  -q QUERY --query=QUERY  Filter results using the provided QUERY.
  -t LEVEL --tree=LEVEL   Show results in tree mode until LEVEL then revert to list mode. [default: 0]
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  args.dispatchProc(newTask, "task", "new")
  args.dispatchProc(editTask, "task", "edit")
  args.dispatchProc(subTask, "task", "sub")
  args.dispatchProc(doTask, "task", "do")
  args.dispatchProc(undoTask, "task", "undo")
  args.dispatchProc(delTask, "task", "del")
  
  args.dispatchProc(newMemo, "memo", "new")
  args.dispatchProc(openMemo, "memo", "open")
  args.dispatchProc(delMemo, "memo", "del")

  args.dispatchProc(listTag, "tag", "list")
  args.dispatchProc(delTag, "tag", "del")
  args.dispatchProc(editTag, "tag", "edit")
  args.dispatchProc(tag, "tag")
  args.dispatchProc(find, "find")

  args.dispatchProc(reset, "reset")
  args.dispatchProc(listBackup, "backup", "list")
  args.dispatchProc(newBackup, "backup", "new")
  args.dispatchProc(delBackup, "backup", "del")
  args.dispatchProc(restoreBackup, "backup", "restore")