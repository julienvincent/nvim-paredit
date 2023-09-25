local traversal = require("nvim-paredit.utils.traversal")
local ts = require("nvim-treesitter.ts_utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.ensure_visual_mode()
  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.api.nvim_command("normal! v")
  end
end

local function get_range_around_form_impl(node_fn)
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
    use_source = false,
  })
  if not current_form then
    return
  end

  local selected = current_form

  if node_fn then
    selected = node_fn(selected)
  end

  local root = lang.get_node_root(selected)
  local range = { root:range() }

  -- stylua: ignore
  return {
    range[1], range[2],
    range[3], range[4],
  }
end

function M.get_range_around_form()
  return get_range_around_form_impl()
end

function M.get_range_around_top_level_form()
  return get_range_around_form_impl(traversal.get_top_level_node_below_document)
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
  local lang = langs.get_language_api()
  local current_form = traversal.find_nearest_form(ts.get_node_at_cursor(), {
    lang = lang,
    use_source = false,
  })
  if not current_form then
    return
  end

  local selected = current_form

  if node_fn then
    selected = node_fn(selected)
  end

  local edges = lang.get_form_edges(selected)

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
  return get_range_in_form_impl(traversal.get_top_level_node_below_document)
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

function M.get_element_range()
  local lang = langs.get_language_api()
  local node = ts.get_node_at_cursor()
  if not node then
    return
  end

  local root = lang.get_node_root(node)
  local range = { root:range() }

  -- stylua: ignore
  return {
    range[1], range[2],
    range[3], range[4]
  }
end

function M.select_element()
  local range = M.get_element_range()
  if not range then
    return
  end

  M.ensure_visual_mode()
  vim.api.nvim_win_set_cursor(0, { range[1] + 1, range[2] })
  vim.api.nvim_command("normal! o")
  vim.api.nvim_win_set_cursor(0, { range[3] + 1, range[4] - 1 })
end

return M
