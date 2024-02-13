import docopt


when isMainModule:
  let doc = """
  Mind. Tags for the sane.

  Usage:
    mind --version
    mind (-h | --help)
    mind task new <text>...
    mind task <id> edit <newtext>...
    mind task <id> [do | undo | del]
    mind memo new <text>...
    mind memo <id> del
    mind memo <id> edit <newtext>...
    mind memo <id> title <newtitle>...
    mind tag (-s | --system)
    mind tag del <tag>
    mind tag edit <tag> <newtag>
    mind tag <tag> <file>...
    mind untag <tag> <file>...
    mind find [-q=<filter>] [-t=<level>] [-FMTDN]

  Options:
    -h --help                 Show this screen.
    --version                 Show version.
    -s, --system              Show only system tags.
    -q QUERY, --query=QUERY   Filter results by the provided QUERY.
    -F, --file                Show file-type results of the search.
    -M, --memo                Show memo-type results of the search.
    -T, --task                Show task-type results of the search.
    -D, --done                Show done tasks out of the search results.
    -N, --not-done            Show not-done tasks out of the search results.
    -t LEVEL --tree=LEVEL     Show results in tree mode until LEVEL then revert to list mode.
  """

  let args = docopt(doc, version = "MIND v0.1.0")

  if args["task"]: echo "TASK CRUD"
  elif args["memo"]: echo "MEMO CRUD"
  elif args["tag"]: echo "TAGGING..."
  elif args["untag"]: echo "UNTAGGING..."
  else: echo "Hello, World!"
