local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local lang = require("nvim-paredit.lang")

local M = {}

function M.slurpForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = lang.getDefinitions().form_types
  })
  if not current_form then
    return
  end

  local left, right = utils.findNextClosestSibling(current_form)
  if not left or not right then
    return
  end

  local buf = vim.api.nvim_get_current_buf()

  local close_bracket_node = left:field("close")[1]
  local close_bracket_text = close_bracket_node:type()

  local right_end = { right:end_() }
  local right_row = right_end[1]
  local right_col = right_end[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { close_bracket_text }
  )

  local close_bracket_range = { close_bracket_node:range() }
  local r1 = close_bracket_range[1]
  local c1 = close_bracket_range[2]
  local r2 = close_bracket_range[3]
  local c2 = close_bracket_range[4]
  vim.api.nvim_buf_set_text(buf,
    r1, c1,
    r2, c2,
    {}
  )
end

function M.slurpBackwards()

end

function M.barfForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = lang.getDefinitions().form_types
  })
  if not current_form then
    return
  end

  local left, right = utils.findNextFurthestSibling(current_form)
  if not left or not right then
    return
  end

  local end_pos = {}
  local sibling = right:prev_named_sibling()
  if sibling then
    end_pos = { sibling:end_() }
  else
    end_pos = { left:field("open")[1]:end_() }
  end

  local buf = vim.api.nvim_get_current_buf()

  local close_bracket_node = left:field("close")[1]
  local close_bracket_text = close_bracket_node:type()

  local close_bracket_range = { close_bracket_node:range() }
  local r1 = close_bracket_range[1]
  local c1 = close_bracket_range[2]
  local r2 = close_bracket_range[3]
  local c2 = close_bracket_range[4]
  vim.api.nvim_buf_set_text(buf,
    r1, c1,
    r2, c2,
    {}
  )

  local right_row = end_pos[1]
  local right_col = end_pos[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { close_bracket_text }
  )
end

function M.barfBackwards()

end

return M
