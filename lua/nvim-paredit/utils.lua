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
  if opts.lang.nodeIsForm(current_node) then
    return current_node
  end

  local parent = current_node:parent()
  if parent then
    return M.findNearestForm(parent, opts)
  end

  -- We are in the root document, which we can consider a form. TODO: Find a better name for this function
  return current_node
end

function M.getLastChild(node)
  local index = node:named_child_count() - 1
  if index < 0 then
    return
  end
  return node:named_child(index)
end

function M.findClosestFormWithChildren(current_node)
  if current_node:named_child_count() > 0 then
    return current_node
  end

  local parent = current_node:parent()
  if parent then
    return M.findClosestFormWithChildren(parent)
  end
end

function M.findClosestFormWithSiblings(current_node)
  if current_node:next_named_sibling() then
    return current_node
  end
  local parent = current_node:parent()
  if parent then
    return M.findClosestFormWithSiblings(parent)
  end
end

-- Find the root most parent of the given `child` node which is still contained within
-- the given `root` node.
--
-- This is useful to discover the element that we need to operate on within an enclosing
-- form. As an example, take the following senario with the cursor indicated with `|`:
--
-- (:keyword '|(a))
--
-- The enclosing `(` `)` brackets would be given as `root` while the inner list would be
-- given as `child`. The inner list may be wrapped in a `quoting` node, which is the
-- actual node we are wanting to operate on.
function M.findElementRoot(root, child)
  local parent = child:parent()
  if not parent then
    return child
  end
  if root:equal(parent) then
    return child
  end
  return M.findElementRoot(root, parent)
end

return M
