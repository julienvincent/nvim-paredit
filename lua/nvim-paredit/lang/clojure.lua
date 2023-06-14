local utils = require("nvim-paredit.utils")

local M = {}

local form_types = {
  "list_lit",
  "vec_lit",
  "map_lit",
  "set_lit",
  "anon_fn_lit",
}

local function find_next_parent_form(current_node)
  if utils.included_in_table(form_types, current_node:type()) then
    return current_node
  end

  local parent = current_node:parent()
  if parent then
    return find_next_parent_form(parent)
  end

  return current_node
end

function M.get_node_root(node)
  local search_point = node
  if M.node_is_form(node) then
    search_point = node:parent()
  end

  local root = find_next_parent_form(search_point)
  return utils.find_root_element_relative_to(root, node)
end

function M.unwrap_form(node)
  if utils.included_in_table(form_types, node:type()) then
    return node
  end
  local child = node:named_child(0)
  if child then
    return M.unwrap_form(child)
  end
end

function M.node_is_form(node)
  if M.unwrap_form(node) then
    return true
  else
    return false
  end
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
      marker_start,
      marker_end,
      left_range[3],
      left_range[4],
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
      range = right_range,
    },
  }
end

return M
