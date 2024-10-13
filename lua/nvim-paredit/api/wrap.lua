local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_utils = require("nvim-paredit.treesitter.utils")
local whitespace = require("nvim-paredit.api.whitespace")

local M = {}

local function find_parent_form(element, opts)
  local nearest_form = ts_forms.find_nearest_form(element, {
    captures = opts.captures,
    use_source = false,
  })

  if not nearest_form then
    return element
  end

  local parent = nearest_form

  if nearest_form:equal(element) then
    parent = nearest_form:parent()
  end

  if parent and parent:type() ~= "source" then
    return ts_forms.find_nearest_form(parent, {
      captures = opts.captures,
      use_source = false,
    })
  end
  return nearest_form
end

function M.wrap_element(buf, element, prefix, suffix)
  prefix = prefix or ""
  suffix = suffix or ""

  local range = { element:range() }
  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    range[3], range[4],
    range[3], range[4],
    { suffix }
  )
  -- stylua: ignore
  vim.api.nvim_buf_set_text(buf,
    range[1], range[2],
    range[1], range[2],
    { prefix }
  )
  local end_col
  if range[1] == range[3] then
    end_col = range[4] + prefix:len() + suffix:len() - 1
  else
    end_col = range[4] + suffix:len() - 1
  end
  return {
    range[1],
    range[2],
    range[3],
    end_col,
  }
end

function M.wrap_element_under_cursor(prefix, suffix)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local current_element = ts_forms.get_node_root(context.node, context)
  if not current_element then
    return
  end

  if ts_utils.node_is_comment(current_element, context) then
    return
  end
  if whitespace.is_whitespace_under_cursor() then
    return
  end

  return M.wrap_element(buf, current_element, prefix, suffix)
end

function M.wrap_enclosing_form_under_cursor(prefix, suffix)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local current_element = ts_forms.get_node_root(context.node, context)
  if not current_element then
    return
  end

  local is_whitespace = whitespace.is_whitespace_under_cursor()
  local use_direct_parent = is_whitespace or ts_utils.node_is_comment(context.node, context)

  local form = ts_forms.find_nearest_form(current_element, {
    captures = context.captures,
    use_source = false,
  })
  if not form then
    return
  end

  if not use_direct_parent and form:type() ~= "source" then
    form = find_parent_form(current_element, context)
  end

  return M.wrap_element(buf, form, prefix, suffix)
end

return M
