local M = {}

function M.insert_mode()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, true, true), "n", false)
end

function M.place_cursor(form, opts)
  if not form then
    return
  end

  local range = { form:range() }
  local cursor_pos
  if opts.placement == "left_edge" then
    cursor_pos = { range[1] + 1, range[2] }
  elseif opts.placement == "inner_start" then
    cursor_pos = { range[1] + 1, range[2] + 1 }
  elseif opts.placement == "inned_end" then
    cursor_pos = { range[3] + 1, range[4] - 2 }
  else
    cursor_pos = { range[3] + 1, range[4] - 1 }
  end
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  if opts.mode == "insert" then
    M.insert_mode()
  end
end

return M
