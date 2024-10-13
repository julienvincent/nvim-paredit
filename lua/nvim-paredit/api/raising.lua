local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_utils = require("nvim-paredit.treesitter.utils")

local M = {}

function M.raise_form()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local form = ts_forms.find_nearest_form(context.node, context)
  local current_form = ts_forms.get_node_root(form, context)
  if not current_form then
    return
  end

  local parent = current_form:parent()
  if not parent or ts_utils.is_document_root(parent) then
    return
  end

  local replace_text = vim.treesitter.get_node_text(current_form, 0)

  local parent_range = { parent:range() }
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

function M.raise_element()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_node = ts_forms.get_node_root(context.node, context)

  local parent = current_node:parent()
  if not parent or ts_utils.is_document_root(parent) then
    return
  end

  local replace_text = vim.treesitter.get_node_text(current_node, 0)

  local parent_range = { parent:range() }
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

return M
