prepare channel="stable":
  #!/usr/bin/env bash
  test -d .build/nvim || {
    mkdir -p ./.build/nvim

    os=$(uname)
    if [[ "$os" == "Darwin" ]]; then
      curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-macos.tar.gz > ./.build/nvim-macos.tar.gz
      xattr -c ./.build/nvim-macos.tar.gz
      tar xzf ./.build/nvim-macos.tar.gz -C ./.build/nvim --strip-components=1
      rm ./.build/nvim-macos.tar.gz
    elif [[ "$os" == "Linux" ]]; then
      curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-linux64.tar.gz > ./.build/nvim-linux64.tar.gz
      tar xzf ./.build/nvim-linux64.tar.gz -C ./.build/nvim --strip-components=1
      rm ./.build/nvim-linux64.tar.gz
    else
      echo "Unsupported operating system: $os"
      exit 1
    fi
  }

  test -d .build/dependencies || {
    mkdir -p ./.build/dependencies
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ./.build/dependencies/plenary.nvim
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter ./.build/dependencies/nvim-treesitter
  }

tests_dir := "tests/nvim-paredit/"

test: prepare
  ./.build/nvim/bin/nvim --version
  ./.build/nvim/bin/nvim \
    --headless \
    --noplugin \
    -u tests/init.lua \
    -c "PlenaryBustedDirectory tests/nvim-paredit { minimal_init='tests/init.lua', sequential=true }"
