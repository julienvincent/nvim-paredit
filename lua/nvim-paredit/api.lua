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

function M.dragFormForwards()
  return call("dragFormForwards")
end

function M.dragFormBackwards()
  return call("dragFormBackwards")
end

function M.dragElementForwards()
  return call("dragElementForwards")
end

function M.dragElementBackwards()
  return call("dragElementBackwards")
end

function M.raiseForm()
  return call("raiseForm")
end

function M.raiseElement()
  return call("raiseElement")
end

return M
