local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local traversal = require("nvim-paredit.utils.traversal")
local indentation = require("nvim-paredit.indentation")
local config = require("nvim-paredit.config")

local M = {}

local function slurp(opts)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local context = ts_context.create_context(opts)
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, context)
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
    sibling = traversal.get_prev_sibling_ignoring_comments(form, context)
  else
    sibling = traversal.get_next_sibling_ignoring_comments(form, context)
  end

  if not sibling then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local form_edges = ts_forms.get_form_edges(form, context)
  local left_or_right_edge
  if opts.reversed then
    left_or_right_edge = form_edges.left
  else
    left_or_right_edge = form_edges.right
  end

  local start_or_end
  if opts.reversed then
    start_or_end = { sibling:start() }
  else
    start_or_end = { sibling:end_() }
  end

  local row = start_or_end[1]
  local col = start_or_end[2]

  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    row, col,
    row, col,
    { left_or_right_edge.text }
  )

  local offset = 0
  if opts.reversed and row == left_or_right_edge.range[1] then
    offset = #left_or_right_edge.text
  end

  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    left_or_right_edge.range[1], left_or_right_edge.range[2] + offset,
    left_or_right_edge.range[3], left_or_right_edge.range[4] + offset,
    {}
  )

  local cursor_behaviour = opts.cursor_behaviour or config.config.cursor_behaviour
  if cursor_behaviour == "follow" then
    offset = 0
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

  local operation_type
  local new_range
  if not opts.reversed then
    operation_type = "slurp-forwards"
    -- stylua: ignore
    new_range = {
      form_edges.left.range[1], form_edges.left.range[2],
      row, col,
    }
  else
    operation_type = "slurp-backwards"
    -- stylua: ignore
    new_range = {
      row, col,
      form_edges.right.range[1], form_edges.right.range[2],
    }
  end

  local event = {
    type = operation_type,
    parent_range = new_range,
  }
  indentation.handle_indentation(event, opts)
end

function M.slurp_forwards(opts)
  slurp(opts or {})
end

function M.slurp_backwards(opts)
  slurp(vim.tbl_deep_extend("force", opts or {}, {
    reversed = true,
  }))
end

return M
