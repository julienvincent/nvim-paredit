local keybindings = require("nvim-paredit.keybindings")
local lang = require("nvim-paredit.lang")
local utils = require("nvim-paredit.utils")

local M = {
  api = require("nvim-paredit.api"),
}

function M.setup(config)
  config = config or {}

  for filetype, api in pairs(config.extensions or {}) do
    lang.add_language_extension(filetype, api)
  end

  local use_default_keys = true
  if type(config.use_default_keys) == "boolean" then
    use_default_keys = config.use_default_keys
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("Paredit", { clear = true }),
    pattern = "*",
    callback = function(event)
      if not utils.included_in_table(lang.filetypes(), event.match) then
        return
      end

      keybindings.setup_keybindings({
        overrides = config.keys or {},
        use_defaults = use_default_keys,
      })
    end,
  })
end

return M
