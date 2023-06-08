local utils = require("nvim-paredit.utils")

local M = {}

local form_types = {
  "tagged_or_ctor_litw",
  "set_lit",
  "list_lit",
  "map_lit",
  "vec_lit",
  "anon_fn_lit",
}

function M.nodeIsForm(node)
  return utils.includedInTable(form_types, node:type())
end

function M.nodeIsComment(node)
  return node:type() == "comment"
end

function M.getNodeEdges(node)
  local left_bracket_node = node:field("open")[1]
  local left_bracket_text = left_bracket_node:type()
  local left_bracket_range = { left_bracket_node:range() }

  local right_bracket_node = node:field("close")[1]
  local right_bracket_text = right_bracket_node:type()
  local right_bracket_range = { right_bracket_node:range() }

  return {
    left = {
      text = left_bracket_text,
      range = left_bracket_range,
    },
    right = {
      text = right_bracket_text,
      range = right_bracket_range
    }
  }
end

return M
