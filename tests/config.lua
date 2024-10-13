vim.opt.runtimepath:append("./.build/dependencies/plenary.nvim")
vim.opt.runtimepath:append("./.build/dependencies/nvim-treesitter")
vim.opt.runtimepath:append("./.build/parsers")
vim.opt.runtimepath:append(".")

vim.cmd.runtime({ "plugin/plenary.vim", bang = true })
vim.cmd.runtime({ "plugin/nvim-treesitter.lua", bang = true })

vim.o.swapfile = false
vim.bo.swapfile = false

require("nvim-treesitter.configs").setup({
  parser_install_dir = vim.fn.getcwd() .. "/.build/parsers",
  ensure_installed = { "clojure", "fennel", "scheme" },
  sync_install = true,
})
