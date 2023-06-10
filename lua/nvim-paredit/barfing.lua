local ts = require("nvim-treesitter.ts_utils")
local utils = require("nvim-paredit.utils")
local langs = require("nvim-paredit.lang")

local M = {}

function M.barfForwards()
  local lang = langs.getLanguageApi()
  local current_form = utils.findNearestForm(ts.get_node_at_cursor(), {
    use_source = false,
    lang = lang
  })
  if not current_form then
    return
  end

  local form = utils.findClosestFormWithChildren(current_form, {
    lang = lang
  })
  if not form or form:type() == "source" then
    return
  end

  local last_child = utils.getLastChildIgnoringComments(form, {
    lang = lang
  })
  if not last_child then
    return
  end

  local edges = lang.getNodeEdges(form)

  local end_pos = {}
  local sibling = utils.getPrevSiblingIgnoringComments(last_child, {
    lang = lang
  })
  if sibling then
    end_pos = { sibling:end_() }
  else
    end_pos = { edges.left.range[3], edges.left.range[4] }
  end

  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_text(buf,
    edges.right.range[1], edges.right.range[2],
    edges.right.range[3], edges.right.range[4],
    {}
  )

  local right_row = end_pos[1]
  local right_col = end_pos[2]
  vim.api.nvim_buf_set_text(buf,
    right_row, right_col,
    right_row, right_col,
    { edges.right.text }
  )
end

function M.barfBackwards()

end

return M
