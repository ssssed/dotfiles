# dotfiles

Personal config for zsh/oh-my-zsh, git, tmux, kitty, nvim, Claude Code.

## Layout

| Path in repo            | Linked to                     |
|--------------------------|--------------------------------|
| `zsh/.zshrc`             | `~/.zshrc`                     |
| `git/.gitconfig`         | `~/.gitconfig`                 |
| `tmux/.tmux.conf`        | `~/.tmux.conf`                 |
| `kitty/kitty.conf`       | `~/.config/kitty/kitty.conf`   |
| `kitty/kitty-themes`     | `~/.config/kitty/kitty-themes` (submodule, [dexpota/kitty-themes](https://github.com/dexpota/kitty-themes)) |
| `nvim`                   | `~/.config/nvim` (submodule, [ssssed/neovim](https://github.com/ssssed/neovim), branch `v3`) |
| `claude/settings.json`   | `~/.claude/settings.json`      |
| `claude/CLAUDE.md`       | `~/.claude/CLAUDE.md`          |
| `claude/RTK.md`          | `~/.claude/RTK.md`             |
| `claude/statusline.sh`   | `~/.claude/statusline.sh`      |

## Install on a new machine

```sh
git clone --recurse-submodules https://github.com/ssssed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh`:
- inits submodules
- installs oh-my-zsh if missing, plus `zsh-syntax-highlighting` / `zsh-autosuggestions`
- symlinks every file above into place, backing up any existing real file under `~/.dotfiles-backup/<timestamp>/`
- creates `~/.zsh_secrets` from the example template if missing

Safe to re-run; already-correct symlinks are left alone.

## Secrets

`~/.zshrc` sources `~/.zsh_secrets` if present. That file lives outside the repo and is **never committed** — fill in real API keys there after install:

```sh
cp zsh/.zsh_secrets.example ~/.zsh_secrets
$EDITOR ~/.zsh_secrets
```

## Updating

```sh
cd ~/dotfiles
git pull
git submodule update --init --recursive
./install.sh
```
