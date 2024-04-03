use "debug"

use per = "collections/persistent"

use ast = "../../ast"
use lint = ".."

class val TrimTrailingWhitespace is lint.Rule
  fun val name(): String => lint.ConfigKey.trim_trailing_whitespace()

  fun val message(): String => "trailing whitespace"

  fun val should_apply(config: lint.Config val): Bool =>
    try
      config(lint.ConfigKey.trim_trailing_whitespace())?.lower() == "true"
    else
      false
    end

  fun val analyze(tree: ast.SyntaxTree iso, issues: Seq[lint.Issue] iso)
    : ( ast.SyntaxTree iso^,
        Seq[lint.Issue] iso^,
        ReadSeq[ast.TraverseError] val)
  =>
    let ws_seen = Array[ast.Path]
    let rule = this
    let issues' = Array[lint.Issue]
    let fn =
      object
        fun ref apply(node: ast.Node, path: ast.Path) =>
          if node.children().size() == 0 then
            match node
            | let t: ast.NodeWith[ast.Trivia] if
              (t.data().kind is ast.EndOfLineTrivia) or
              (t.data().kind is ast.EndOfFileTrivia)
            =>
              if ws_seen.size() > 0 then
                try issues'.push(lint.Issue(rule, ws_seen(0)?, path)) end
              end
              ws_seen.clear()
            | let t: ast.NodeWith[ast.Trivia] if
              t.data().kind is ast.WhiteSpaceTrivia
            =>
              ws_seen.push(path)
            else
              ws_seen.clear()
            end
          else
            for child in node.children().values() do
              this(child, path.prepend(child))
            end
          end
        end
    fn(tree.root, per.Cons[ast.Node](tree.root, per.Nil[ast.Node]))
    for issue in issues'.values() do
      issues.push(issue)
    end
    (consume tree, consume issues, recover val Array[ast.TraverseError] end)

  fun val fix(tree: ast.SyntaxTree iso, issues: ReadSeq[lint.Issue] val)
    : ( ast.SyntaxTree iso^,
        ReadSeq[lint.Issue] val,
        ReadSeq[ast.TraverseError] val )
  =>
    var root: ast.Node = tree.root
    let unfixed: Array[lint.Issue] trn = Array[lint.Issue]
    let all_errors: Array[ast.TraverseError] trn = Array[ast.TraverseError]
    for issue in issues.values() do
      if issue.rule.name() == this.name() then
        let visitor = _TrailingWhitespaceVisitor(issue)
        (let new_root, let errors) = tree.traverse[None](consume visitor, root)
        if new_root is root then
          unfixed.push(issue)
          all_errors.push((root, "tree was unchanged by " + this.name()))
        else
          root = new_root
        end
        all_errors.append(errors)
      else
        unfixed.push(issue)
      end
    end

    if root is tree.root then
      (consume tree, consume unfixed, consume all_errors)
    else
      ( recover iso ast.SyntaxTree(root) end,
        consume unfixed,
        consume all_errors )
    end

class _TrailingWhitespaceVisitor is ast.Visitor[None]
  let _issue: lint.Issue

  new iso create(issue: lint.Issue) =>
    _issue = issue

  fun ref visit_pre(
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso)
    : (None, Array[ast.TraverseError] iso^)
  =>
    (None, consume errors)

  fun ref visit_post(
    pre_state: None,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso,
    new_children: (ast.NodeSeq | None) = None)
    : (ast.Node, Array[ast.TraverseError] iso^)
  =>
    // Trailing whitespace will all be children of one node, usually
    // post_trivia (except for pre_trivia in SrcFile)
    let existing_children =
      match new_children
      | let nc: ast.NodeSeq =>
        nc
      else
        node.children()
      end

    // find the start and next index of the trailing whitespace
    var start_child: USize = 0
    var next_child: USize = 0
    var found = false
    var i: USize = 0
    while i < existing_children.size() do
      let child =
        try
          existing_children(i)?
        else
          next_child = i
          break
        end
      if _issue.match_start(child) then
        start_child = i
        found = true
      elseif _issue.match_next(child) then
        next_child = i
        break
      end
      i = i + 1
    end
    if found and (next_child <= start_child) then
      next_child = start_child + 1
    end

    let new_node =
      if found then
        let update_map: ast.ChildUpdateMap trn = ast.ChildUpdateMap
        let new_children': Array[ast.Node] trn = Array[ast.Node](
          existing_children.size() - (next_child - start_child))
        i = 0
        while i < start_child do
          try
            let child = existing_children(i)?
            update_map(child) = child
            new_children'.push(child)
          end
          i = i + 1
        end
        i = next_child
        while i < existing_children.size() do
          try
            let child = existing_children(i)?
            update_map(child) = child
            new_children'.push(child)
          end
          i = i + 1
        end
        node.clone(where
          new_children' = consume new_children',
          update_map' = consume update_map)
      else
        if existing_children isnt node.children() then
          if existing_children.size() == node.children().size() then
            let update_map: ast.ChildUpdateMap trn = ast.ChildUpdateMap
            i = 0
            while i < existing_children.size() do
              try
                update_map(node.children()(i)?) = existing_children(i)?
              end
              i = i + 1
            end
            node.clone(where
              new_children' = existing_children,
              update_map' = consume update_map)
          else
            errors.push((node, "length of updated children doesn't match old!"))
            node.clone(where new_children' = existing_children)
          end
        else
          node
        end
      end
    (new_node, consume errors)
