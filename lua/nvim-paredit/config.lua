local M = {}

M.config = {}

function M.update_config(config)
  M.config = vim.tbl_deep_extend("force", M.config, config)
end

return M
