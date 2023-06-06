local utils = require("nvim-paredit.utils")

local langs = {
  clojure = require("nvim-paredit.lang.clojure.api")
}

local M = {}

function call(api)
  local fn = langs[utils.fileType()]
  if fn and fn[api] then
    return fn[api]()
  end
end

function M.slurpForwards()
  return call("slurpForwards")
end

function M.barfForwards()
  return call("barfForwards")
end

return M
