import std/[sugar, deques, sets]
from std/sequtils import mapIt
from regex import re2, findAll
from std/strutils import toLower, isEmptyOrWhitespace, replace, join

from ../data/entities import readFiles

type
  NodeKind = enum
    nkNot, nkAnd, nkOr,
    nkTag, nkExtension, nkType
  Node = ref object
    case kind: NodeKind
    of nkNot: op: Node
    of nkAnd, nkOr: leftOp, rightOp: Node
    of nkTag, nkExtension, nkType: val: string


func parseOr(tokens: var Deque[string]): Node
func parseAtom(tokens: var Deque[string]): Node =
  let token = tokens.popFirst
  case token[0]:
  of '#': result = Node(kind: nkTag, val: token[1..^1])
  of '.': result = Node(kind: nkExtension, val: token[1..^1])
  of 't': result = Node(kind: nkType, val: token[2..^1])
  of '(':
    result = parseOr tokens
    let nextTkn = tokens.peekFirst
    if nextTkn == ")": tokens.popFirst
    else: raise newException(ValueError, "Query parse Error: expected `)` but found `" & nextTkn & "`.")
  else: raise newException(ValueError, "Query parse Error: expected tag atom but found an undefined token `" & token & "`.")

func parseNot(tokens: var Deque[string]): Node =
  if tokens.len > 0:
    if tokens.peekFirst == "not":
      discard tokens.popFirst
      Node(kind: nkNot, op: parseAtom tokens)
    else: parseAtom tokens
  else: raise newException(ValueError, "Query parse Error: expected `not` or tag atom but hit end of expression.")

func parseAnd(tokens: var Deque[string]): Node =
  result = parseNot tokens
  while tokens.len > 0 and tokens.peekFirst == "and":
    discard tokens.popFirst
    result = Node(kind: nkAnd, leftOp: result, rightOp: parseNot tokens)

func parseOr(tokens: var Deque[string]): Node =
  result = parseAnd tokens
  while tokens.len > 0 and tokens.peekFirst == "or":
    discard tokens.popFirst
    result = Node(kind: nkOr, leftOp: result, rightOp: parseAnd tokens)

func tokenize(input: string): Deque[string] =
  const tokenRegx = re2"#[a-zA-Z_]\w*|\.(\?|[a-zA-Z][a-zA-Z0-9]*)|t\/[a-zA-Z]+|and|or|not|\(|\)"
  input.findAll(tokenRegx).mapIt(input[it.boundaries]).toDeque

func parse(input: string): Node =
  var tokens = tokenize input
  parseOr tokens

func interpret(ast: Node): (HashSet[string] -> bool) =
  proc(tags: HashSet[string]): bool =
    case ast.kind:
    of nkAnd: interpret(ast.leftOp)(tags) and interpret(ast.rightOp)(tags)
    of nkOr: interpret(ast.leftOp)(tags) or interpret(ast.rightOp)(tags)
    of nkNot: not interpret(ast.op)(tags)
    of nkTag: ast.val in tags
    of nkExtension: "ext[" & ast.val & "]" in tags
    of nkType: "type[" & ast.val.toLower & "]" in tags

proc find*(query: string, files, memos, tasks: bool) =
  if query.isEmptyOrWhitespace or query == "nil":
    echo readFiles(_ => true).join("\n")
  else:
    let
      predicate = interpret parse query
      shown = readFiles(predicate).join("\n")
    if shown.len > 0: echo shown
