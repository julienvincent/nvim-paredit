local langs = {
  clojure = require("nvim-paredit.lang.clojure")
}

local function keys(tbl)
  local result = {}
  for k, _ in pairs(tbl) do
    table.insert(result, k)
  end
  return result
end

return {
  getLanguageApi = function()
    return langs[vim.bo.filetype]
  end,

  addLanguageExtension = function(filetype, api)
    langs[filetype] = api
  end,

  filetypes = function()
    return keys(langs)
  end
}
