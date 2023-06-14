local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")
local ts = require("nvim-treesitter.ts_utils")
local config = require("nvim-paredit.config")
local langs = require("nvim-paredit.lang")

local M = {}

function M.barf_forwards(opts)
  opts = opts or {}

  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    use_source = false,
    lang = lang,
  })
  if not current_form then
    return
  end

  local form = traversal.find_closest_form_with_children(current_form, {
    lang = lang,
  })
  if not form or form:type() == "source" then
    return
  end

  local last_child = traversal.get_last_child_ignoring_comments(form, {
    lang = lang,
  })
  if not last_child then
    return
  end

  local edges = lang.get_node_edges(form)

  local end_pos = {}
  local sibling = traversal.get_prev_sibling_ignoring_comments(last_child, {
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

  local cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour
  if cursor_behaviour == "auto" or cursor_behaviour == "follow" then
    local cursor_out_of_bounds = common.cursor_out_of_bounds(vim.api.nvim_win_get_cursor(0), end_pos)
    if cursor_behaviour == "follow" or cursor_out_of_bounds then
      vim.api.nvim_win_set_cursor(0, { right_row + 1, right_col })
    end
  end
end

function M.barf_backwards()
end

return M
