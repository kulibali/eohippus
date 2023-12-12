use ast = "../ast"

primitive _TypedefActions
  fun tag _doc_string(
    s: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let s' =
      try
        _Build.value_with[ast.Literal](b, s, r)?
      else
        return _Build.bind_error(d, r, c, b, "DocString/LiteralString")
      end

    let value = ast.NodeWith[ast.DocString](
      _Build.info(d, r), c, ast.DocString(s'))
    (value, b)

  fun tag _method_params(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let params' = _Build.nodes_with[ast.MethodParam](c)

    let value = ast.NodeWith[ast.MethodParams](
      _Build.info(d, r), c, ast.MethodParams(params'))
    (value, b)

  fun tag _method_param(
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/MethodParam/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint, r)
    let initializer' =
      _Build.value_with_or_none[ast.Expression](b, initializer, r)

    let value = ast.NodeWith[ast.MethodParam](
      _Build.info(d, r), c, ast.MethodParam(identifier', constraint', initializer'))
    (value, b)

  fun tag _field(
    kind: Variable,
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    doc_string: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Kind")
      end
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint, r)
    let initializer' = _Build.value_with_or_none[ast.Expression](b, initializer, r)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string, r)

    let value = ast.NodeWith[ast.TypedefField](
      _Build.info(d, r),
      c,
      ast.TypedefField(kind', identifier', constraint', initializer')
      where doc_strings' = doc_strings')
    (value, b)

  fun tag _method(
    kind: Variable,
    ann: Variable,
    cap: Variable,
    raw: Variable,
    id: Variable,
    tparams: Variable,
    params: Variable,
    rtype: Variable,
    partial: Variable,
    doc_string: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Method/Kind")
      end
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann, r)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap, r)
    let raw' = b.contains(raw)
    let id' =
      try
        _Build.value_with[ast.Identifier](b, id, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Method/Id")
      end
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams, r)
    let params' = _Build.value_with_or_none[ast.MethodParams](b, params, r)
    let rtype' = _Build.value_with_or_none[ast.TypeType](b, rtype, r)
    let partial' = b.contains(partial)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string, r)
    let body' = _Build.value_with_or_none[ast.Expression](b, body, r)

    let value = ast.NodeWith[ast.TypedefMethod](
      _Build.info(d, r),
      c,
      ast.TypedefMethod(
        kind', cap', raw', id', tparams', params', rtype', partial', body')
      where doc_strings' = doc_strings', annotation' = ann')
    (value, b)

  fun tag _members(
    fields: Variable,
    methods: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let fields' = _Build.values_with[ast.TypedefField](b, fields, r)
    let methods' = _Build.values_with[ast.TypedefMethod](b, methods, r)

    let value = ast.NodeWith[ast.TypedefMembers](
      _Build.info(d, r), c, ast.TypedefMembers(fields', methods'))
    (value, b)

  fun tag _primitive(
    id: Variable,
    ds: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let id': ast.NodeWith[ast.Identifier] =
      try
        _Build.value_with[ast.Identifier](b, id, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Primitive/Identifier")
      end
    let ds' = _Build.values_with[ast.DocString](b, ds, r)

    let value = ast.NodeWith[ast.Typedef](
      _Build.info(d, r), c, ast.TypedefPrimitive(id')
      where doc_strings' = ds')
    (value, b)
