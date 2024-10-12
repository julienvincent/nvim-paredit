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

--- @return table<string, function>
function M.get_language_api()
  for l in string.gmatch(vim.bo.filetype, "[^.]+") do
    if langs[l] ~= nil then
      return langs[l]
    end
  end
  error("Could not find language extension for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
end

function M.add_language_extension(filetype, api)
  langs[filetype] = api
end

function M.filetypes()
  return keys(langs)
end

return M
