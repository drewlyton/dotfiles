# dotfiles

My macOS development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Config | Description |
|--------|-------------|
| **aerospace** | [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling window manager |
| **ghostty** | [Ghostty](https://ghostty.org) terminal theme (Tokyo Night Moon) |
| **git** | Global gitignore |
| **nvim** | [Neovim](https://neovim.io) with [LazyVim](https://www.lazyvim.org) |
| **opencode** | [OpenCode](https://opencode.ai) AI tool with custom agents, commands, and MCP integrations |
| **tmux** | [tmux](https://github.com/tmux/tmux) with TPM plugins and Tokyo Night Moon theme |
| **zsh** | [Oh My Zsh](https://ohmyz.sh) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) |

Plus home directory dotfiles: `.zshenv`, `.gitconfig`, `.p10k.zsh`, `.tool-versions`.

## Setup

```sh
git clone https://github.com/drewlyton/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script handles:
- Installing Homebrew and GNU Stow (if missing)
- Symlinking everything into place via `stow`
- Installing Oh My Zsh, Powerlevel10k, and Tmux Plugin Manager

## Secrets

After install, copy the example and fill in the values:

```sh
cp ~/.config/zsh/.secrets.example ~/.config/zsh/.secrets
```

## Structure

```
~/dotfiles/
├── home/           # stowed into ~/
│   ├── .gitconfig
│   ├── .p10k.zsh
│   ├── .tool-versions
│   └── .zshenv
├── config/         # stowed into ~/.config/
│   ├── aerospace/
│   ├── ghostty/
│   ├── git/
│   ├── nvim/
│   ├── opencode/
│   ├── tmux/
│   └── zsh/
└── install.sh
```

## Adding new configs

1. Create the directory under `config/` (or add a file to `home/`)
2. Re-stow: `stow -R -d ~/dotfiles -t ~/.config config`
3. Commit and push

## Post-install steps

- **tmux plugins**: Open tmux and press `prefix + I` to install plugins via TPM
- **nvim plugins**: Open nvim and Lazy will auto-install on first launch
- **opencode plugins**: Run `cd ~/.config/opencode && npm install`
