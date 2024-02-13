import docopt
import docopt/dispatch

import app/[items, tags, queries, backups]


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management while also providing memos and todo tasks utilities.

Usage:
  mind --version
  mind (-h | --help)
  mind task new <text>
  mind task <id> edit <newtext>
  mind task <id> sub <parent>
  mind task (do | undo | del) <id>
  mind memo new [<text>]
  mind memo (open | del) <id>
  mind tag list [--system]
  mind tag del <tag>
  mind tag edit <tag> <newtag>
  mind tag [--remove | --hard] <tag> <files>...
  mind find [-q=<query>] [-t=<level>] [-FMTDN]
  mind reset [--clean]
  mind backup list [<filename>]
  mind backup new [<filename>]
  mind backup del [<filename>]
  mind backup restore [<filename>]

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  --system                  Show only system tags.
  -r, --remove              Remove tag from the listed files.
  -q QUERY, --query=QUERY   Filter results by the provided QUERY.
  -F, --file                Show file-type results of the search.
  -M, --memo                Show memo-type results of the search.
  -T, --task                Show task-type results of the search.
  -D, --done                Show done tasks out of the search results.
  -N, --not-done            Show not-done tasks out of the search results.
  -t LEVEL --tree=LEVEL     Show results in tree mode until LEVEL then revert to list mode.
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  args.dispatchProc(newTask, "task", "new")
  args.dispatchProc(delTask, "task", "del")
  args.dispatchProc(editTask, "task", "edit")
  args.dispatchProc(subTask, "task", "sub")
  args.dispatchProc(doTask, "task", "do")
  args.dispatchProc(undoTask, "task", "undo")
  
  args.dispatchProc(newMemo, "memo", "new")
  args.dispatchProc(openMemo, "memo", "open")
  args.dispatchProc(delMemo, "memo", "del")

  args.dispatchProc(listTag, "tag", "list")
  args.dispatchProc(editTag, "tag", "edit")
  args.dispatchProc(delTag, "tag", "del")
  args.dispatchProc(tag, "tag")
  args.dispatchProc(find, "find")

  args.dispatchProc(reset, "reset")
  args.dispatchProc(listBackup, "backup", "list")
  args.dispatchProc(newBackup, "backup", "new")
  args.dispatchProc(delBackup, "backup", "del")
  args.dispatchProc(restoreBackup, "backup", "restore")