import docopt
import docopt/dispatch


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
  mind tag [--remove] <tag> <files>...
  mind find [-q=<query>] [-t=<level>] [-FMTDN]

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  -s, --system              Show only system tags.
  -r, --remove              Remove tag from the listed files.
  -q QUERY, --query=QUERY   Filter results by the provided QUERY.
  -F, --file                Show file-type results of the search.
  -M, --memo                Show memo-type results of the search.
  -T, --task                Show task-type results of the search.
  -D, --done                Show done tasks out of the search results.
  -N, --not-done            Show not-done tasks out of the search results.
  -t LEVEL --tree=LEVEL     Show results in tree mode until LEVEL then revert to list mode.
"""

proc newTask(text: string) = echo "new task: " & text
proc editTask(id: int, newtext: string) = echo "edit task n." & $id & " to " & newtext
proc subTask(id: int, parent: int) = echo "sub task n." & $id & " to task n." & $parent
proc doTask(id: int) = echo "do task n." & $id
proc undoTask(id: int) = echo "undo task n." & $id
proc delTask(id: int) = echo "delete task n." & $id
proc newMemo(text: string) = echo "new memo" & (if text != "nil": ": " & text else: "")
proc openMemo(id: int) = echo "open memo n." & $id
proc delMemo(id: int) = echo "delete memo n." & $id
proc listTag(system: bool) = echo "show " & (if system: "system" else: "non-system") & " tags."
proc editTag(tag: string, newtag: string) = echo "edit tag #" & tag & " to " & newtag
proc delTag(tag: string) = echo "delete tag #" & tag
proc tag(tag: string, files: seq[string], remove: bool) = echo (if remove: "un" else: "") & "tag " & $files & " by #" & tag
proc find(query: string, level: int, file: bool, memo: bool,
          task: bool, done: bool, not_done: bool) =
  echo "show items according to query: " & query & " at a " &
    (if level == 0: "flat" else: $level & "-tree ") & " listing."

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