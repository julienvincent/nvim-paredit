local M = {}

-- This is a hack to enable dot-repeat for fn keymaps.
--
-- For more information on how this works, see:
-- https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
--
-- For this to work in a keymap, make sure `expr = true` is defined:
--  vim.keymap.set("n", "lhs", with_repeat(function() end), { expr = true })
function M.with_repeat(fn)
  return function()
    _G.NVIM_PAREDIT_REPEAT_FN = function()
      fn()
    end
    vim.go.operatorfunc = "v:lua.NVIM_PAREDIT_REPEAT_FN"
    return "g@l"
  end
end

function M.setup_keybindings(opts)
  for keymap, action in pairs(opts.keys) do
    if not action then
      return
    end

    local repeatable = true
    if type(action.repeatable) == "boolean" then
      repeatable = action.repeatable
    end

    local fn = action[1]
    if repeatable then
      fn = M.with_repeat(fn)
    end

    vim.keymap.set(action.mode or { "n", "x" }, keymap, fn, {
      desc = action[2],
      buffer = opts.buf or 0,
      expr = repeatable,
      remap = false,
      silent = true,
    })
  end
end

return M
