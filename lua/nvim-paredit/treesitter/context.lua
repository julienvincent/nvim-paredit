local utils = require("nvim-paredit.treesitter.utils")

local M = {}

function M.create_capture_context(target_node, opts)
  opts = opts or {}
  local root_node
  if opts.capture_root == true then
    root_node = target_node:tree():root()
  else
    root_node = utils.find_local_root(target_node)
  end

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
  local node = vim.treesitter.get_node()
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
