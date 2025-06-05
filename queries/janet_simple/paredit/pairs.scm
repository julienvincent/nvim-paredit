(par_tup_lit
  (sym_lit) @fn-name
  (#any-of? @fn-name
   "let"
   "if-let"
   "when-let"
   "with-dyns"
   "with-vars")

  (par_tup_lit
    (_) @pair))


(struct_lit
  (_) @pair)


(tbl_lit
  (_) @pair)


(par_tup_lit 
  (sym_lit) @fn-name
  (#any-of? @fn-name
   "case"
   "match")

  (_) .
  ((_) @pair . (_) @pair)+
  (_)?)


(par_tup_lit 
  (sym_lit) @fn-name
  (#eq? @fn-name "cond")

  ((_) @pair (_) @pair)+)
