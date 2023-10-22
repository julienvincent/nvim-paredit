local traversal = require("nvim-paredit.utils.traversal")
local langs = require("nvim-paredit.lang")
local ts = require("nvim-treesitter.ts_utils")

local M = {}

function M.unwrap_form(buf, form)
  local lang = langs.get_language_api()
  local edges = lang.get_form_edges(form)
  local left = edges.left
  local right = edges.right
  vim.api.nvim_buf_set_text(
    buf,
    right.range[1],
    right.range[2],
    right.range[3],
    right.range[4],
    { "" }
  )
  vim.api.nvim_buf_set_text(
    buf,
    left.range[1],
    left.range[2],
    left.range[3],
    left.range[4],
    { "" }
  )
end

function M.unwrap_form_under_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local lang = langs.get_language_api()
  local node = ts.get_node_at_cursor()
  local current_element = lang.get_node_root(node)
  local form = traversal.find_nearest_form(
    current_element,
    { lang = lang, use_source = false }
  )
  if not form then
    return false
  end

  M.unwrap_form(buf, form)
  return true
end

return M
