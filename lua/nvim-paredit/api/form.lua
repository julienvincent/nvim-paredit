local traversal = require("nvim-paredit.utils.traversal")
local ts = require("nvim-treesitter.ts_utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.wrap_element(buf, element, prefix, suffix)
  prefix = prefix or ""
  suffix = suffix or ""

  local range = { element:range() }
  vim.api.nvim_buf_set_text(buf, range[3], range[4], range[3], range[4], { suffix })
  vim.api.nvim_buf_set_text(buf, range[1], range[2], range[1], range[2], { prefix })
end

function M.wrap_element_under_cursor(prefix, suffix)
  if langs.is_whitespace_under_cursor() then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local current_element = ts.get_node_at_cursor()
  if not current_element then
    return
  end

  M.wrap_element(buf, current_element, prefix, suffix)

  local lang = langs.get_language_api()
  local parser = vim.treesitter.get_parser(buf, vim.bo.filetype)
  parser:parse()
  local enclosing_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
  })
  print(vim.treesitter.get_node_text(enclosing_form, buf))
  return enclosing_form
end

return M
