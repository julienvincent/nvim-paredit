local M = {}

function M.included_in_table(table, item)
  for _, value in pairs(table) do
    if value == item then
      return true
    end
  end
  return false
end

function M.merge(a, b)
  local result = {}
  for k, v in pairs(a) do
    result[k] = v
  end
  for k, v in pairs(b) do
    result[k] = v
  end
  return result
end

function M.find_nearest_form(current_node, opts)
  if opts.lang.node_is_form(current_node) then
    return current_node
  end

  local parent = current_node:parent()
  if parent then
    return M.find_nearest_form(parent, opts)
  end

  -- We are in the root of the document, which we can consider a form.
  if type(opts.use_source) ~= "boolean" or opts.use_source then
    return current_node
  end
end

function M.get_last_child_ignoring_comments(node, opts)
  local function find_from_index(index)
    if index < 0 then
      return
    end
    local child = node:named_child(index)
    if not child then
      return
    end
    if child:extra() or opts.lang.node_is_comment(child) then
      return find_from_index(index - 1)
    end
    return child
  end

  return find_from_index(node:named_child_count() - 1)
end

function M.find_closest_form_with_children(current_node, opts)
  local form = opts.lang.unwrap_form(current_node)
  if form:named_child_count() > 0 and current_node:type() ~= "source" then
    return form
  end

  local parent = current_node:parent()
  if parent then
    return M.find_closest_form_with_children(parent, opts)
  end
end

local function find_closest_form_with_siblings(current_node, is_next)
  if is_next then
    if current_node:next_named_sibling() then
      return current_node
    end
  else
    if current_node:prev_named_sibling() then
      return current_node
    end
  end
  local parent = current_node:parent()
  if parent then
    return find_closest_form_with_siblings(parent, is_next)
  end
end

function M.find_closest_form_with_next_siblings(current_form)
  return find_closest_form_with_siblings(current_form, true)
end

function M.find_closest_form_with_prev_siblings(current_form)
  return find_closest_form_with_siblings(current_form, false)
end

function M.get_next_sibling_ignoring_comments(node, opts)
  local sibling = node:next_named_sibling()
  if not sibling then
    return
  end

  if sibling:extra() or opts.lang.node_is_comment(sibling) then
    return M.get_next_sibling_ignoring_comments(sibling, opts)
  end

  return sibling
end

function M.get_prev_sibling_ignoring_comments(node, opts)
  local sibling = node:prev_named_sibling()
  if not sibling then
    return
  end

  if sibling:extra() or opts.lang.node_is_comment(sibling) then
    return M.get_prev_sibling_ignoring_comments(sibling, opts)
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

return M
