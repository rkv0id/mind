from std/sequtils import mapIt, toSeq
from regex import re2, findAll, group

type
  NodeKind = enum
    nkNot, nkAnd, nkOr,
    nkTag, nkSysTag, nkExtension, nkType
  Node = ref object
    case kind: NodeKind
    of nkTag, nkSysTag, nkExtension, nkType: val: string
    of nkNot: op: Node
    of nkAnd, nkOr: leftOp, rightOp: Node


proc find*(query: string) =
  ## TODO
  echo "show tagged files according to query: " & query

func tokenize(input: string): seq[string] =
  const tokenRegx = re2"s\/[a-zA-Z_]\w*|#[a-zA-Z_]\w*|\.[a-zA-Z]\w*|t\/[a-zA-Z]+|and|or|not|\(|\)"
  input.findAll(tokenRegx).mapIt(input[it.boundaries])

func parse(tokens: seq[string], operatorStack = newSeq[string](),
           operandStack = newSeq[Node]()): Node =
  # TODO: POPPING
  # STACKING
  case tokens[0]:
  of "not", "and", "or": parse(tokens[1..^1], tokens[0] & operatorStack, operandStack)
  of "(": parse(tokens[1..^1], operatorStack, operandStack)
  of ")": parse(tokens[1..^1], operatorStack, )
  else:
    let operand = case tokens[0][0]:
      of '#': Node(kind: nkTag, val: tokens[0][1..^1])
      of '.': Node(kind: nkExtension, val: tokens[0][1..^1])
      of 's': Node(kind: nkSysTag, val: tokens[0][2..^1])
      else: Node(kind: nkType, val: tokens[0][2..^1])
    if operatorStack.len == 0 or operatorStack[0] == "or":
      parse(tokens[1..^1], operatorStack, operand & operandStack)
    else:
      if operatorStack[0] == "not":
        parse(tokens[1..^1], operatorStack[1..^1],
              Node(kind: nkNot, op: operand) & operandStack)
      else:
        parse(tokens[1..^1], operatorStack[1..^1],
              Node(kind: nkAnd, leftOp: operandStack[0], rightOp: operand) & operandStack[1..^1])
