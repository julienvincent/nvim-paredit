local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")
local ts = require("nvim-treesitter.ts_utils")
local config = require("nvim-paredit.config")
local langs = require("nvim-paredit.lang")

local M = {}

local function slurp(opts)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  if not current_form then
    return
  end

  local form
  if opts.reversed then
    form = traversal.find_closest_form_with_prev_siblings(current_form)
  else
    form = traversal.find_closest_form_with_next_siblings(current_form)
  end

  if not form then
    return
  end

  local sibling

  if opts.reversed then
    sibling = traversal.get_prev_sibling_ignoring_comments(form, { lang = lang })
  else
    sibling = traversal.get_next_sibling_ignoring_comments(form, { lang = lang })
  end

  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local left_or_right_edge
  if opts.reversed then
    left_or_right_edge = lang.get_form_edges(form).left
  else
    left_or_right_edge = lang.get_form_edges(form).right
  end

  local start_or_end
  if opts.reversed then
    start_or_end = { sibling:start() }
  else
    start_or_end = { sibling:end_() }
  end

  local row = start_or_end[1]
  local col = start_or_end[2]

  vim.api.nvim_buf_set_text(buf,
    row, col,
    row, col,
    { left_or_right_edge.text }
  )

  local offset = 0
  if opts.reversed and row == left_or_right_edge.range[1] then
    offset = string.len(left_or_right_edge.text)
  end

  vim.api.nvim_buf_set_text(
    buf,
    left_or_right_edge.range[1], left_or_right_edge.range[2] + offset,
    left_or_right_edge.range[3], left_or_right_edge.range[4] + offset,
    {}
  )

  local cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour
  if cursor_behaviour == "follow" then
    local offset = 0
    if not opts.reversed then
      offset = string.len(left_or_right_edge.text)
    end
    vim.api.nvim_win_set_cursor(0, { row + 1, col - offset })
  else
    local current = vim.api.nvim_win_get_cursor(0)
    if current[1] ~= cursor_pos[1] or current[2] ~= cursor_pos[2] then
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    end
  end
end

function M.slurp_forwards(opts)
  slurp(opts or {})
end

function M.slurp_backwards(opts)
  slurp(common.merge(opts or {}, {
    reversed = true
  }))
end

return M
