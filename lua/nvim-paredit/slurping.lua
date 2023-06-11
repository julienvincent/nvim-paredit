local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.slurp_forwards()
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local form = utils.find_closest_form_with_siblings(current_form)
  if not form then
    return
  end

  local sibling = utils.get_next_sibling_ignoring_comments(form, {
    lang = lang
  })
  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local edges = lang.get_node_edges(form)

  local right_end = { sibling:end_() }
  local right_row = right_end[1]
  local right_col = right_end[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { edges.right.text }
  )

  vim.api.nvim_buf_set_text(buf,
    edges.right.range[1], edges.right.range[2],
    edges.right.range[3], edges.right.range[4],
    {}
  )
end

function M.slurp_backwards()

end

return M
