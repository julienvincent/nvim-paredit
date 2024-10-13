local keybindings = require("nvim-paredit.utils.keybindings")
local common = require("nvim-paredit.utils.common")
local defaults = require("nvim-paredit.defaults")
local config = require("nvim-paredit.config")
local lang = require("nvim-paredit.lang")

local function setup_keybingings(buf)
  local keys = config.config.keys
  keybindings.setup_keybindings({
    keys = keys,
    buf = buf,
  })
end

local M = {
  api = require("nvim-paredit.api"),
  wrap = require("nvim-paredit.api.wrap"),
  unwrap = require("nvim-paredit.api.unwrap"),
  cursor = require("nvim-paredit.api.cursor"),
  extension = {
    add_language_extension = lang.add_language_extension,
  },
}

function M.setup(opts)
  opts = opts or {}

  local keys = opts.keys or {}

  if type(opts.use_default_keys) ~= "boolean" or opts.use_default_keys then
    keys = vim.tbl_deep_extend("force", defaults.default_keys, opts.keys or {})
  end

  config.update_config(defaults.defaults)
  config.update_config(vim.tbl_deep_extend("force", opts, {
    keys = keys,
  }))

  if common.included_in_table(config.config.filetypes, vim.bo.filetype) then
    setup_keybingings()
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("Paredit", { clear = true }),
    pattern = config.config.filetypes,
    callback = function(event)
      setup_keybingings(event.buf)
    end,
  })
end

return M
