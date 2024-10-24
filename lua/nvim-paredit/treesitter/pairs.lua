local ts_utils = require("nvim-paredit.treesitter.utils")
local ts_forms = require("nvim-paredit.treesitter.forms")

local M = {}

-- Use a 'paredit/pairwise' treesitter query to find all nodes within a local
-- branch that are labeled as @pair.
--
-- If any of these labeled nodes match the given target node then return all
-- matched nodes.
function M.find_pairwise_nodes(target_node, opts)
  local root_node = ts_utils.find_local_root(target_node)
  local enclosing_form = ts_forms.get_node_root(target_node, opts):parent()
  if not enclosing_form then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang then
    return
  end

  local query = vim.treesitter.query.get(lang, "paredit/pairs")
  if not query then
    return
  end

  local captures = query:iter_captures(root_node, bufnr)
  local pairwise_nodes = {}
  local found = false
  for id, node in captures do
    if query.captures[id] == "pair" then
      if not ts_utils.node_is_comment(node, opts) then
        if node:parent():equal(enclosing_form) then
          table.insert(pairwise_nodes, node)
          if node:equal(target_node) then
            found = true
          end
        end
      end
    end
  end

  if not found then
    return
  end

  return pairwise_nodes
end

return M
