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

  -- We are in the root of the document, which we can consider a form.
  if type(opts.use_source) ~= "boolean" or opts.use_source then
    return current_node
  end
end

function M.getLastChildIgnoringComments(node, opts)
  local function findFromIndex(index)
    if index < 0 then
      return
    end
    local child = node:named_child(index)
    if not child then
      return
    end
    if child:extra() or opts.lang.nodeIsComment(child) then
      return findFromIndex(index - 1)
    end
    return child
  end

  return findFromIndex(node:named_child_count() - 1)
end

function M.findClosestFormWithChildren(current_node, opts)
  local form = opts.lang.unwrapForm(current_node)
  if form:named_child_count() > 0 and current_node:type() ~= "source" then
    return form
  end

  local parent = current_node:parent()
  if parent then
    return M.findClosestFormWithChildren(parent, opts)
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

function M.getNextSiblingIgnoringComments(node, opts)
  local sibling = node:next_named_sibling()
  if not sibling then
    return
  end

  if sibling:extra() or opts.lang.nodeIsComment(sibling) then
    return M.getNextSiblingIgnoringComments(sibling, opts)
  end

  return sibling
end

function M.getPrevSiblingIgnoringComments(node, opts)
  local sibling = node:prev_named_sibling()
  if not sibling then
    return
  end

  if sibling:extra() or opts.lang.nodeIsComment(sibling) then
    return M.getPrevSiblingIgnoringComments(sibling, opts)
  end

  return sibling
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
function M.findRootElementRelativeTo(root, child)
  local parent = child:parent()
  if not parent then
    return child
  end
  if root:equal(parent) then
    return child
  end
  return M.findRootElementRelativeTo(root, parent)
end

return M
