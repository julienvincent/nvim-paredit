[macos]
prepare-nvim channel:
  #!/usr/bin/env bash
  NVIM_DIR=".build/nvim/{{ channel }}"

  test -d $NVIM_DIR || {
    mkdir -p $NVIM_DIR

    curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-macos.tar.gz > ./.build/nvim-macos.tar.gz
    xattr -c ./.build/nvim-macos.tar.gz
    tar xzf ./.build/nvim-macos.tar.gz -C $NVIM_DIR --strip-components=1
    rm ./.build/nvim-macos.tar.gz
  }

[linux]
prepare-nvim channel:
  #!/usr/bin/env bash
  NVIM_DIR=".build/nvim/{{ channel }}"

  test -d $NVIM_DIR || {
    mkdir -p $NVIM_DIR

    curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-linux64.tar.gz > ./.build/nvim-linux64.tar.gz
    tar xzf ./.build/nvim-linux64.tar.gz -C $NVIM_DIR --strip-components=1
    rm ./.build/nvim-linux64.tar.gz
  }

prepare-dependencies:
  #!/usr/bin/env bash
  test -d .build/dependencies || {
    mkdir -p ./.build/dependencies
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ./.build/dependencies/plenary.nvim
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter ./.build/dependencies/nvim-treesitter
  }

prepare channel: (prepare-nvim channel) prepare-dependencies

test channel="stable" file="": (prepare channel)
  #!/usr/bin/env bash
  NVIM_DIR=".build/nvim/{{ channel }}"

  ./$NVIM_DIR/bin/nvim --version
  ./$NVIM_DIR/bin/nvim \
    --headless \
    --noplugin \
    -u tests/init.lua \
    -c "PlenaryBustedDirectory tests/nvim-paredit/{{ file }} { minimal_init='tests/init.lua', sequential=true }"
