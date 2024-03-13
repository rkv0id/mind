import docopt
import docopt/dispatch

import ./app/[memos, tags, queries]
from ./data/db import existsOrInitDb, syncDb
from ./data/repository import existsOrInitRepo, dropRepo


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management.

Usage:
  mind -h
  mind -v
  mind sync
  mind init [-r]
  mind find [-fmq] [<query>]
  mind tags ls [-asq] [<tagpattern>]
  mind tags tag [-H] <filepattern> <tags>...
  mind tags untag <filepattern> [<tags>...]
  mind tags mv <name> <newname>
  mind tags desc <tag> <description>
  mind tags rm <tags>...
  mind memos open [<memoid>]
  mind memos rm <memos>...
  mind tasks new <task>
  mind tasks new --from <memoid>
  mind tasks done <memoid>
  mind tasks undo <memoid>
  mind kv store <key> <value>
  mind kv get <key>
  mind kv rm <key>
  mind kv mv <key> <newkey>

Options:
  -h --help               Show this screen.
  -v --version            Show version.
  -r --reset              Force Mind DB reinitialization if DB is already populated.
  -a --all                Show even tags with 0 linked files.
  -s --system             Show only system tags.
  -q --quiet              Show a shorter more concise version of the output.
  -H --hard               Create a hard link for a file and tag it.
  -f --files              Show only files out of the query results.
  -m --memos              Show only memos out of the query results.
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  if args["sync"]: syncDb()
  if args["init"]:
    if args["--reset"]: dropRepo()
    existsOrInitRepo()
    existsOrInitDb()
  
  args.dispatchProc(listTags, "ls")
  args.dispatchProc(tagFiles, "tag")
  args.dispatchProc(untagFiles, "untag")
  args.dispatchProc(modTag, "mv")
  args.dispatchProc(describeTag, "desc")
  args.dispatchProc(removeTag, "rm")
  args.dispatchProc(memo, "memo")
  args.dispatchProc(find, "find")
