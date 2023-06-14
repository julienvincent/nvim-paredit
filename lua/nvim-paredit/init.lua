local keybindings = require("nvim-paredit.utils.keybindings")
local common = require("nvim-paredit.utils.common")
local defaults = require("nvim-paredit.defaults")
local config = require("nvim-paredit.config")
local lang = require("nvim-paredit.lang")

local M = {
  api = require("nvim-paredit.api"),
}

function M.setup(opts)
  config.update_config(common.merge(defaults.defaults, opts))

  for filetype, api in pairs(opts.extensions or {}) do
    lang.add_language_extension(filetype, api)
  end

  if type(opts.use_default_keys) ~= "boolean" or opts.use_default_keys then
    config.update_config({
      keys = common.merge(defaults.default_keys, opts.keys or {})
    })
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("Paredit", { clear = true }),
    pattern = "*",
    callback = function(event)
      if not common.included_in_table(lang.filetypes(), event.match) then
        return
      end

      keybindings.setup_keybindings({
        keys = config.config.keys or {},
        buf = event.buf
      })
    end,
  })
end

return M
