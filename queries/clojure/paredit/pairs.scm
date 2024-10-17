(list_lit 
  (sym_lit) @fn-name
  (#any-of? @fn-name
   "let"
   "loop"
   "binding"
   "with-open"
   "with-redefs")

  (vec_lit
    (_) @pair))

(map_lit
  (_) @pair)

(list_lit 
  (sym_lit) @fn-name
  (#eq? @fn-name "case")

  (_) .
  ((_) @pair . (_) @pair)+
  (_)?)

(list_lit 
  (sym_lit) @fn-name
  (#eq? @fn-name "cond")

  ((_) @pair (_) @pair)+)

(list_lit
  (sym_lit) @fn-name
  (#any-of? @fn-name
   "cond->"
   "cond->>")
  (_)
  .
  ((_) @pair . (_) @pair)+)

(list_lit 
  (sym_lit) @fn-name
  (#eq? @fn-name "condp")

  (_) (_)
  .
  ((_) @pair . (_) @pair)+
  .
  (_)?)
