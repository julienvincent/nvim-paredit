<div align="center">
  <h1>nvim-paredit</h1>
</div>

<div align="center">
  <p>
    <img src="assets/logo.png" align="center" alt="Logo" />
  </p>
  <p>
    A <a href="https://paredit.org/">Paredit</a> implementation for <a href="https://github.com/neovim/neovim/">Neovim</a>, built using <a href="https://github.com/tree-sitter/tree-sitter">Treesitter</a> and written in Lua.
  </p>
</div>

The goal of `nvim-paredit` is to provide a comparable s-expression editing experience in Neovim to that provided by Emacs. This is what is provided:

- Treesitter based lisp structural editing, cursor motions and text object selections
- Dot-repeatable keybindings
- Language extensibility
- Programmable API

---

![Demo](./assets/demo.gif)

## Project Status

This is currently **beta software**. It works well in the workflows of the current maintainers but has not been thoroughly tested with many users.

It currently only has first-class support for the `clojure` language and has a focus on supporting the fundamental paredit operations and motions.

## Installation

### Using [folke/lazy.vim](https://github.com/folke/lazy.nvim)

```lua
{
  "julienvincent/nvim-paredit",
  config = function()
    require("nvim-paredit").setup()
  end
}
```

## Configuration

```lua
paredit = require("nvim-paredit");
paredit.setup({
  -- should plugin use default keybindings? (default = true)
  use_default_keys = true,
  -- sometimes user wants to restrict plugin to certain file types only
  -- defaults to all supported file types including custom lang
  -- extensions (see next section)
  filetypes = { "clojure" },

  -- This controls where the cursor is placed when performing slurp/barf operations
  --
  -- - "remain" - It will never change the cursor position, keeping it in the same place
  -- - "follow" - It will always place the cursor on the form edge that was moved
  -- - "auto"   - A combination of remain and follow, it will try keep the cursor in the original position
  --              unless doing so would result in the cursor no longer being within the original form. In
  --              this case it will place the cursor on the moved edge
  cursor_behaviour = "auto", -- remain, follow, auto

  indent = {
    -- This controls how nvim-paredit handles indentation when performing operations which
    -- should change the indentation of the form (such as when slurping or barfing).
    --
    -- When set to true then it will attempt to fix the indentation of nodes operated on.
    enabled = false,
    -- A function that will be called after a slurp/barf if you want to provide a custom indentation
    -- implementation.
    indentor = require("nvim-paredit.indentation.native").indentor,
  },

  -- list of default keybindings
  keys = {
    [">)"] = { paredit.api.slurp_forwards, "Slurp forwards" },
    [">("] = { paredit.api.slurp_backwards, "Slurp backwards" },

    ["<)"] = { paredit.api.barf_forwards, "Barf forwards" },
    ["<("] = { paredit.api.barf_backwards, "Barf backwards" },

    [">e"] = { paredit.api.drag_element_forwards, "Drag element right" },
    ["<e"] = { paredit.api.drag_element_backwards, "Drag element left" },

    [">f"] = { paredit.api.drag_form_forwards, "Drag form right" },
    ["<f"] = { paredit.api.drag_form_backwards, "Drag form left" },

    ["<localleader>o"] = { paredit.api.raise_form, "Raise form" },
    ["<localleader>O"] = { paredit.api.raise_element, "Raise element" },

    ["E"] = {
      paredit.api.move_to_next_element,
      "Jump to next element tail",
      -- by default all keybindings are dot repeatable
      repeatable = false,
      mode = { "n", "x", "o", "v" },
    },
    ["B"] = {
      paredit.api.move_to_prev_element,
      "Jump to previous element head",
      repeatable = false,
      mode = { "n", "x", "o", "v" },
    },

    -- These are text object selection keybindings which can used with standard `d, y, c`, `v`
    ["af"] = {
      paredit.api.select_around_form,
      "Around form",
      repeatable = false,
      mode = { "o", "v" }
    },
    ["if"] = {
      paredit.api.select_in_form,
      "In form",
      repeatable = false,
      mode = { "o", "v" }
    },
    ["ae"] = {
      paredit.api.select_element,
      "Around element",
      repeatable = false,
      mode = { "o", "v" },
    },
    ["ie"] = {
      paredit.api.select_element,
      "Element",
      repeatable = false,
      mode = { "o", "v" },
    },
  }
})
```

## Auto Indentation

Nvim-paredit comes with built-in support for fixing form indentation when performing slurp and barf operations. By default this behaviour is disabled and can be enabled by setting `indent.enabled = true` in the [configuration](#configuration)

The main goal of this implementation is to provide a visual aid to the user, allowing them to confirm they are operating on the correct node and to know when to stop when performing recursive slurp/barf operations. This implementation is fast and does not result in any UI lag or jitter.

The goal is _not_ to be 100% correct. The implementation follows a simple set of rules which account for most scenarios but not all. If a more correct implementation is needed then the native implementation can be replaced by setting the configuration property `intent.indentor`. For example an implementation using `vim.lsp.buf.format` could be built if the user doesn't mind sacrificing performance for correctness.

### Recipes

<details>
  <summary><code>vim.lsp.buf.format</code></summary>

  Below is a reference implementation for using `vim.lsp.buf.format` to replace the native implementation. This implementation won't be nearly as performant but it will be more correct.

  ```lua
  local function lsp_indent(event, opts)
    local traversal = require("nvim-paredit.utils.traversal")
    local utils = require("nvim-paredit.indentation.utils")
    local langs = require("nvim-paredit.lang")

    local lang = langs.get_language_api()

    local parent = event.parent

    local child
    if event.type == "slurp-forwards" then
      child = parent:named_child(parent:named_child_count() - 1)
    elseif event.type == "slurp-backwards" then
      child = parent:named_child(1)
    elseif event.type == "barf-forwards" then
      child = traversal.get_next_sibling_ignoring_comments(event.parent, { lang = lang })
    elseif event.type == "barf-backwards" then
      child = event.parent
    else
      return
    end

    local child_range = { child:range() }
    local lines = utils.find_affected_lines(child, utils.get_node_line_range(child_range))

    vim.lsp.buf.format({
      bufnr = opts.buf or 0,
      range = {
        ["start"] = { lines[1] + 1, 0 },
        ["end"] = { lines[#lines] + 1, 0 },
      },
    })
  end

  require("nvim-paredit").setup({
    indent = {
      enabled = true,
      indentor = lsp_indent
    }
  })
  ```
</details>

## Language Support

As this is built using Treesitter it requires that you have the relevant Treesitter grammar installed for your language of choice. Additionally `nvim-paredit` will need explicit support for the treesitter grammar as the node names and metadata of nodes vary between languages.

Right now `nvim-paredit` only has built in support for `clojure` but exposes an extension API for adding support for other lisp dialects. This API is considered **very alpha** and may change without warning to properly account for other languages when attempts are made to add support.

Extensions can either be added as config when calling `setup`:

```lua
require("nvim-paredit").setup({
  extensions = {
    commonlisp = {
      -- Should return the 'root' of the given Treesitter node. For example:
      -- The node at cursor in the below example is `()` or 'list_lit':
      --   '(|)
      -- But the node root is `'()` or 'quoting_lit'
      get_node_root = function(node)
      end,
      -- This is the inverse of `get_node_root` for forms and should find the inner node for which
      -- the forms elements are direct children.
      --
      -- For example given the node `'()` or 'quoting_lit', this function should return `()` or 'list_lit'.
      unwrap_form = function(node)
      end,
      -- Accepts a Treesitter node and should return true or false depending on whether the given node
      -- can be considered a 'form'
      node_is_form = function(node)
      end,
      -- Accepts a Treesitter node and should return true or false depending on whether the given node
      -- can be considered a 'comment'
      node_is_comment = function(node)
      end,
      -- Accepts a Treesitter node representing a form and should return the 'edges' of the node. This
      -- includes the node text and the range covered by the node
      get_node_edges = function(node)
        return {
          left = { text = "#{", range = { 0, 0, 0, 2 } },
          right = { text = "}", range = { 0, 5, 0, 6 } },
        }
      end,
    }
  }
})
```

Or by calling the `add_language_extension` API directly before the setup. This would be the recommended approach for extension plugin authors.

```lua
require("nvim-paredit").extension.add_language_extension("commonlisp", { ... }).
```

### Existing Language Extensions

+ [fennel](https://github.com/julienvincent/nvim-paredit-fennel)

---

As no attempt has been made to add support for other grammars I have no idea if the language extension API's are actually sufficient for adding additional languages. They will evolve as attempts are made.

## API

The core API is exposed as `paredit.api`:

```lua
local paredit = require("nvim-paredit")
paredit.api.slurp_forwards()
```

- **`slurp_forwards`**
- **`slurp_backwards`**
- **`barf_forwards`**
- **`barf_backwards`**
- **`drag_element_forwards`**
- **`drag_element_backwards`**
- **`drag_form_forwards`**
- **`drag_form_backwards`**
- **`raise_element`**
- **`raise_form`**
- **`delete_form`**
- **`delete_in_form`**
- **`delete_element`**
- **`move_to_next_element`**
- **`move_to_prev_element`**

Form/element wrap api is in `paredit.wrap` module:

- **`wrap_element_under_cursor`** - accepts prefix and suffix, returns wrapped `TSNode`
- **`wrap_enclosing_form_under_cursor`** - accepts prefix and suffix, returns wrapped `TSNode`

Cursor api `paredit.cursor`

- **`place_cursor`** - accepts `TSNode`, and following options:
  - `placement` - enumeration `left_edge`,`inner_start`,`inner_end`,`right_edge`
  - `mode` - currently only `insert` is supported, defaults to `normal`

## API usage recipes

### `vim-sexp` wrap form (head/tail) replication

Require api module:
```lua
local paredit = require("nvim-paredit.api")
```
Add following keybindings to config:
```lua
["<localleader>w"] = {
  function()
    -- place cursor and set mode to `insert`
    paredit.cursor.place_cursor(
      -- wrap element under cursor with `( ` and `)`
      paredit.wrap.wrap_element_under_cursor("( ", ")"),
      -- cursor placement opts
      { placement = "inner_start", mode = "insert" }
    )
  end,
  "Wrap element insert head",
},

["<localleader>W"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_element_under_cursor("(", ")"),
      { placement = "inner_end", mode = "insert" }
    )
  end,
  "Wrap element insert tail",
},

-- same as above but for enclosing form
["<localleader>i"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_enclosing_form_under_cursor("( ", ")"),
      { placement = "inner_start", mode = "insert" }
    )
  end,
  "Wrap form insert head",
},

["<localleader>I"] = {
  function()
    paredit.cursor.place_cursor(
      paredit.wrap.wrap_enclosing_form_under_cursor("(", ")"),
      { placement = "inner_end", mode = "insert" }
    )
  end,
  "Wrap form insert tail",
}
```
Same approach can be used for other `vim-sexp` keybindings (e.g. `<localleader>e[`) with cursor placement or without.

## Prior Art

### [vim-sexp](https://github.com/guns/vim-sexp)

Currently the de-facto s-expression editing plugin with the most extensive set of available editing operations. If you are looking for a more complete plugin with a wider range of supported languages then you might want to look into using this instead.

The main reasons you might want to consider `nvim-paredit` instead are:

- Easier configuration and an exposed lua API
- Control over how the cursor is moved during slurp/barf. (For example if you don't want the cursor to always be moved)
- Recursive slurp/barf operations. If your cursor is in a nested form you can still slurp from the forms parent(s)
- Automatic form/element indentations on slurp/barf
- Subjectively better out-of-the-box keybindings

### [vim-sexp-mappings-for-regular-people](https://github.com/tpope/vim-sexp-mappings-for-regular-people)

A companion to `vim-sexp` which configures `vim-sexp` with better mappings. The default mappings for `nvim-paredit` were derived from here.
