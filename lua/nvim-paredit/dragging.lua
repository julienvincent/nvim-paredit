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

  local root = lang.getNodeRoot(current_form)

  local sibling = root:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(root, sibling, 0, true)
end

function M.dragFormBackwards()
  local lang = langs.getLanguageApi()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local root = lang.getNodeRoot(current_form)

  local sibling = root:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(root, sibling, 0, true)
end

function M.dragElementForwards()
  local lang = langs.getLanguageApi()
  local current_node = lang.getNodeRoot(ts.get_node_at_cursor())

  local sibling = current_node:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_node, sibling, 0, true)
end

function M.dragElementBackwards()
  local lang = langs.getLanguageApi()
  local current_node = lang.getNodeRoot(ts.get_node_at_cursor())

  local sibling = current_node:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_node, sibling, 0, true)
end

return M
