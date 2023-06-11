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
  get_language_api = function()
    return langs[vim.bo.filetype]
  end,

  add_language_extension = function(filetype, api)
    langs[filetype] = api
  end,

  filetypes = function()
    return keys(langs)
  end
}
