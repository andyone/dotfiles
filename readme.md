## .dotfiles

A set of zsh, git, and tmux configuration files.

### Installation

```
bash <(curl -fsSL https://raw.githubusercontent.com/andyone/dotfiles/master/install.sh)
```

### Aliases

| Alias | Description |
|--------------------|-------------------------------|
| `sshk` | `ssh` command without checking and saving host key |
| `scpk` | `scp` command without checking and saving host key |
| `g` | `grep` |
| `hf` | `grep` over shell history |
| `tx` | Start or attach to tmux session |
| `txc` | Rename current tmux window to short path to current directory |
| `goc` | Create HTML coverage report for Go sources |

### Tmux cheatsheet

| Shortcut | Action |
|----------------------------------------|-------------------------------------------|
| <kbd>CTRL</kbd>+<kbd>B</kbd> | Prefix key |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>С</kbd> | Create new window |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>R</kbd> | Rearrage windows |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>\|</kbd> | Split window vertically |
| <kbd>CTRL</kbd>+<kbd>B</kbd> → <kbd>-</kbd> | Split window horizontaly |
| <kbd>ALT</kbd>+<kbd>←</kbd> | Select pane on the left |
| <kbd>ALT</kbd>+<kbd>→</kbd> | Select pane on the right |
| <kbd>ALT</kbd>+<kbd>↑</kbd> | Select upper pane |
| <kbd>ALT</kbd>+<kbd>↓</kbd> | Select bottom pane |
| <kbd>CTRL</kbd>+<kbd>SHIFT</kbd>+<kbd>←</kbd> | Move current window to the left (_reorder windows_) |
| <kbd>CTRL</kbd>+<kbd>SHIFT</kbd>+<kbd>→</kbd> | Move current window to the right (_reorder windows_) |
| <kbd>F1</kbd> | Select window #1 |
| <kbd>F2</kbd> | Select window #2 |
| <kbd>F3</kbd> | Select window #3 |
| <kbd>F4</kbd> | Select window #4 |
| <kbd>F5</kbd> | Select window #5 |
| <kbd>F6</kbd> | Select window #6 |
| <kbd>F7</kbd> | Select window #7 |
| <kbd>F8</kbd> | Select window #8 |
| <kbd>F9</kbd> | Select window #9 |
| <kbd>F12</kbd> | Kill current window |

_For function keys support in XShell 5 you should use custom [mappings file](xshell.tkm)._
