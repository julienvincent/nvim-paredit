local traversal = require("nvim-paredit.utils.traversal")

local M = {}

-- Use a 'paredit/pairwise' treesitter query to find all nodes within a local
-- branch that are labeled as @pair.
--
-- If any of these labeled nodes match the given target node then return all
-- matched nodes.
function M.find_pairwise_nodes(target_node, opts)
  local root_node = traversal.find_local_root(target_node)

  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)

  local query = vim.treesitter.query.get(lang, "paredit/pairwise")
  if not query then
    return
  end

  local captures = query:iter_captures(root_node, bufnr)
  local pairwise_nodes = {}
  local found = false
  for id, node in captures do
    if query.captures[id] == "pair" then
      if not node:extra() and not opts.lang.node_is_comment(node) then
        table.insert(pairwise_nodes, node)
        if node:equal(target_node) then
          found = true
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
