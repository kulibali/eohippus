use "collections"
use "files"

use ast = "../ast"
use parser = "../parser"

primitive AnalysisStart
  fun apply(): USize => 0

primitive AnalysisParse
  fun apply(): USize => 1

primitive AnalysisScope
  fun apply(): USize => 2

primitive AnalysisLint
  fun apply(): USize => 3

primitive AnalysisUpToDate
  fun apply(): USize => 4

primitive AnalysisError
  fun apply(): USize => USize.max_value()

type SrcItemState is
  ( AnalysisStart
  | AnalysisParse
  | AnalysisScope
  | AnalysisLint
  | AnalysisUpToDate
  | AnalysisError )

trait SrcItem
  fun get_canonical_path(): FilePath
  fun get_state(): SrcItemState
  fun ref set_state(state': SrcItemState)

class SrcFileItem is SrcItem
  let canonical_path: FilePath

  let cache_path: FilePath
  var cache_prefix: String = ""

  var parent_package: (SrcPackageItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart

  var is_open: Bool = false
  var schedule: (I64, I64) = (0, 0)
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.Node | None) = None
  var scope: (Scope | None) = None

  var node_indices: MapIs[ast.Node, USize] val = node_indices.create()
  var nodes_by_index: Map[USize, ast.Node] val = nodes_by_index.create()

  var scope_indices: MapIs[Scope, USize] val = scope_indices.create()
  var scopes_by_index: Map[USize, Scope] val = scopes_by_index.create()

  new create(canonical_path': FilePath, cache_path': FilePath) =>
    canonical_path = canonical_path'
    cache_path = cache_path'

  fun get_canonical_path(): FilePath => canonical_path
  fun get_state(): SrcItemState => state
  fun ref set_state(state': SrcItemState) => state = state'

  fun ref make_indices() =>
    match syntax_tree
    | let node: ast.Node =>
      (node_indices, nodes_by_index) =
        recover val
          let ni = MapIs[ast.Node, USize]
          let nbi = Map[USize, ast.Node]
          var next_index: USize = 0
          _make_node_indices(
            node, ni, nbi, { ref () => next_index = next_index + 1 })
          (ni, nbi)
        end
    end
    match scope
    | let scope': Scope =>
      (scope_indices, scopes_by_index) =
        recover val
          let si = MapIs[Scope, USize]
          let sbi = Map[USize, Scope]
          _make_scope_indices(scope', si, sbi)
          (si, sbi)
        end
    end

  fun tag _make_node_indices(
    node: ast.Node,
    ni: MapIs[ast.Node, USize],
    nbi: Map[USize, ast.Node],
    get_next: { ref (): USize })
  =>
    let index = get_next()
    ni(node) = index
    nbi(index) = node
    for child in node.children().values() do
      _make_node_indices(child, ni, nbi, get_next)
    end

  fun tag _make_scope_indices(
    scope': Scope,
    si: MapIs[Scope, USize],
    sbi: Map[USize, Scope])
  =>
    let index = scope'.index
    si(scope') = index
    sbi(index) = scope'
    for child in scope'.children.values() do
      _make_scope_indices(child, si, sbi)
    end

  fun ref compact() =>
    syntax_tree = None
    scope = None
    node_indices = node_indices.create()
    nodes_by_index = nodes_by_index.create()
    scope_indices = scope_indices.create()
    scopes_by_index = scopes_by_index.create()

class SrcPackageItem is SrcItem
  let canonical_path: FilePath

  let cache_path: FilePath
  var cache_prefix: String = ""

  var is_workspace: Bool = false
  var parent_package: (SrcPackageItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart

  new create(canonical_path': FilePath, cache_path': FilePath) =>
    canonical_path = canonical_path'
    cache_path = cache_path'

  fun get_canonical_path(): FilePath => canonical_path
  fun get_state(): SrcItemState => state
  fun ref set_state(state': SrcItemState) => state = state'
