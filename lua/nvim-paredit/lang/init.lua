local langs = {
  clojure = require("nvim-paredit.lang.clojure")
}

return {
  getDefinitions = function()
    return langs[vim.bo.filetype]
  end
}
