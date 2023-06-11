local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.drag_form_forwards()
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local root = lang.get_node_root(current_form)

  local sibling = root:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(root, sibling, 0, true)
end

function M.drag_form_backwards()
  local lang = langs.get_language_api()
  local current_form = utils.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang
  })
  if not current_form then
    return
  end

  local root = lang.get_node_root(current_form)

  local sibling = root:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(root, sibling, 0, true)
end

function M.drag_element_forwards()
  local lang = langs.get_language_api()
  local current_node = lang.get_node_root(ts.get_node_at_cursor())

  local sibling = current_node:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_node, sibling, 0, true)
end

function M.drag_element_backwards()
  local lang = langs.get_language_api()
  local current_node = lang.get_node_root(ts.get_node_at_cursor())

  local sibling = current_node:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_node, sibling, 0, true)
end

return M
