local M = {}

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

local function get_child_ignoring_comments(node, index, opts)
  if index < 0 or index >= node:named_child_count() then
    return
  end
  local child = node:named_child(index)
  if not child then
    return
  end
  if child:extra() or opts.lang.node_is_comment(child) then
    return get_child_ignoring_comments(node, index + opts.direction, opts)
  end
  return child
end

function M.get_last_child_ignoring_comments(node, opts)
  return get_child_ignoring_comments(node, node:named_child_count() - 1, {
    direction = -1,
    lang = opts.lang
  })
end

function M.get_first_child_ignoring_comments(node, opts)
  return get_child_ignoring_comments(node, 0, {
    direction = 1,
    lang = opts.lang
  })
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

local function find_closest_form_with_siblings(current_node, fn)
  if fn(current_node) then
    return current_node
  end
  local parent = current_node:parent()
  if parent then
    return find_closest_form_with_siblings(parent, fn)
  end
end

function M.find_closest_form_with_next_siblings(current_form)
  return find_closest_form_with_siblings(current_form, function(node)
    return node:next_named_sibling()
  end)
end

function M.find_closest_form_with_prev_siblings(current_form)
  return find_closest_form_with_siblings(current_form, function(node)
    return node:prev_named_sibling()
  end)
end

local function get_sibling_ignoring_comments(node, opts)
  local sibling = opts.sibling_fn(node)
  if not sibling then
    return opts.sibling or nil
  end

  if sibling:extra() or opts.lang.node_is_comment(sibling) then
    return get_sibling_ignoring_comments(sibling, opts)
  elseif opts.count > 1 then
    local new_opts = vim.tbl_deep_extend("force", opts, {
      count = opts.count - 1,
      sibling = sibling
    })
    return get_sibling_ignoring_comments(sibling, new_opts)
  end

  return sibling
end

function M.get_next_sibling_ignoring_comments(node, opts)
  return get_sibling_ignoring_comments(node, {
    lang = opts.lang,
    count = opts.count or 1,
    sibling_fn = function(n)
      return n:next_named_sibling()
    end,
  })
end

function M.get_prev_sibling_ignoring_comments(node, opts)
  return get_sibling_ignoring_comments(node, {
    lang = opts.lang,
    count = opts.count or 1,
    sibling_fn = function(n)
      return n:prev_named_sibling()
    end,
  })
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
