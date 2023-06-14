local paredit = require("nvim-paredit.api")
local keybindings = require("nvim-paredit.keybindings")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("dot-repeat", function()
  -- vim.api.nvim_buf_set_option(0, "filetype", "clojure")
  -- local parser = vim.treesitter.get_parser(0)
  --
  -- it("should repeat the last operation when pressing .", function()
  --   vim.keymap.set({ "n", "x" }, "q", paredit.slurp_forwards, {
  --     -- expr = true,
  --   })
  --
  --   prepare_buffer({
  --     content = "() a b",
  --     cursor = { 1, 1 }
  --   })
  --
  --   vim.api.nvim_input('q')
  --
  --   expect({
  --     content = "( a) b",
  --   })
  --
  --   parser:parse()
  --   vim.api.nvim_input(".")
  --
  --   expect({
  --     content = "( a b)",
  --   })
  -- end)
end)
