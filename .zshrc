COLORTERM=truecolor

# --------------------------------------------------
# Powerlevel10k
# --------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -r "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
alias ls='eza --classify=always --follow-symlinks --icons=always --group-directories-first'
alias la='ls -a'
alias ll='ls -l'
alias gl='git log'
alias ga='git add'
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

# ==============================
# Git Worktree Management
# ==============================
function gw () {
  local cmd="$1"
  if [ $# -gt 0 ]; then
    shift
  fi
  case "$cmd" in
    ls) gw-ls "$@" ;;
    add) gw-add "$@" ;;
    rm) gw-rm "$@" ;;
    cd) gw-cd "$@" ;;
    *)
      echo "Usage:"
      echo "  gw ls                → List git worktrees"
      echo "  gw add <branch-name> → Add git worktree and branch"
      echo "  gw rm                → Remove git worktree and branch"
      echo "  gw cd                → Change directory to selected git worktree"
      return 1
      ;;
  esac
}

# List git worktrees
gw-ls () {
  git worktree list
}

# Add git worktree and branch
# Usage: gw add <branch-name>
function gw-add () {
  local project_dir=$(git worktree list | head -n 1 | awk '{print $1}' | xargs dirname)
  local dir_name=${1//\//-}
  echo "Adding worktree: ${project_dir}/${dir_name} for branch: $1"
  git worktree add -b "$1" "${project_dir}/${dir_name}"
}

# Remove git worktree and branch
function gw-rm () {
  local selected_line=$(git worktree list | peco)
  [ -z "$selected_line" ] && return

  local target_dir hash target_branch
  echo $selected_line | read target_dir hash target_branch

  target_branch=${target_branch//[\[\]]/}
  echo "Removing worktree: ${target_dir}"
  echo "Removing branch: ${target_branch}"

  git worktree remove "${target_dir}"
  git branch -D "${target_branch}"
}

# Change directory to selected git worktree
function gw-cd () {
  local selected_line=$(git worktree list | peco)
  [ -z "$selected_line" ] && return

  local target_dir hash target_branch
  echo $selected_line | read target_dir hash target_branch

  echo "Changing directory to worktree: ${target_dir}"
  cd $target_dir

  mksymlink
}

# Make symbolic link
function mksymlink () {
  local main_branch_dir=$(git worktree list | head -n 1 | awk '{print $1}')
  local ssl_source="${main_branch_dir}/ssl"

  for src_file in "${ssl_source}"/*(DN); do
    local filename=$(basename "$src_file")
    local target_path="./ssl/$filename"

    if [[ -e "$target_path" || -L "$target_path" ]]; then
      continue
    else
      echo "🔗 Linking: $target_path"
      ln -s "$src_file" "$target_path"
    fi
  done
}
