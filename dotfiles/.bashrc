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
