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

- Treesitter based lisp structural editing and cursor motions
- Dot-repeatable keybindings
- Language extensibility
- Programmable API

## Project Status

This is currently **alpha software**.

You will experience bugs and there are still several unimplemented operations. The fundamental operations are mostly complete and probably work as expected in 90% of cases. You can probably switch to using this full time if you can tolerate some oddities and don't need the unimplemented operations.

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

### Using [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "julienvincent/nvim-paredit",
  config = function()
    require('nvim-paredit').setup()
  end,
}
```

## Configuration

```lua
require("nvim-paredit").setup({
  -- should plugin use default keybindings? (default = true)
  use_default_keys = true,
  -- sometimes user wants to restrict plugin to certain file types only
  -- defaults to all supported file types including custom lang
  -- extensions (see next section)
  filetypes = { "clojure" },
  cursor_behaviour = "auto", -- remain, follow, auto
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
      repeatable = false 
    },
    ["B"] = {
      paredit.api.move_to_prev_element, 
      "Jump to previous element head",
      repeatable = false
    },
  }
})
```

## Language Support

As this is built using Treesitter it requires that you have the relevant Treesitter grammar installed for your language of choice. Additionally `nvim-paredit` will need explicit support for the treesitter grammar as the node names and metadata of nodes vary between languages.

Right now `nvim-paredit` only has built in support for `clojure` but exposes an extension API for adding support for other lisp dialects. Extensions can either be added as config when calling `setup`:

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
require("nvim-paredit.lang").add_language_extension("commonlisp", { ... }).
```

## API

The api is exposed as `paredit.api`:

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
- **`move_to_next_element`**
- **`move_to_prev_element`**
