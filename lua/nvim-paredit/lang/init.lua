local langs = {
  clojure = require("nvim-paredit.lang.clojure")
}

return {
  getLanguageApi = function()
    return langs[vim.bo.filetype]
  end,
  addLanguageExtension = function(filetype, api)
    langs[filetype] = api
  end
}
