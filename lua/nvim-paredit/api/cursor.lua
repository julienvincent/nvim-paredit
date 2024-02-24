local M = {}

function M.insert_mode()
  vim.cmd("startinsert")
end

function M.get_cursor_pos(range_or_node, opts)
  local range

  if type(range_or_node) == "table" then
    range = range_or_node
  elseif type(range_or_node) == "userdata" then
    range = { range_or_node:range() }
    range[4] = range[4] - 1
  end

  if not range then
    return
  end

  local cursor_pos
  if opts.placement == "left_edge" then
    cursor_pos = { range[1] + 1, range[2] }
  elseif opts.placement == "inner_start" then
    cursor_pos = { range[1] + 1, range[2] + 1 }
  elseif opts.placement == "inner_end" then
    cursor_pos = { range[3] + 1, range[4] }
  else
    cursor_pos = { range[3] + 1, range[4] + 1 }
  end
  return cursor_pos
end

function M.place_cursor(range_or_node, opts)
  local cursor_pos = M.get_cursor_pos(range_or_node, opts)
  if cursor_pos then
    vim.api.nvim_win_set_cursor(0, cursor_pos)
    if opts.mode == "insert" then
      M.insert_mode()
    end
  end
end

return M
