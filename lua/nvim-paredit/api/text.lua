local M = {}

-- Swap the text in the given buffer represented by left_range and right_range
function M.swap_ranges(buf, left_range, right_range, cursor_pos)
  -- stylua: ignore
  local left_text = vim.api.nvim_buf_get_text(
    buf,
    left_range[1], left_range[2],
    left_range[3], left_range[4],
    {}
  )
  -- stylua: ignore
  local right_text = vim.api.nvim_buf_get_text(buf,
    right_range[1], right_range[2],
    right_range[3], right_range[4],
    {}
  )

  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    right_range[1], right_range[2],
    right_range[3], right_range[4],
    left_text
  )
  if cursor_pos == 1 then
    vim.api.nvim_win_set_cursor(0, { right_range[1] + 1, right_range[2] })
  end

  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    left_range[1], left_range[2],
    left_range[3], left_range[4],
    right_text
  )
  if cursor_pos == 0 then
    vim.api.nvim_win_set_cursor(0, { left_range[1] + 1, left_range[2] })
  end
end

return M
