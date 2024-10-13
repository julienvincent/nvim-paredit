local common = require("nvim-paredit.utils.common")

local M = {}

M.add_language_extension = common.deprecate(
  function() end,
  "nvim-paredit.lang.add_language_extension",
  "This API has been completely removed in nvim-paredit@1.0.0.\n\n"
    .. "Nvim-paredit has been redesigned to use treesitter queries instead of language extension APIs\n"
    .. "See https://github.com/julienvincent/nvim-paredit/releases/tag/v1.0.0"
)

return M
