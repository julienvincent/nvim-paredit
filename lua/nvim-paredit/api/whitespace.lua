local common = require("nvim-paredit.utils.common")
local config = require("nvim-paredit.config")

local M = {}

local default_whitespace_chars = { " " }

function M.is_whitespace_under_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor = { cursor[1] - 1, cursor[2] }

  -- stylua: ignore
  local char_under_cursor = vim.api.nvim_buf_get_text(0,
    cursor[1], cursor[2],
    cursor[1], cursor[2] + 1,
    {}
  )[1]

  local filetype = vim.api.nvim_get_option_value("filetype", {
    buf = 0,
  })

  local langs = config.config.languages or {}
  local language_config = langs[filetype] or {}
  local whitespace_chars = language_config.whitespace_chars or default_whitespace_chars

  return char_under_cursor == "" or common.included_in_table(whitespace_chars, char_under_cursor)
end

return M
