local utils = require("nvim-paredit.utils")

local M = {}

local markers = {
  "quoting_lit",     -- '()
  "syn_quoting_lit", -- `()
  -- "dis_expr"         -- #_()
}

local form_types = {
  "list_lit",
  "vec_lit",
  "map_lit",
  "set_lit",
  "anon_fn_lit",
}

function M.get_node_root(node)
  local is_form = M.node_is_form(node)
  if is_form then
    local parent = node:parent()
    if utils.included_in_table(markers, parent:type()) then
      return parent
    end
    return node
  end

  local root = utils.find_nearest_form(node, {
    lang = M
  })

  return utils.find_root_element_relative_to(root, node)
end

function M.unwrap_form(node)
  if utils.included_in_table(form_types, node:type()) then
    return node
  end
  local child = node:named_child(0)
  if not child then
    return
  end
  return M.unwrap_form(child)
end

function M.node_is_form(node)
  local type = node:type()
  if utils.included_in_table(form_types, type) then
    return true
  end
  if utils.included_in_table(markers, type) then
    local child = node:named_child(0)
    return child and utils.included_in_table(form_types, child:type())
  end
  return false
end

function M.node_is_comment(node)
  return node:type() == "comment"
end

function M.get_node_edges(node)
  local marker = node:field("marker")[1]

  local left_bracket = node:field("open")[1]
  local right_bracket = node:field("close")[1]

  if not left_bracket or not right_bracket then
    local child = node:named_child(0)
    if child then
      left_bracket = child:field("open")[1]
      right_bracket = child:field("close")[1]
    end
  end

  local left_text = left_bracket:type()
  local left_range = { left_bracket:range() }
  if marker then
    left_text = marker:type() .. left_text
    local marker_start, marker_end = marker:range()
    left_range = {
      marker_start, marker_end,
      left_range[3], left_range[4]
    }
  end

  local right_text = right_bracket:type()
  local right_range = { right_bracket:range() }

  return {
    left = {
      text = left_text,
      range = left_range,
    },
    right = {
      text = right_text,
      range = right_range
    }
  }
end

return M
