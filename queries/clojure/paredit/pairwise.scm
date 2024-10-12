(list_lit 
  (sym_lit) @fn-name
  (vec_lit
    (_) @pair)
  (#any-of? @fn-name "let" "loop" "binding" "with-open" "with-redefs"))

(map_lit
  (_) @pair)

(list_lit 
  (sym_lit) @fn-name
  (_)
  (_) @pair
  (#eq? @fn-name "case"))

(list_lit 
  (sym_lit) @fn-name
  (_) @pair
  (#eq? @fn-name "cond"))

(list_lit 
  (sym_lit) @fn-name
  (_)
  (_)
  (_) @pair
  (#eq? @fn-name "condp"))
