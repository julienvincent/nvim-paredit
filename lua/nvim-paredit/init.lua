local keybindings = require("nvim-paredit.utils.keybindings")
local common = require("nvim-paredit.utils.common")
local defaults = require("nvim-paredit.defaults")
local config = require("nvim-paredit.config")
local lang = require("nvim-paredit.lang")

local M = {
  api = require("nvim-paredit.api"),
}

local function setup_keybingings(filetype)
  local filetypes = config.config.filetypes
  local keys = config.config.keys

  if common.included_in_table(filetypes, filetype) then
    keybindings.setup_keybindings({
      keys = keys,
      buf = 0,
    })
  end
end

function M.setup(opts)
  for filetype, api in pairs(opts.extensions or {}) do
    lang.add_language_extension(filetype, api)
  end

  local filetypes
  if type(opts.filetypes) == "table" then
    -- substract langs form opts.filetypes to avoid
    -- binding keymaps to unsupported buffers
    filetypes = common.remove_extras(opts.filetypes, lang.filetypes())
  else
    filetypes = lang.filetypes()
  end

  local keys = opts.keys or {}

  if type(opts.use_default_keys) ~= "boolean" or opts.use_default_keys then
    keys = common.merge(defaults.default_keys, opts.keys or {})
  end

  config.update_config(common.merge(opts, {
    filetypes = filetypes,
    keys = keys,
  }))

  setup_keybingings(vim.bo.filetype)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("Paredit", { clear = true }),
    pattern = "*",
    callback = function(event)
      setup_keybingings(event.match)
    end,
  })
end

return M
