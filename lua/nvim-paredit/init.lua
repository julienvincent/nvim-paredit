local keybindings = require("nvim-paredit.utils.keybindings")
local common = require("nvim-paredit.utils.common")
local defaults = require("nvim-paredit.defaults")
local config = require("nvim-paredit.config")
local lang = require("nvim-paredit.lang")

local function setup_keybingings(filetype, buf)
  local whitelist = config.config.filetypes
  local keys = config.config.keys

  if whitelist and not common.included_in_table(whitelist, filetype) then
    return
  end

  if not common.included_in_table(lang.filetypes(), filetype) then
    return
  end

  keybindings.setup_keybindings({
    keys = keys,
    buf = buf,
  })
end

local function add_language_extension(ft, api)
  lang.add_language_extension(ft, api)

  if vim.bo.filetype == ft then
    setup_keybingings(ft, vim.api.nvim_get_current_buf())
  end
end

local M = {
  api = require("nvim-paredit.api"),
  wrap = require("nvim-paredit.api.wrap"),
  unwrap = require("nvim-paredit.api.unwrap"),
  cursor = require("nvim-paredit.api.cursor"),
  extension = {
    add_language_extension = add_language_extension,
  },
}

function M.setup(opts)
  opts = opts or {}

  for filetype, api in pairs(opts.extensions or {}) do
    lang.add_language_extension(filetype, api)
  end

  local keys = opts.keys or {}

  if type(opts.use_default_keys) ~= "boolean" or opts.use_default_keys then
    keys = vim.tbl_deep_extend("force", defaults.default_keys, opts.keys or {})
  end

  config.update_config(defaults.defaults)
  config.update_config(vim.tbl_deep_extend("force", opts, {
    keys = keys,
  }))

  setup_keybingings(vim.bo.filetype)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("Paredit", { clear = true }),
    pattern = "*",
    callback = function(event)
      setup_keybingings(event.match, event.buf)
    end,
  })
end

return M
