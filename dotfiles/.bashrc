# .bashrc - Custom user shell settings

# Enable colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Custom aliases
alias ll='ls -alF'
alias gs='git status'
alias k='kubectl'
alias d='dotnet'

# Add dotnet to PATH
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

#add Go to PATH
export PATH="$(go env GOPATH)/bin:${PATH}"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Custom prompt with git and kubernetes info
function git_prompt_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local branch=$(git branch --show-current 2>/dev/null)
    local unstaged=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $unstaged -gt 0 ]]; then
      echo " (${branch} +${unstaged})"
    else
      echo " (${branch})"
    fi
  fi
}

function k8s_prompt_info() {
  if command -v kubectl > /dev/null 2>&1; then
    local context=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$context" ]]; then
      echo " [k8s:${context}]"
    fi
  fi
}

# Set the prompt
PS1='\[\033[01;32m\]\w\[\033[01;33m\]$(git_prompt_info)\[\033[01;34m\]$(k8s_prompt_info)\[\033[00m\]\n$ '
