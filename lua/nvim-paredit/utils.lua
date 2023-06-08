local ts = require("nvim-treesitter.ts_utils")

local M = {}

function M.includedInTable(table, item)
  for _, value in pairs(table) do
    if value == item then
      return true
    end
  end
  return false
end

function M.findNearestForm(current_node, opts)
  if M.includedInTable(opts.form_types, current_node:type()) then
    if not (opts.exclude_node and opts.exclude_node:equal(current_node)) then
      return current_node
    end
  end

  local parent = current_node:parent()
  if parent then
    return M.findNearestForm(parent, opts)
  end

  -- We are in the root document, which we can consider a form. TODO: Find a better name for this function
  return current_node
end

function M.findNextClosestSibling(current_node)
  local sibling = current_node:next_named_sibling()
  if sibling then
    return current_node, sibling
  end

  local parent = current_node:parent()
  if parent then
    return M.findNextClosestSibling(parent)
  end
end

function M.getLastChild(node)
  local index = node:named_child_count() - 1
  if index < 0 then
    return
  end

  return node:named_child(index)
end

function M.findNextFurthestSibling(current_node)
  local last_child = M.getLastChild(current_node)
  if last_child then
    return current_node, last_child
  end

  local parent = current_node:parent()
  if parent then
    return M.findNextFurthestSibling(parent)
  end
end

function M.getOuterChildOfNode(root, child)
  local parent = child:parent()
  if not parent then
    return child
  end
  if root:equal(parent) then
    return child
  end
  return M.getOuterChildOfNode(root, parent)
end

return M
