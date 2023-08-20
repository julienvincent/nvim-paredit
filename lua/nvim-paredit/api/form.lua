local traversal = require("nvim-paredit.utils.traversal")
local ts = require("nvim-treesitter.ts_utils")
local langs = require("nvim-paredit.lang")

local M = {}

local function reparse(buf)
  local parser = vim.treesitter.get_parser(buf, vim.bo.filetype)
  parser:parse()
end

local function find_element_under_cursor(lang)
  local node = ts.get_node_at_cursor()
  if lang.element_lit then
    return lang.element_lit(node)
  end
  return node
end

function M.find_form(element, lang)
  return traversal.find_nearest_form(element, { lang = lang })
end

function M.find_parend_form(element, lang)
  local nearest_form = M.find_form(element, lang)
  local parent = nearest_form

  if nearest_form == element then
    parent = nearest_form:parent()
  end

  if parent then
    return M.find_form(parent, lang)
  end
  return nearest_form
end

function M.wrap_element(buf, element, prefix, suffix)
  prefix = prefix or ""
  suffix = suffix or ""

  local range = { element:range() }
  vim.api.nvim_buf_set_text(buf, range[3], range[4], range[3], range[4], { suffix })
  vim.api.nvim_buf_set_text(buf, range[1], range[2], range[1], range[2], { prefix })
end

function M.wrap_element_under_cursor(prefix, suffix)
  local buf = vim.api.nvim_get_current_buf()
  local lang = langs.get_language_api()
  local current_element = find_element_under_cursor(lang)

  if not current_element then
    return
  end
  if lang.node_is_comment(current_element) then
    return
  end
  if langs.is_whitespace_under_cursor() then
    return
  end

  M.wrap_element(buf, current_element, prefix, suffix)

  reparse(buf)

  current_element = lang.element_lit(ts.get_node_at_cursor())
  return M.find_form(current_element, lang)
end

function M.wrap_enclosing_form_under_cursor(prefix, suffix)
  local buf = vim.api.nvim_get_current_buf()
  local lang = langs.get_language_api()
  local current_element = find_element_under_cursor(lang)

  if not current_element then
    return
  end

  local use_parent = langs.is_whitespace_under_cursor()

  local form
  if use_parent then
    form = M.find_form(current_element, lang)
  else
    form = M.find_parend_form(current_element, lang)
  end

  M.wrap_element(buf, form, prefix, suffix)

  reparse(buf)

  current_element = find_element_under_cursor(lang)
  if use_parent then
    form = current_element
  else
    form = M.find_parend_form(current_element, lang)
  end
  return M.find_parend_form(form, lang)
end

return M
