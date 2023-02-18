## `.dotfiles`

A set of zsh, git, tig, and tmux configuration files.

### Installation

```
bash <(curl -fsSL https://andy.one/dotfiles/install.sh)
```

### Extra commands

| Name | Description |
|------|-------------|
| `tx` | Start or attach to TMUX session |
| `txn` | Rename current pane |
| `sshk` | `ssh` command without checking and saving host key |
| `ssht` | `sshk` to many hosts at once (_requires TMUX session_) |
| `scpk` | `scp` command without checking and saving host key |
| `g` | `grep` shortcut |
| `e` | Editor shortcut |
| `d` | Docker shortcut |
| `dr` | Docker `run` shortcut |
| `de` | Docker `exec` shortcut |
| `hf` | `grep` over zsh history |
| `txc` | Rename current TMUX window to short path to current directory |
| `goc` | Create HTML coverage report for Go sources |
| `gcl` | Clone repository with Go sources |
| `bkp` | Create backup for file or directory |
| `flat` | Print flatten list of records |
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

### Tmux cheatsheet

| Shortcut | Action |
|----------|--------|
| <kbd>CTRL+B</kbd> | Prefix key |
| <kbd>CTRL+T</kbd> | Toggle panes names |
| <kbd>CTRL+B</kbd> → <kbd>T</kbd> | Show current time |
| <kbd>CTRL+B</kbd> → <kbd>С</kbd> | Create new window |
| <kbd>CTRL+B</kbd> → <kbd>R</kbd> | Rearrage windows |
| <kbd>CTRL+B</kbd> → <kbd>W</kbd> | List windows |
| <kbd>CTRL+B</kbd> → <kbd>S</kbd> | Show current tmux sessions |
| <kbd>CTRL+B</kbd> → <kbd>\|</kbd> | Split window vertically |
| <kbd>CTRL+B</kbd> → <kbd>-</kbd> | Split window horizontaly |
| <kbd>CTRL+B</kbd> → <kbd>,</kbd> | Set window name |
| <kbd>CTRL+B</kbd> → <kbd>N</kbd> | Next window |
| <kbd>CTRL+B</kbd> → <kbd>P</kbd> | Previous window |
| <kbd>CTRL+B</kbd> → <kbd>A</kbd> | Toggle panes syncing |
| <kbd>CTRL</kbd>+<kbd>←</kbd> | Move current window to the left (_reorder windows_) |
| <kbd>CTRL</kbd>+<kbd>→</kbd> | Move current window to the right (_reorder windows_) |
| <kbd>CTRL+B</kbd> → <kbd>Q</kbd> | Show pane numbers |
| <kbd>CTRL+B</kbd> → <kbd>X</kbd> | Kill pane |
| <kbd>ALT</kbd>+<kbd>←</kbd> | Select pane on the left |
| <kbd>ALT</kbd>+<kbd>→</kbd> | Select pane on the right |
| <kbd>ALT</kbd>+<kbd>↑</kbd> | Select upper pane |
| <kbd>ALT</kbd>+<kbd>↓</kbd> | Select bottom pane |
| <kbd>CTRL+B</kbd> → <kbd>Space</kbd> | Set panes layout |
| <kbd>CTRL+B</kbd> → <kbd>PgUp</kbd> | Scroll up |
| <kbd>CTRL+B</kbd> → <kbd>PgDn</kbd> | Scroll down |
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

_For function keys support in XShell 5+ you should use custom [mappings file](xshell.tkm)._
