import docopt
import docopt/dispatch

import ./app/tags
from ./data/entities import existsOrInitDb
from ./data/repository import existsOrInitRepo, dropRepo


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management.

Usage:
  mind -h
  mind -v
  mind init [-f]
  mind ls [-asq] [<tagpattern>]
  mind tag [-H] <filepattern> <tags>...
  mind untag <filepattern> [<tags>...]
  mind mv <name> <newname>
  mind desc <tag> <description>
  mind rm <tags>...
  mind find [-t=<level>] [-S] <query>

Options:
  -h --help               Show this screen.
  -v --version            Show version.
  -f --force              Force Mind DB reinitialization (even if DB is already populated).
  -a --all                Show even tags with 0 linked files.
  -s --system             Show only system tags.
  -q --quiet              Show a shorter more concise version of the output.
  -S --sync               Synchronise query results before output.
  -H --hard               Create a hard link for a file and tag it.
  -t LEVEL --tree=LEVEL   Show results in tree mode until LEVEL then revert to list mode. [default: 0]
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

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
  args.dispatchProc(find, "find")
