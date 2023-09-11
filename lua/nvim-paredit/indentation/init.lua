local config = require("nvim-paredit.config")

local M = {}

function M.handle_indentation(event, opts)
  local indent = opts.indent or config.config.indent or {}
  if not indent.enabled or not indent.indentor then
    return
  end

  local tree = vim.treesitter.get_parser(0)

  tree:parse()
  local parent = tree:named_node_for_range(event.parent_range)

  indent.indentor(
    vim.tbl_deep_extend("force", event, {
      tree = tree,
      parent = parent,
    }),
    vim.tbl_deep_extend("force", opts, {
      indent = indent,
    })
  )
end

return M
