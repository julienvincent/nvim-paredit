vim.opt.runtimepath:append("./.build/dependencies/plenary.nvim")
vim.opt.runtimepath:append("./.build/dependencies/nvim-treesitter")
vim.opt.runtimepath:append(".")

vim.cmd.runtime({ "plugin/plenary.vim", bang = true })
vim.cmd.runtime({ "plugin/nvim-treesitter.lua", bang = true })
vim.cmd.runtime({ "plugin/query_predicates.lua", bang = true })
vim.cmd.runtime({ "plugin/filetypes.lua", bang = true })

vim.o.swapfile = false
vim.bo.swapfile = false

require("nvim-treesitter").setup({ install_dir = vim.fn.getcwd() .. "/.build/parsers" })
require("nvim-treesitter.install").install({ "clojure", "fennel", "scheme", "commonlisp" }):wait()
