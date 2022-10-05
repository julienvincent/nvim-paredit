(module nvim-paretid.keymaps
  {autoload {sx nvim-paredit.core
             nvim aniseed.nvim}})

(vim.keymap.set :n "<S-M-l>" sx.slurp-forward {:desc "Slurp forward"})
(vim.keymap.set :n "<S-M-k>" sx.barf-forward {:desc "Barf forward"})
(vim.keymap.set :n "<M-p>" sx.move-sexp-backward {:desc "Move sexp backward"})
(vim.keymap.set :n "<M-f>" sx.move-sexp-forward {:desc "Move sexp forward"})
