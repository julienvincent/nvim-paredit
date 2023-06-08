local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.moveToNextElement()
  local lang = langs.getLanguageApi()
  local current_node = ts.get_node_at_cursor()

  local search_point = current_node
  if lang.nodeIsForm(current_node) then
    search_point = current_node:parent()
  end

  local root = utils.findNearestForm(search_point, {
    lang = lang
  })
  local current_element = utils.findElementRoot(root, current_node)
  if not current_element then
    return
  end

  local sibling = current_element:next_named_sibling()
  if not sibling then
    return
  end

  local pos = { sibling:end_() }
  vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] - 1 })
end

function M.moveToPrevElement()
  local lang = langs.getLanguageApi()
  local current_node = ts.get_node_at_cursor()

  local search_point = current_node
  if lang.nodeIsForm(current_node) then
    search_point = current_node:parent()
  end

  local root = utils.findNearestForm(search_point, {
    lang = lang
  })
  local current_element = utils.findElementRoot(root, current_node)
  if not current_element then
    return
  end

  local sibling = current_element:prev_named_sibling()
  if not sibling then
    return
  end

  local pos = { sibling:start() }
  vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

return M
