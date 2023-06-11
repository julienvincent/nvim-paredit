local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.raise_form()
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  if not current_form then
    return
  end

  local parent = current_form:parent()
  if not parent or parent:type() == "source" then
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

function M.raise_element()
  local lang = langs.get_language_api()
  local current_node = lang.get_node_root(ts.get_node_at_cursor())

  local parent = current_node:parent()
  if not parent or parent:type() == "source" then
    return
  end

  local replace_text = vim.treesitter.get_node_text(current_node, 0)

  local parent_range = { parent:range() }
  vim.api.nvim_buf_set_text(0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

return M
