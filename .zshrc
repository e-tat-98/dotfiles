# --------------------------------------------------
# Completion system
# --------------------------------------------------

# brew completion
if type brew &> /dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

# npm completion
if type npm &> /dev/null; then
  source <(npm completion)
fi

autoload -Uz compinit
compinit

# --------------------------------------------------
# History substring search
# --------------------------------------------------

if type brew &> /dev/null; then
  source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# --------------------------------------------------
# Aliases
# --------------------------------------------------
alias la='ls -a'
alias ll='ls -l'
alias gl='git log'
alias gc='git checkout'
alias gcp='git checkout $(git branch | peco)'
alias gb='git branch'
alias gbd='git branch -D $(git branch | peco)'
alias gs='git stash -u'
alias gss='git stash save'
alias gsl='git stash list'
alias gsc='git stash clear'
alias gsap='git stash apply $(echo $(git stash list | peco) | grep -o "^stash@{\d*}")'
alias mkfile='f() { mkdir -p "$(dirname "$1")" && touch "$1"; }; f' # ファイルを作成する

# --------------------------------------------------
# Functions
# --------------------------------------------------
function key () {
  echo 'Ctrl + q      → 現在の入力を破棄'
  echo 'Ctrl + e      → 行末へ移動'
  echo 'Ctrl + a      → 行頭に移動'
  echo 'Ctrl + k      → カーソルから行末までの文字を切り取り'
  echo 'Ctrl + w      → 左の単語を切り取り'
  echo 'Esc -> d      → 右の単語を切り取り'
  echo 'Ctrl + u      → その行全部切り取り'
  echo 'Ctrl + y      → ペースト'
  echo 'Ctrl + -      → undo'
  echo 'Ctrl + l      → 今のコマンドラインをウィンドウの一番上に持ってくる'
  echo 'Cmd + k       → Clear CLI'
}
