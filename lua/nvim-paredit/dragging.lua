local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.dragFormForwards()
  local lang = langs.getLanguageApi()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local sibling = current_form:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_form, sibling, 0, true)
end

function M.dragFormBackwards()
  local lang = langs.getLanguageApi()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local sibling = current_form:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_form, sibling, 0, true)
end

function M.dragElementForwards()
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

  ts.swap_nodes(current_element, sibling, 0, true)
end

function M.dragElementBackwards()
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

  ts.swap_nodes(current_element, sibling, 0, true)
end

return M
