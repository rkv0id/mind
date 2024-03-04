import docopt
import docopt/dispatch

import ./app/[memos, tags, queries]
from ./data/entities import existsOrInitDb, syncDb
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
  mind ls [-asq] [<tagpattern>]
  mind tag [-H] <filepattern> <tags>...
  mind untag <filepattern> [<tags>...]
  mind mv <name> <newname>
  mind desc <tag> <description>
  mind rm <tags>...
  mind memo [<memoid>]
  mind find [-fmt] [<query>]

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
  -t --tasks              Show only tasks out of the query results.
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
