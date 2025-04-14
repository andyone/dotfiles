## `.dotfiles`

A set of `zsh`, `git`, `tig`, and `tmux` configuration files.

### Installation

```
bash <(curl -fsSL https://andy.one/dotfiles/install.sh)
```

### Extra commands

| Name | Description |
|------|-------------|
| `tx` | Start or attach to TMUX session |
| `txn {name}` | Rename current pane |
| `txc` | Rename current TMUX window to short path to current directory |
| `sshk …` | `ssh` command without checking and saving host key |
| `ssht …` | `sshk` to many hosts at once (_requires TMUX session_) |
| `scpk …` | `scp` command without checking and saving host key |
| `dl …` | Download one or more files using `curl` |
| `e …` | Editor (_nano_) shortcut |
| `b …` | [`bat`](https://github.com/sharkdp/bat) shortcut |
| `g …` | `grep` shortcut |
| `d …` | Docker shortcut |
| `dr …` | Docker `run` shortcut |
| `de …` | Docker `exec` shortcut |
| `k …` | `kubectl` shortcut |
| `kd …` | `kubectl describe` shortcut |
| `ka …` | `kubectl apply -f` shortcut |
| `kn {namespace}` | Set k8s namespace |
| `kl {resource} {option}…` | View k8s resource logs |
| `ks {pod}` | Connect to k8s pod |
| `lll …` | List files and directories using [`eza`](https://github.com/eza-community/eza) |
| `llg …` | List files and directories using [`eza`](https://github.com/eza-community/eza) with `git` status |
| `hf …` | `grep` over zsh history |
| `goc` | Create HTML coverage report for Go sources |
| `gcl {org}/{repo}` | Clone repository with Go sources |
| `bkp {file}` | Create backup for file or directory |
| `flat {file}` | Print flatten list of records |
| `git release {version}` | Add signed version tag for the latest commit to the master branch |
| `git tag-delete {tag}` | Delete tag everywhere |
| `git tag-update {tag}` | Update tag to the latest commit |
| `git pr {pr}` | Fetch PR with given ID from GitHub |
| `git undo` | Undo previous commit |

### Git aliases

| Alias | Original   |
|-------|------------|
| `st`  | `status`   |
| `ci`  | `commit`   |
| `br`  | `branch`   |
| `co`  | `checkout` |
| `df`  | `diff`     |
| `dfi` | `icdiff`   |
| `lg`  | `log`      |

### Tmux hotkey cheatsheet

| Hotkey | Action |
|--------|--------|
| <kbd>CTRL</kbd>+<kbd>B</kbd> | Prefix key |
| <kbd>CTRL</kbd>+<kbd>T</kbd> | Toggle panes names |
| <kbd>CTRL</kbd>+<kbd>Z</kbd> | Toggle pane zoom |
| <kbd>CTRL</kbd>+<kbd>Q</kbd> | Show session tree |
| <kbd>CTRL</kbd>+<kbd>L</kbd> | Clear terminal |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>T</kbd> | Show current time |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>С</kbd> | Create new window |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>R</kbd> | Rearrange windows |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>W</kbd> | List windows |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>\|</kbd> | Split window vertically |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>\-</kbd> | Split window horizontally |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>,</kbd> | Set window name |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>N</kbd> | Next window |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>P</kbd> | Previous window |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>A</kbd> | Toggle panes syncing |
| <kbd>CTRL</kbd>+<kbd>←</kbd> | Move current window to the left (_reorder windows_) |
| <kbd>CTRL</kbd>+<kbd>→</kbd> | Move current window to the right (_reorder windows_) |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>Q</kbd> | Show pane numbers |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>X</kbd> | Kill pane |
| <kbd>ALT</kbd>+<kbd>←</kbd> | Select pane on the left |
| <kbd>ALT</kbd>+<kbd>→</kbd> | Select pane on the right |
| <kbd>ALT</kbd>+<kbd>↑</kbd> | Select upper pane |
| <kbd>ALT</kbd>+<kbd>↓</kbd> | Select bottom pane |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>Space</kbd> | Set panes layout |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>1</kbd> | Set panes layout to layout 1 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>2</kbd> | Set panes layout to layout 2 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>3</kbd> | Set panes layout to layout 3 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>4</kbd> | Set panes layout to layout 4 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>5</kbd> | Set panes layout to layout 5 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>ALT</kbd>+<kbd>6</kbd> | Set panes layout to layout 6 |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>PgUp</kbd> | Scroll up |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>PgDn</kbd> | Scroll down |
| <kbd>F1</kbd> | Select window #1 |
| <kbd>F2</kbd> | Select window #2 |
| <kbd>F3</kbd> | Select window #3 |
| <kbd>F4</kbd> | Select window #4 |
| <kbd>F5</kbd> | Select window #5 |
| <kbd>F6</kbd> | Select window #6 |
| <kbd>F7</kbd> | Select window #7 |
| <kbd>F8</kbd> | Select window #8 |
| <kbd>F9</kbd> | Select window #9 |
| <kbd>F10</kbd> | Select window #10 |
| <kbd>F11</kbd> | Select window #11 |
| <kbd>F12</kbd> | Kill current window |
| <kbd>CTRL</kbd>+<kbd>R</kbd> | History search with [fzf](https://github.com/junegunn/fzf) |

_For function keys support in XShell 5+ you should use custom [mappings file](xshell.tkm)._
