;; We only consider a list_lit a form if it starts with a "(" anonymous node.
;; Some constructs like `(defun)` or `(loop)` are constructed as:
;;
;; (list_lit
;;   (defun ...))
;;
;; And in these cases we want to consider the `(defun)` the form inner and
;; 'ignore' the `list_lit` node
(list_lit
  open: "(") @form

(loop_macro) @form
(defun) @form
