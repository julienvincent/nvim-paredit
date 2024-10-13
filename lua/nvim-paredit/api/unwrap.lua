local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")

local M = {}

local function unwrap_form(buf, form, context)
  local edges = ts_forms.get_form_edges(form, context)
  local left = edges.left
  local right = edges.right
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    right.range[1],
    right.range[2],
    right.range[3],
    right.range[4],
    { "" }
  )
  -- stylua: ignore
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
  local context = ts_context.create_context()
  if not context then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local current_element = ts_forms.get_node_root(context.node, context)
  local form = ts_forms.find_nearest_form(current_element, {
    captures = context.captures,
    use_source = false,
  })
  if not form then
    return false
  end

  unwrap_form(buf, form, context)
  return true
end

return M
