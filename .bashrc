# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Provide a warning/confirmation before deleting, copying, and moving files and directories
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source <(keychain --eval --timeout $((24 * 60))) # This requires SSH password to be entered once a day

# Add tab completion for aws commands
complete -C '/usr/local/bin/aws_completer' aws

cdnvm() {
    command cd "$@" || return $?
    nvm_path="$(nvm_find_up .nvmrc | command tr -d '\n')"

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version
        default_version="$(nvm version default)"

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [ $default_version = 'N/A' ]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [ "$(nvm current)" != "${default_version}" ]; then
            nvm use default
        fi
    elif [[ -s "${nvm_path}/.nvmrc" && -r "${nvm_path}/.nvmrc" ]]; then
        declare nvm_version
        nvm_version=$(<"${nvm_path}"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "${nvm_version}" | command tail -1 | command tr -d '\->*' | command tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [ "${locally_resolved_nvm_version}" = 'N/A' ]; then
            nvm install "${nvm_version}";
        elif [ "$(nvm current)" != "${locally_resolved_nvm_version}" ]; then
            nvm use "${nvm_version}";
        fi
    fi
}

alias cd='cdnvm'
cdnvm "$PWD" || exit

# Set up some useful colours
        RED="\[\033[31m\]"
      GREEN="\[\033[0;32m\]"
LIGHT_GREEN="\[\033[1;32m\]"
       GRAY="\[\033[1;30m\]"
 LIGHT_BLUE="\[\033[1;34m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
  COLOR_OFF="\[\e[0m\]"

function prompt_func() {
  PS1="${LIGHT_BLUE}\W${COLOR_OFF}" # basename of current working directoory

  PS1+="${GREEN}"
  PS1+='$(__git_ps1 " [%s]")' # current git branch checked out

  if [[ $VIRTUAL_ENV != "" ]]; then
      PS1+="${RED}(${VIRTUAL_ENV##*/})" # current venv/pipenv
  fi

  if [[ $PS_ENV != "" ]]; then
      PS1+="${LIGHT_BLUE}(${PS_ENV})" # extra that can be set by bin/activate e.g current active environment
  fi

  PS1+="${COLOR_OFF}$ "

  BASE=`basename $PWD`
  echo -ne "\033]0;${BASE}\007" # set title of terminal

  history -a # immediately add commands to your history
}
PROMPT_COMMAND=prompt_func

# Turn off sound for tab completion
bind 'set bell-style none'

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Set global default editor to vim
export VISUAL=vim
export EDITOR="$VISUAL"

# Created by `pipx` on 2025-06-15 11:44:21
export PATH="$PATH:/home/sam/.local/bin"

# Add tab completion for pipx
eval "$(register-python-argcomplete3 pipx)"

# Add tab completion for poetry
_poetry_51f1a9952a75656a_complete()
{
    local cur script coms opts com
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur words

    # for an alias, get the real script behind it
    if [[ $(type -t ${words[0]}) == "alias" ]]; then
        script=$(alias ${words[0]} | sed -E "s/alias ${words[0]}='(.*)'/\1/")
    else
        script=${words[0]}
    fi

    # lookup for command
    for word in ${words[@]:1}; do
        if [[ $word != -* ]]; then
            com=$word
            break
        fi
    done

    # completing for an option
    if [[ ${cur} == --* ]] ; then
        opts="--ansi --directory --help --no-ansi --no-cache --no-interaction --no-plugins --project --quiet --verbose --version"

        case "$com" in

            (about)
            opts="${opts} "
            ;;

            (add)
            opts="${opts} --allow-prereleases --dev --dry-run --editable --extras --group --lock --markers --optional --platform --python --source"
            ;;

            (build)
            opts="${opts} --clean --config-settings --format --local-version --output"
            ;;

            ('cache clear')
            opts="${opts} --all"
            ;;

            ('cache list')
            opts="${opts} "
            ;;

            (check)
            opts="${opts} --lock --strict"
            ;;

            (config)
            opts="${opts} --list --local --migrate --unset"
            ;;

            ('debug info')
            opts="${opts} "
            ;;

            ('debug resolve')
            opts="${opts} --extras --install --python --tree"
            ;;

            ('debug tags')
            opts="${opts} "
            ;;

            ('env activate')
            opts="${opts} "
            ;;

            ('env info')
            opts="${opts} --executable --path"
            ;;

            ('env list')
            opts="${opts} --full-path"
            ;;

            ('env remove')
            opts="${opts} --all"
            ;;

            ('env use')
            opts="${opts} "
            ;;

            (help)
            opts="${opts} "
            ;;

            (init)
            opts="${opts} --author --dependency --description --dev-dependency --license --name --python"
            ;;

            (install)
            opts="${opts} --all-extras --all-groups --compile --dry-run --extras --no-directory --no-root --only --only-root --sync --with --without"
            ;;

            (list)
            opts="${opts} "
            ;;

            (lock)
            opts="${opts} --regenerate"
            ;;

            (new)
            opts="${opts} --author --dependency --description --dev-dependency --flat --interactive --license --name --python --readme --src"
            ;;

            (publish)
            opts="${opts} --build --cert --client-cert --dist-dir --dry-run --password --repository --skip-existing --username"
            ;;

            ('python install')
            opts="${opts} --clean --free-threaded --implementation --reinstall"
            ;;

            ('python list')
            opts="${opts} --all --implementation --managed"
            ;;

            ('python remove')
            opts="${opts} --implementation"
            ;;

            (remove)
            opts="${opts} --dev --dry-run --group --lock"
            ;;

            (run)
            opts="${opts} "
            ;;

            (search)
            opts="${opts} "
            ;;

            ('self add')
            opts="${opts} --allow-prereleases --dry-run --editable --extras --source"
            ;;

            ('self install')
            opts="${opts} --dry-run --sync"
            ;;

            ('self lock')
            opts="${opts} --regenerate"
            ;;

            ('self remove')
            opts="${opts} --dry-run"
            ;;

            ('self show')
            opts="${opts} --addons --latest --outdated --tree"
            ;;

            ('self show plugins')
            opts="${opts} "
            ;;

            ('self sync')
            opts="${opts} --dry-run"
            ;;

            ('self update')
            opts="${opts} --dry-run --preview"
            ;;

            (show)
            opts="${opts} --all --latest --no-truncate --only --outdated --top-level --tree --why --with --without"
            ;;

            ('source add')
            opts="${opts} --priority"
            ;;

            ('source remove')
            opts="${opts} "
            ;;

            ('source show')
            opts="${opts} "
            ;;

            (sync)
            opts="${opts} --all-extras --all-groups --compile --dry-run --extras --no-directory --no-root --only --only-root --with --without"
            ;;

            (update)
            opts="${opts} --dry-run --lock --only --sync --with --without"
            ;;

            (version)
            opts="${opts} --dry-run --next-phase --short"
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0;
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms="about add build 'cache clear' 'cache list' check config 'debug info' 'debug resolve' 'debug tags' 'env activate' 'env info' 'env list' 'env remove' 'env use' help init install list lock new publish 'python install' 'python list' 'python remove' remove run search 'self add' 'self install' 'self lock' 'self remove' 'self show' 'self show plugins' 'self sync' 'self update' show 'source add' 'source remove' 'source show' sync update version"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _poetry_51f1a9952a75656a_complete poetry
complete -o default -F _poetry_51f1a9952a75656a_complete /home/sam/poetry

export GPG_TTY=$(tty)

source <(kubectl completion bash)

