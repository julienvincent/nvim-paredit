local ts_context = require("nvim-paredit.treesitter.context")
local selections = require("nvim-paredit.api.selections")

local M = {}

local function delete_form_impl(range)
  if not range then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )
end

function M.delete_form()
  delete_form_impl(selections.get_range_around_form())
end

function M.delete_top_level_form()
  delete_form_impl(selections.get_range_around_top_level_form())
end

local function delete_in_form_impl(range)
  if not range then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )

  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
end

function M.delete_in_form()
  delete_in_form_impl(selections.get_range_in_form())
end

function M.delete_in_top_level_form()
  delete_in_form_impl(selections.get_range_in_top_level_form())
end

function M.delete_element()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local range = selections.get_element_range(context)

  local buf = vim.api.nvim_get_current_buf()
  -- stylua: ignore
  vim.api.nvim_buf_set_text(
    buf,
    range[1], range[2],
    range[3], range[4],
    {}
  )
end

return M
