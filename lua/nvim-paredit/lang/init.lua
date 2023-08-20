local common = require("nvim-paredit.utils.common")

local langs = {
  clojure = require("nvim-paredit.lang.clojure"),
}

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

return M
