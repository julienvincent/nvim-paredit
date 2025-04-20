local ts_context = require("nvim-paredit.treesitter.context")
local ts_forms = require("nvim-paredit.treesitter.forms")
local ts_utils = require("nvim-paredit.treesitter.utils")

local M = {}

function M.ensure_visual_mode()
  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.api.nvim_command("normal! v")
  end
end

local function adjust_range_for_whitespace(range)
  local start_row, start_col, end_row, end_col = unpack(range)

  local end_line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]
  if end_col < #end_line then
    local after = end_line:sub(end_col + 1, end_col + 2)
    if after:match(" [^;| ]") then
      return { start_row, start_col, end_row, end_col + 1 }
    end
  end

  local start_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
  if start_col > 2 then
    local before = start_line:sub(start_col - 1, start_col)
    if before:match("[^ ] ") then
      return { start_row, start_col - 1, end_row, end_col }
    end
  end
  return { start_row, start_col, end_row, end_col }
end

local function get_range_around_form_impl(node_fn)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, {
    captures = context.captures,
    use_source = false,
  })
  if not current_form then
    return
  end

  local selected = current_form

  if node_fn then
    selected = node_fn(selected)
  end

  local root = ts_forms.get_node_root(selected, context)
  local range = { root:range() }

  -- stylua: ignore
  return adjust_range_for_whitespace({ range[1], range[2], range[3], range[4] })
end

function M.get_range_around_form()
  return get_range_around_form_impl()
end

function M.get_range_around_top_level_form()
  return get_range_around_form_impl(ts_utils.find_local_root)
end

local function select_around_form_impl(range)
  if not range then
    return
  end

  M.ensure_visual_mode()
  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
  vim.api.nvim_command("normal! o")
  vim.api.nvim_win_set_cursor(0, { range[3] + 1, range[4] - 1 })
end

function M.select_around_form()
  return select_around_form_impl(M.get_range_around_form())
end

function M.select_around_top_level_form()
  return select_around_form_impl(M.get_range_around_top_level_form())
end

local function get_range_in_form_impl(node_fn)
  local context = ts_context.create_context()
  if not context then
    return
  end

  local current_form = ts_forms.find_nearest_form(context.node, {
    captures = context.captures,
    use_source = false,
  })
  if not current_form then
    return
  end

  local selected = current_form

  if node_fn then
    selected = node_fn(selected)
  end

  local edges = ts_forms.get_form_edges(selected, context)

  -- stylua: ignore
  return {
    edges.left.range[3], edges.left.range[4],
    edges.right.range[1], edges.right.range[2],
  }
end

function M.get_range_in_form()
  return get_range_in_form_impl()
end

function M.get_range_in_top_level_form()
  return get_range_in_form_impl(ts_utils.find_local_root)
end

local function select_in_form_impl(range)
  if not range then
    return
  end

  M.ensure_visual_mode()
  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
  vim.api.nvim_command("normal! o")
  vim.api.nvim_win_set_cursor(0, { range[3] + 1, range[4] - 1 })
end

function M.select_in_form()
  return select_in_form_impl(M.get_range_in_form())
end

function M.select_in_top_level_form()
  return select_in_form_impl(M.get_range_in_top_level_form())
end

function M.get_element_range(opts)
  local root = ts_forms.get_node_root(opts.node, opts)
  local range = { root:range() }

  -- stylua: ignore
  return {
    range[1], range[2],
    range[3], range[4]
  }
end

function M.select_element()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local range = M.get_element_range(context)

  M.ensure_visual_mode()
  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
  vim.api.nvim_command("normal! o")
  vim.api.nvim_win_set_cursor(0, { range[3] + 1, range[4] - 1 })
end

function M.select_around_element()
  local context = ts_context.create_context()
  if not context then
    return
  end

  local range = adjust_range_for_whitespace(M.get_element_range(context))

  M.ensure_visual_mode()
  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
  vim.api.nvim_command("normal! o")
  vim.api.nvim_win_set_cursor(0, { range[3] + 1, range[4] - 1 })
end

return M
