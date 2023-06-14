local utils = require("nvim-paredit.utils")

local M = {}

M.config = {}

function M.update_config(config)
  M.config = utils.merge(M.config, config)
end

return M
