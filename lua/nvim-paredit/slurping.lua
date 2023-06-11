local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

local function slurp(is_forward)
  -- remember cursor pos
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  if not current_form then
    return
  end

  local form
  if is_forward then
    form = utils.find_closest_form_with_next_siblings(current_form)
  else
    form = utils.find_closest_form_with_prev_siblings(current_form)
  end

  if not form then
    return
  end

  local sibling

  if is_forward then
    sibling = utils.get_next_sibling_ignoring_comments(form, { lang = lang })
  else
    sibling = utils.get_prev_sibling_ignoring_comments(form, { lang = lang })
  end

  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local left_or_right_edge
  if is_forward then
    left_or_right_edge = lang.get_node_edges(form).right
  else
    left_or_right_edge = lang.get_node_edges(form).left
  end

  local start_or_end
  if is_forward then
    start_or_end = { sibling:end_() }
  else
    start_or_end = { sibling:start() }
  end

  local row = start_or_end[1]
  local col = start_or_end[2]

  -- print(vim.inspect(start_or_end))
  -- print(vim.inspect(left_or_right_edge.range))

  vim.api.nvim_buf_set_text(buf, row, col, row, col, { left_or_right_edge.text })

  local col_offset = 0
  if not is_forward and row == left_or_right_edge.range[1] then
    col_offset = string.len(left_or_right_edge.text)
  end

  vim.api.nvim_buf_set_text(
    buf,
    left_or_right_edge.range[1],
    left_or_right_edge.range[2] + col_offset,
    left_or_right_edge.range[3],
    left_or_right_edge.range[4] + col_offset,
    {}
  )
  -- restore cursor pos
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

function M.slurp_forwards()
  slurp(true)
end

function M.slurp_backwards()
  slurp(false)
end

return M
