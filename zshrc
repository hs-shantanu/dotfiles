# -*- mode: sh -*-
# Time-stamp: <2023-11-11 14:28:07 shantanu>
#            _
#           | |
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

################################################################################
# Include /etc/profile
source /etc/profile
[ -f $HOME/.profile ] && source $HOME/.profile

################################################################################
# Options

# General Options
setopt ALLEXPORT        # all parameters below this point are automatically exported
setopt NO_BEEP          # disable beep on error
setopt MULTIOS          # redirect streams to multiple locations
setopt CORRECT          # try to correct mistakes in commands
setopt NO_FLOWCONTROL   # disable flow control characters
setopt PRINT_EXIT_VALUE # print return value of commands which return non-zero


# Expansion and Globbing
setopt NO_NOMATCH        # when a glob pattern fails, pass it to program as it is
setopt EXTENDED_GLOB     # Treat ‘#’, ‘~’ and ‘^’ as glob patterns
setopt NUMERIC_GLOB_SORT # sort files with numbers using numeric sort
setopt CASE_GLOB         # case sensitive expansion and globbing

# Directories
setopt AUTO_CD            # change to directory without needing to type cd
setopt CDABLE_VARS        # if path component is missing but matching variable is defined, use it instead
setopt AUTO_PUSHD         # cd automatically calls pushd
setopt PUSHD_IGNORE_DUPS  # don't add duplicate directories to dirstack
setopt PUSHD_SILENT       # don't print dirstack after pushd/popd
setopt PUSHD_TO_HOME      # blank pushd -> pushd $HOME
DIRSTACKSIZE=5            # store at most five directories in dirstack

# Job Control
setopt AUTO_CONTINUE   # disown automatically sends SIGCONT to processes
setopt CHECK_JOBS      # check for background jobs before exiting
setopt LONG_LIST_JOBS  # list jobs in log format
setopt NOTIFY          # when a background job completes, print notification immediately
setopt NOHUP           # don't send SIGHUP to running processes when shell exits

# History
HISTFILE=~/.zhistory
HISTSIZE=655360
SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY    # Save timestamp of command and duration
setopt HIST_IGNORE_DUPS    # Don't write duplicates to command history
setopt HIST_REDUCE_BLANKS  # Remove extra blanks from commands in history
setopt HIST_IGNORE_SPACE   # Don't save to history if command starts with a space

# Ensure PATH always contains unique entries
typeset -U path PATH

# Default editor and pager
PAGER='less'
EDITOR='vi'

PATH="$HOME/bin":/opt/homebrew/bin:$PATH
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin":$PATH

################################################################################
# Completion
fpath+=~/.zfunc
autoload -U compinit
compinit
unsetopt MENU_COMPLETE   # do not autoselect the first completion entry
setopt AUTO_LIST         # automatically list entries
setopt COMPLETE_IN_WORD  # completion happens from both ends
setopt ALWAYS_TO_END     # if completion results in single result, cursor is placed at end of the word

WORDCHARS='*?_-.[]~\!#$%^(){}<>|`@#$%^*()+:'

zmodload -i zsh/complist

zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''

bindkey -M menuselect '^o' accept-and-infer-next-history

zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*:*:*:*:*' menu select _complete _ignored _approximate
zstyle ':completion:*:*:*:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps f -u $USER"
zstyle ':completion:*:processes-names' command 'ps axho command'
# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
cdpath=(.)

# use /etc/hosts and known_hosts for hostname completion
[ -r ~/.ssh/known_hosts ] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r /etc/hosts ] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  "$_ssh_hosts[@]"
  "$_etc_hosts[@]"
  "$HOST"
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order files all-files users hosts-host
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order hosts-host users

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs

expand-or-complete-with-dots() {
    echo -n "\e[31m......\e[0m"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

################################################################################
# Aliases and Command Functions
alias sudo='sudo '
alias man='LC_ALL=C LANG=C man'
alias ls='LC_COLLATE=C ls --color=auto'
alias ll='ls -l'
alias la='ll -a'
alias vi=vim
alias psf='ps f -U $USER'
alias sl=ls
alias dirs='dirs -v'

# cd to a directory and then do an ls
# unless there are lots of files in the directory
function lcd() {
    builtin cd "${@}"
    if [ "$( ls | wc -l )" -gt 30 ] ; then
        ls -lh --color=always | awk 'NR < 16 { print }; NR == 16 { print " (... snip ...)" }; { buffer[NR % 14] = $0 } END { for( i = NR + 1; i <= NR+14; i++ ) print buffer[i % 14] }'
    else
        ls -lh
    fi
}

# mkdir, move a file to it
function mvcd() {
    mkdir -p "$2" && mv "$1" "$2" && cd "$2";
}

# mkdir & cd to it
function mcd() {
  mkdir -p "$1" && cd "$1";
}

function zsh_stats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function pvm() {
    eval last=\$$#
    [[ ! -d "$last" ]] && mkdir -p $last
    for arg in ${@[1,-2]}
    do
        pv "$arg" > "$last"/"$arg"
        rm "$arg"
    done
}

function pvc() {
    eval last=\$$#
    [[ ! -d "$last" ]] && mkdir -p $last
    for arg in ${@[1,-2]}
    do
        pv "$arg" > "$last"/"$arg"
    done
}

# Git aliases
alias g='git'
compdef g=git
alias gst='git status'
compdef _git gst=git-status
alias gl='git pull'
compdef _git gl=git-pull
alias gp='git push'
compdef _git gp=git-push
gdv() { git diff -w "$@" | vim - }
compdef _git gdv=git-diff
alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gb='git branch'
compdef _git gb=git-branch
alias ga='git add'
compdef _git ga=git-add

################################################################################
# Key Bindings
bindkey "^?" backward-delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^W' backward-delete-word
bindkey "^r" history-incremental-search-backward
bindkey ' ' magic-space    # also do history expansion on space
bindkey '^I' complete-word # complete on tab, leave expansion to _expand
bindkey '\M.' insert-last-word

################################################################################
# Prompt
autoload colors zsh/terminfo
colors
unsetopt ALLEXPORT
for color in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval PR_$color='%{$fg[${(L)color}]%}'
    eval PR_BOLD_$color='%{$fg_bold[${(L)color}]%}'
done
eval RESET='%{$reset_color%}'

# Starship prompt
eval "$(starship init zsh)"

################################################################################
# Specific aliases and Command Functions
setopt ALLEXPORT
CLICOLOR=true
alias ll='ls -Fl'

alias cleanrepl='lein -U do clean, deps, compile, trampoline repl :headless'
alias repl='lein trampoline repl :headless'
alias testrepl='lein with-profile dev,test,cljtools trampoline repl :headless'

alias awsjump='ssh jump-nv2.p.helpshift.com'

function rfcc() {
    $HOME/bin/rfc "$(git symbolic-ref --short HEAD)"
}
function rfcd() {
    RFC_DRAFT_FIRST=1 $HOME/bin/rfc "$(git symbolic-ref --short HEAD)"
}

function gerrit_create_branch() {

    if [ -z "$1" ]; then
        echo "Need name of branch, exiting.";
        return;
    fi

    # Go to top-level in the working directory
    cd $(git rev-parse --show-toplevel);

    git branch -l | grep -q $1
    if [ $? -eq 0 ]; then
        echo "Branch $1 exists, use a different name."
        return;
    fi

    # Create the branch on gerrit
    CWD=$(pwd)
    ssh gerrit gerrit create-branch $(basename "$CWD") $1 master

    if [ $? -ne 0 ]; then
        echo "Failed to create branch on Gerrit!"
        return
    fi

    # Checkout the branch now
    git checkout -b $1

    # Point the local branch to the remote origin
    gsed -i.bak "\|$1|,+3d" .git/config
    cat <<EOF >> .git/config
[branch "$1"]
	remote = origin
	merge = refs/heads/$1
	rebase = true
EOF
    mkdir -p $(dirname .git/refs/remotes/origin/$1)
    echo $(git rev-parse HEAD) > .git/refs/remotes/origin/$1

}

################################################################################
# Work related definitions and aliases

MOBY_ENV=localhost
TEST_LOGS=true
LEIN_JVM_OPTS=-Dhttps.protocols=TLSv1.2
[ -f ~/.credentials ] && source ~/.credentials

alias activate2='source $HOME/src/python/venv-2.7/bin/activate'
alias activate3='source $HOME/src/python/venv3/bin/activate'
function activate { echo "Choose either Python 2.7 (activate2) or Python 3 (activate3)" }

LC_ALL=en_US.UTF-8
TERM=xterm-256color

[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Node and NPM
export NVM_DIR="/opt/nvm"
function nvm_setup {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

## emacsclient
EMACSCLIENT="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
alias ecn='$EMACSCLIENT -n -s $HOME/.emacs.d/server -a /usr/bin/vim'

## AWS ECR container
export AWS_ACCOUNT=664404405793
export AWS_REGION=us-east-1
alias aws-ecr-login="aws --profile hsft ecr get-login-password --region $AWS_REGION | podman login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com"

## Bring moby up or down
alias podman-compose='/Users/shantanu/Library/Python/3.9/bin/podman-compose'
alias moby-up="podman-compose -f ~/src/helpshift/moby/container/moby_arm64.yml up -d"
alias moby-down="podman-compose -f ~/src/helpshift/moby/container/moby_arm64.yml down"
alias moby-status="podman ps -a --format 'table {{.ID}} {{.Names}} {{.Status}}'"

export GPG_TTY=\$(tty)
