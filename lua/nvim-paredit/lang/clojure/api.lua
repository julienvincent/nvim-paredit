local utils = require("nvim-paredit.utils")
local ts = require("nvim-treesitter.ts_utils")

local M = {}

local form_types = {
  "tagged_or_ctor_litw",
  "set_lit",
  "list_lit",
  "map_lit",
  "vec_lit",
  "anon_fn_lit",
}

function M.slurpForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = form_types
  })
  if not current_form then
    return
  end

  local left, right = utils.findNextClosestSibling(current_form)
  if not left or not right then
    return
  end

  local buf = vim.api.nvim_get_current_buf()

  local close_bracket_node = left:field("close")[1]
  local close_bracket_text = close_bracket_node:type()

  local right_end = { right:end_() }
  local right_row = right_end[1]
  local right_col = right_end[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { close_bracket_text }
  )

  local close_bracket_range = { close_bracket_node:range() }
  local r1 = close_bracket_range[1]
  local c1 = close_bracket_range[2]
  local r2 = close_bracket_range[3]
  local c2 = close_bracket_range[4]
  vim.api.nvim_buf_set_text(buf,
    r1, c1,
    r2, c2,
    {}
  )
end

function M.slurpBackwards()

end

function M.barfForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = form_types
  })
  if not current_form then
    return
  end

  local left, right = utils.findNextFurthestSibling(current_form)
  if not left or not right then
    return
  end

  local end_pos = {}
  local sibling = right:prev_named_sibling()
  if sibling then
    end_pos = { sibling:end_() }
  else
    end_pos = { left:field("open")[1]:end_() }
  end

  local buf = vim.api.nvim_get_current_buf()

  local close_bracket_node = left:field("close")[1]
  local close_bracket_text = close_bracket_node:type()

  local close_bracket_range = { close_bracket_node:range() }
  local r1 = close_bracket_range[1]
  local c1 = close_bracket_range[2]
  local r2 = close_bracket_range[3]
  local c2 = close_bracket_range[4]
  vim.api.nvim_buf_set_text(buf,
    r1, c1,
    r2, c2,
    {}
  )

  local right_row = end_pos[1]
  local right_col = end_pos[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { close_bracket_text }
  )
end

function M.barfBackwards()

end

function M.dragFormForwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = form_types
  })
  if not current_form then
    return
  end

  local sibling = current_form:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_form, sibling, 0, true)
end

function M.dragFormBackwards()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = form_types
  })
  if not current_form then
    return
  end

  local sibling = current_form:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_form, sibling, 0, true)
end

function M.dragElementForwards()
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = form_types,
    exclude_node = current_node
  })
  local current_element = utils.getOuterChildOfNode(root, current_node)
  if not current_element then
    return
  end

  local sibling = current_element:next_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_element, sibling, 0, true)
end

function M.dragElementBackwards()
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = form_types,
    exclude_node = current_node
  })
  local current_element = utils.getOuterChildOfNode(root, current_node)
  if not current_element then
    return
  end

  local sibling = current_element:prev_named_sibling()
  if not sibling then
    return
  end

  ts.swap_nodes(current_element, sibling, 0, true)
end

function M.raiseForm()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    form_types = form_types
  })
  if not current_form then
    return
  end

  local parent = current_form:parent()
  if not parent then
    return
  end

  local replace_text = vim.treesitter.get_node_text(current_form, 0)

  local parent_range = { parent:range() }
  vim.api.nvim_buf_set_text(0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

function M.raiseElement()
  local current_node = ts.get_node_at_cursor()
  local root = utils.findNearestForm(current_node, {
    form_types = form_types,
    exclude_node = current_node
  })
  local element = utils.getOuterChildOfNode(root, current_node)
  if not element then
    return
  end

  local replace_text = vim.treesitter.get_node_text(element, 0)

  local parent_range = { root:range() }
  vim.api.nvim_buf_set_text(0,
    parent_range[1], parent_range[2],
    parent_range[3], parent_range[4],
    vim.fn.split(replace_text, "\n")
  )
  vim.api.nvim_win_set_cursor(0, { parent_range[1] + 1, parent_range[2] })
end

return M
