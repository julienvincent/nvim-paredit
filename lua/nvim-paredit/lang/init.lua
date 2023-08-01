local common = require("nvim-paredit.utils.common")

local langs = {
  clojure = require("nvim-paredit.lang.clojure"),
}

local default_whitespace_chars = { " ", "," }

local M = {}

local function keys(tbl)
  local result = {}
  for k, _ in pairs(tbl) do
    table.insert(result, k)
  end
  return result
end

function M.get_language_api()
  return langs[vim.bo.filetype]
end

function M.add_language_extension(filetype, api)
  langs[filetype] = api
end

function M.filetypes()
  return keys(langs)
end

function M.is_whitespace_under_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lang = M.get_language_api()
  cursor = { cursor[1] - 1, cursor[2] }

  local char_under_cursor = vim.api.nvim_buf_get_text(0, cursor[1], cursor[2], cursor[1], cursor[2] + 1, {})
  return common.included_in_table(
    lang.whitespace_chars or default_whitespace_chars,
    char_under_cursor[1]
  ) or char_under_cursor[1] == ""
end

return M
