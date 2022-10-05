(module nvim-paretid.keymaps
  {autoload {sx nvim-paredit.core
             nvim aniseed.nvim}})

; paredit should ignore command when cursor is out of any sexp

(vim.keymap.set :n :<leader>Pf sx.raise-form {:desc "Raise form"})
(vim.keymap.set :n :<leader>Pe sx.raise-element {:desc "Raise element"})

; cursor looses it's original position on the moving form if form's height 
; more than 1 line
(vim.keymap.set :n :<leader>Pml sx.move-sexp-forward {:desc "Move sexp forward"})
(vim.keymap.set :n :<leader>Pmh sx.move-sexp-backward {:desc "Move sexp backward"})

; TODO
; check boundarires (nil pointer error) for slurps and barfs
; prevent cursor movemet - cursor should stay on the same position
(vim.keymap.set :n :<leader>PL sx.slurp-forward {:desc "Slurp forward"})
;;
;; (vim.keymap.set :n "<S-M-l>" sx.slurp-forward {:desc "Slurp forward"})
;; (vim.keymap.set :n "<S-M-k>" sx.barf-forward {:desc "Barf forward"})
;; (vim.keymap.set :n "<M-p>" sx.move-sexp-backward {:desc "Move sexp backward"})
;; (vim.keymap.set :n "<M-f>" sx.move-sexp-forward {:desc "Move sexp forward"})
