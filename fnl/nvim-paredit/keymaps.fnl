(module nvim-paretid.keymaps
  {autoload {sx nvim-paredit.core
             nvim aniseed.nvim}})

; paredit should ignore command when cursor is out of any sexp

(vim.keymap.set :n :<leader>Pf sx.raise-form {:desc "Raise form"})
(vim.keymap.set :n :<leader>Pe sx.raise-element {:desc "Raise element"})

; cursor looses it's original position on the moving form if form's height 
; more than 1 line
(vim.keymap.set :n :<M-l> sx.move-element-forward {:desc "Move sexp forward"})
(vim.keymap.set :n :<M-h> sx.move-element-backward {:desc "Move sexp backward"})

; TODO
; check boundarires (nil pointer error) for slurps and barfs
; prevent cursor movemet - cursor should stay on the same position
(vim.keymap.set :n :<S-M-l> sx.slurp-forward {:desc "Slurp forward"})
(vim.keymap.set :n :<S-M-k> sx.barf-forward {:desc "Barf forward"})
(vim.keymap.set :n :<S-M-h> sx.slurp-backward {:desc "Slurp backward"})
(vim.keymap.set :n :<S-M-j> sx.barf-backward {:desc "Barf backward"})
;; (vim.keymap.set :n "<S-M-l>" sx.slurp-forward {:desc "Slurp forward"})
;; (vim.keymap.set :n "<S-M-k>" sx.barf-forward {:desc "Barf forward"})
;; (vim.keymap.set :n "<M-p>" sx.move-sexp-backward {:desc "Move sexp backward"})
;; (vim.keymap.set :n "<M-f>" sx.move-sexp-forward {:desc "Move sexp forward"})

; TODO:
;; - split form
;; - move pairs
;; - make binding forms unelidable
;; - refactor slurp-forward and barf-forward
;; - autoformat node utility function...
;; - thread once / all (fennel)
;; - unwind once / all (fennel)
;; - move root form -forward/-back
;; - move form -forward/-back
