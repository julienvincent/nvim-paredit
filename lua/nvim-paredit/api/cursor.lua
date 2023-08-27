local M = {}

function M.insert_mode()
  vim.api.nvim_feedkeys("i", "n", true)
end

function M.place_cursor(range_or_node, opts)
  local range

  if type(range_or_node) == "table" then
    range = range_or_node
  elseif type(range_or_node) == "userdata" then
    range = range_or_node:range()
  end

  if not range then
    return
  end

  local cursor_pos
  if opts.placement == "left_edge" then
    cursor_pos = { range[1] + 1, range[2] }
  elseif opts.placement == "inner_start" then
    cursor_pos = { range[1] + 1, range[2] + 1 }
  elseif opts.placement == "inned_end" then
    cursor_pos = { range[3] + 1, range[4] - 1 }
  else
    cursor_pos = { range[3] + 1, range[4] }
  end
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  if opts.mode == "insert" then
    M.insert_mode()
  end
end

return M
