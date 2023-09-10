local traversal = require("nvim-paredit.utils.traversal")
local common = require("nvim-paredit.utils.common")

local M = {}

function M.get_node_line_range(range)
  local lines = {}
  for i = range[1], range[3], 1 do
    table.insert(lines, i)
  end
  return lines
end

function M.get_node_rhs_siblings(node)
  local nodes = {}
  local current = node
  while current do
    table.insert(nodes, current)
    current = current:next_named_sibling()
  end
  return nodes
end

function M.find_affected_lines(node, lines)
  local siblings = M.get_node_rhs_siblings(node)
  for _, sibling in ipairs(siblings) do
    local range = { sibling:range() }

    local sibling_is_affected = false
    for _, line in ipairs(lines) do
      if line == range[1] then
        sibling_is_affected = true
      end
    end

    if sibling_is_affected then
      local new_lines = M.get_node_line_range(range)
      for _, row in ipairs(new_lines) do
        table.insert(lines, row)
      end
    end
  end

  local parent = node:parent()
  if parent then
    return M.find_affected_lines(parent, lines)
  end

  return common.ordered_set(lines)
end

function M.node_is_first_on_line(node, opts)
  local node_range = { node:range() }

  local sibling = traversal.get_prev_sibling_ignoring_comments(node, opts)
  if not sibling then
    return true
  end

  local sibling_range = { sibling:range() }
  return sibling_range[3] ~= node_range[1]
end

return M
