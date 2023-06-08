local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local lang = require("nvim-paredit.lang")

local M = {}

function M.raiseForm()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = lang.getDefinitions().form_types
  })
  if not current_form then
    return
  end

  local parent = current_form:parent()
  if not parent then
    return
  end

  local replace_text = vim.treesitter.get_node_text(current_form, 0)

  local parent_range = { parent:range() }
  vim.api.nvim_buf_set_text(0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

function M.raiseElement()
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = lang.getDefinitions().form_types,
    exclude_node = current_node
  })
  local element = utils.getOuterChildOfNode(root, current_node)
  if not element then
    return
  end

  local replace_text = vim.treesitter.get_node_text(element, 0)

  local parent_range = { root:range() }
  vim.api.nvim_buf_set_text(0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

return M
