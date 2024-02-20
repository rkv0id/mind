import docopt
import docopt/dispatch

import app/[tags, queries]


const doc = """
Mind. Tags for the sane.

Description:
  A NIMble and efficient tag-based system for file and content management.

Usage:
  mind -h
  mind -v
  mind ls [-s] [-q] [<tagpattern>]
  mind sync [-y]
  mind tag [-H] <filepattern> <tags>...
  mind untag <filepattern> [<tags>...]
  mind mv <name> <newname>
  mind rm <tags>...
  mind find [-t=<level>] <query>

Options:
  -h --help               Show this screen.
  -v --version            Show version.
  -s --system             Show only system tags.
  -q --quiet              Show a shorter more concise version of the output.
  -y --yes                Silently auto-confirm synchronisation of tags without reporting loaded changes.
  -H --hard               Create a hard link for a file and tag it.
  -t LEVEL --tree=LEVEL   Show results in tree mode until LEVEL then revert to list mode. [default: 0]
"""

when isMainModule:
  let args = docopt(doc, version = "MIND v0.1.0")

  args.dispatchProc(listTags, "ls")
  args.dispatchProc(syncTags, "sync")
  args.dispatchProc(tagFiles, "tag")
  args.dispatchProc(untagFiles, "untag")
  args.dispatchProc(modTag, "mv")
  args.dispatchProc(removeTag, "rm")
  args.dispatchProc(find, "find")
