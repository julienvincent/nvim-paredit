local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.barf_forwards()
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    use_source = false,
    lang = lang,
  })
  if not current_form then
    return
  end

  local form = utils.find_closest_form_with_children(current_form, {
    lang = lang,
  })
  if not form or form:type() == "source" then
    return
  end

  local last_child = utils.get_last_child_ignoring_comments(form, {
    lang = lang,
  })
  if not last_child then
    return
  end

  local edges = lang.get_node_edges(form)

  local end_pos = {}
  local sibling = utils.get_prev_sibling_ignoring_comments(last_child, {
    lang = lang,
  })
  if sibling then
    end_pos = { sibling:end_() }
  else
    end_pos = { edges.left.range[3], edges.left.range[4] }
  end

  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_text(
    buf,
    edges.right.range[1],
    edges.right.range[2],
    edges.right.range[3],
    edges.right.range[4],
    {}
  )

  local right_row = end_pos[1]
  local right_col = end_pos[2]
  vim.api.nvim_buf_set_text(buf, right_row, right_col, right_row, right_col, { edges.right.text })
end

function M.barf_backwards() end

return M
