local traversal = require("nvim-paredit.utils.traversal")
local ts = require("nvim-treesitter.ts_utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.delete_form()
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
    use_source = false,
  })
  if not current_form then
    return
  end

  local root = lang.get_node_root(current_form)
  local range = { root:range() }

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )
end

function M.delete_in_form()
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
    use_source = false,
  })
  if not current_form then
    return
  end

  local edges = lang.get_form_edges(current_form)

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    edges.left.range[3], edges.left.range[4],
    edges.right.range[1], edges.right.range[2],
    {}
  )

  vim.api.nvim_win_set_cursor(0, { edges.left.range[3] + 1, edges.left.range[4] })
end

function M.delete_element()
  local lang = langs.get_language_api()
  local node = ts.get_node_at_cursor()
  if not node then
    return
  end

  local root = lang.get_node_root(node)
  local range = { root:range() }

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )
end

return M
