use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator, success.start, success.next)

  fun doc_strings(b: Bindings, ds: Variable): ast.NodeSeqWith[ast.DocString] =>
    recover val
      try
        Array[ast.NodeWith[ast.DocString]].>concat(
          Iter[ast.Node](b(ds)?._2.values())
            .filter_map[ast.NodeWith[ast.DocString]](
              {(node: ast.Node): (ast.NodeWith[ast.DocString] | None) =>
                try node as ast.NodeWith[ast.DocString] end
              }))
      else
        Array[ast.NodeWith[ast.DocString]]
      end
    end

  fun result(b: Bindings, v: Variable): Success? =>
    b(v)?._1

  fun value(b: Bindings, v: Variable): ast.Node? =>
    b(v)?._2(0)?

  fun value_or_none(b: Bindings, v: Variable): (ast.Node | None) =>
    try
      b(v)?._2(0)?
    end

  fun values[N: ast.NodeData val = ast.NodeData](b: Bindings, v: Variable)
    : ast.NodeSeqWith[N]
  =>
    recover val
      try
        let vs = b(v)?._2
        Array[ast.NodeWith[N]](vs.size()) .> concat(
          Iter[ast.Node](vs.values())
            .filter_map[ast.NodeWith[N]](
              {(n) => try n as ast.NodeWith[N] end }))
      else
        []
      end
    end

  fun with_post[T: ast.NodeData val](
    body: RuleNode,
    post: RuleNode,
    action:
      {(Success, ast.NodeSeq, Bindings, ast.NodeSeqWith[T])
        : ((ast.Node | None), Bindings)} val)
    : RuleNode ref
  =>
    let p = Variable("p")
    Conj(
      [ body
        Bind(p, Star(post)) ],
      {(r, c, b) => action(r, c, b, _Build.values[T](b, p)) })

  fun bind_error(r: Success, c: ast.NodeSeq, b: Bindings,
    message: String): (ast.Node, Bindings)
  =>
    let message' = ErrorMsg.internal_ast_node_not_bound(message)
    let value' = ast.NodeWith[ast.ErrorSection](
      _Build.info(r), c, ast.ErrorSection(message'))
    (value', b)
