local ts = require("nvim-treesitter.ts_utils")

local M = {}

function M.getNodeAtCursor()
  return ts.get_node_at_cursor()
end

function M.fileType()
  return vim.bo.filetype
end

function M.getBufferNr()
  return vim.fn.bufnr()
end

return M
