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
| `vscode/settings.json`   | VSCode User `settings.json`    |
| `vscode/keybindings.json`| VSCode User `keybindings.json` |
| `vscode/snippets`        | VSCode User `snippets/`        |
| `vscode/extensions.txt`  | installed via `code --install-extension` |
| `Brewfile`               | `brew bundle install` (formulae, casks, global npm packages) |

## Install on a new machine

```sh
git clone --recurse-submodules https://github.com/ssssed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh`:
- inits submodules
- runs `brew bundle install` from `Brewfile` (formulae, casks, global npm packages) if `brew` is present
- installs oh-my-zsh if missing, plus `zsh-syntax-highlighting` / `zsh-autosuggestions`
- symlinks every file above into place, backing up any existing real file under `~/.dotfiles-backup/<timestamp>/`
- creates `~/.zsh_secrets` from the example template if missing

Safe to re-run; already-correct symlinks are left alone.

### VSCode only

`install.sh` already calls it, but it also runs standalone if you only want
VSCode settings/snippets/extensions on a machine (no shell/git/nvim changes):

```sh
./install-vscode.sh
```

Needs the `code` CLI on PATH (VSCode: Cmd+Shift+P > "Shell Command: Install
'code' command in PATH") to install extensions; settings/snippets/keybindings
link regardless.

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
