local utils = require("nvim-paredit.treesitter.utils")
local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.create_capture_context(target_node, opts)
  opts = opts or {}

  local root_node = utils.find_local_root(target_node)

  local bufnr = opts.buf or vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang then
    return {}
  end

  local query = vim.treesitter.query.get(lang, "paredit/forms")
  if not query then
    return {}
  end

  local captures = query:iter_captures(root_node, bufnr)

  local index = {}
  for id, node in captures do
    if not index[node:id()] then
      index[node:id()] = {}
    end

    table.insert(index[node:id()], query.captures[id])
  end
  return index
end

function M.create_context(opts)
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end

  local captures = M.create_capture_context(node, opts)

  return {
    node = node,
    captures = captures,
  }
end

return M
