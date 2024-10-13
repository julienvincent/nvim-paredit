local common = require("nvim-paredit.utils.common")

local M = {}

function M.is_document_root(node)
  return node and node:tree():root():equal(node)
end

-- Find the root node of the tree `node` is a member of, excluding the root
-- 'source' document.
function M.find_local_root(node)
  local current = node
  while true do
    local next = current:parent()
    if not next or M.is_document_root(next) then
      break
    end
    current = next
  end
  return current
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
function M.find_root_element_relative_to(root, child)
  local parent = child:parent()
  if not parent then
    return child
  end
  if root:equal(parent) then
    return child
  end
  return M.find_root_element_relative_to(root, parent)
end

function M.node_is_comment(node, opts)
  if node:extra() then
    return true
  end

  if node:type() == "comment" then
    return true
  end

  if common.included_in_table(opts.captures[node:id()] or {}, "comment") then
    return true
  end

  return false
end

return M
