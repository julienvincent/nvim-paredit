local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local lang = require("nvim-paredit.lang")

local M = {}

function M.dragFormForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = lang.getDefinitions().form_types
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
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = lang.getDefinitions().form_types
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
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = lang.getDefinitions().form_types,
    exclude_node = current_node
  })
  local current_element = utils.getOuterChildOfNode(root, current_node)
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
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = lang.getDefinitions().form_types,
    exclude_node = current_node
  })
  local current_element = utils.getOuterChildOfNode(root, current_node)
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
