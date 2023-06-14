local common = require("nvim-paredit.utils.common")

local M = {}

M.config = {}

function M.update_config(config)
  M.config = common.merge(M.config, config)
end

return M
