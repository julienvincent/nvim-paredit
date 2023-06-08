local lang = require("nvim-paredit.lang")

local M = {
  api = require("nvim-paredit.api")
}

function M.setup (config)
  config = config or {}

  for filetype, api in pairs(config.extensions or {}) do
    lang.addLanguageExtension(filetype, api)
  end
end

return M
