<div align="center">
  <h1>nvim-paredit</h1>
</div>

<div align="center">
  <p>
    A <a href="https://paredit.org/">Paredit</a> implementation for <a href="https://github.com/neovim/neovim/">Neovim</a>, built using <a href="https://github.com/tree-sitter/tree-sitter">Treesitter</a> and written in Lua.
  </p>
</div>

The goal of `nvim-paredit` is to provide a comparable s-expression editing experience in Neovim to that provided by Emacs.

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
{
  "julienvincent/nvim-paredit",
  config = function()
    local paredit = require("nvim-paredit")
    paredit.setup({
      use_default_keys = true,
      keys = {
        [">)"] = { paredit.api.slurpForwards, "Slurp forwards" },
        [">("] = { paredit.api.slurpBackwards, "Slurp backwards" },

        ["<)"] = { paredit.api.slurpForwards, "Barf forwards" },
        ["<("] = { paredit.api.slurpBackwards, "Barf backwards" },

        [">e"] = { paredit.api.dragElementForwards, "Drag element right" },
        ["<e"] = { paredit.api.dragElementBackwards, "Drag element left" },

        [">f"] = { paredit.api.dragFormForwards, "Drag form right" },
        ["<f"] = { paredit.api.dragFormBackwards, "Drag form left" },

        ["<localleader>o"] = { paredit.api.raiseForm, "Raise form" },
        ["<localleader>O"] = { paredit.api.raiseElement, "Raise element" },

        ["E"] = { paredit.api.moveToNextElement, "Jump to next element tail" },
        ["B"] = { paredit.api.moveToPrevElement, "Jump to previous element head" },
      }
    })
  end
}
```

## Language Support

As this is built using Treesitter it requires that you have the relevant Treesitter grammar installed for your language of choice. Additionally `nvim-paredit` will need explicit support for the treesitter grammar as the node names and metadata of nodes vary between languages. 

Right now `nvim-paredit` has built in support for the following languages:

+ `clojure`

To add support for another language you can either open a PR against this repo or you can use the extention API:

```lua
paredit.setup({
  extensions = {
    fennel = {
      -- Accepts a Treesitter node and should return true or false depending on wether the given node
      -- can be considered a 'form'
      nodeIsForm = function(node)
        ...
      end,
      -- Accepts a Treesitter node representing a form and should return the 'edges' of the node. This
      -- includes the node text and the range covered by the node
      getNodeEdges = function(node)
        return {
          left = { text = "#{", range = { 0, 0, 0, 2 } },
          right = { text = "}", range = { 0, 5, 0, 6 } },
        }
      end,
    }
  }
})
```

## API

The api is exposed as `paredit.api`:

```lua
local paredit = require("nvim-paredit")
paredit.api.slurpForwards()
```

Currently there are no automatic keybindings that get setup, so this is left up to the user to configure.

### **`slurpForwards`**
### **`slurpBackwards`** [TODO]
### **`barfForwards`**
### **`barfBackwards`** [TODO]

### **`dragElementForwards`**
### **`dragElementBackwards`**

### **`dragFormForwards`**
### **`dragFormBackwards`**

### **`raiseElement`**
### **`raiseForm`**
