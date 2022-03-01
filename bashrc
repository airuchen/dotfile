# bi0's .bash_profile
# based on dmnc's

export BLOCKSIZE=1M # use megabytes wherever $BLOCKSIZE is respected

export HISTCONTROL=ignoredups # don't save duplicate lines in the history
export HISTCONTROL=$HISTCONTROL:erasedups # remove duplicate lines when writing
export HISTCONTROL=$HISTCONTROL:ignorespace # don't save lines prefixed with ' '

# no history for searches in less
export LESSHISTSIZE=0 # in case a file already exists
export LESSHISTFILE=/dev/null

# currently only used for man
export HIGHLIGHT_COLOR="0;33";

if [ -z $LANG ]; then
	export LANG="en_GB.UTF-8"
fi

# make sure the default umask is 0022 (prevent write for group/world)
UMASK=$(umask)
if [ "$UMASK" != "0022" ]; then
    _INTERNAL_UMASK_ERROR="umask received from system was $UMASK - setting 0022"
    umask 0022
fi
unset UMASK

# set vi mode for the bash command line editor
set -o vi
if [ ! -e "$HOME/.inputrc" ]; then
    _INTERNAL_READLINE_ERROR="readline uses vi mode but there is no .inputrc"
elif [ ! -r "$HOME/.inputrc" ]; then
    _INTERNAL_READLINE_ERROR="readline uses vi mode but .inputrc cannot be read"
fi

# internal variables
OS=`uname` # to avoid spawning multiple uname processes

# prompt
if [ $USER = "root" ] ; then
    PS1="\[\e[0;31m\][\[\e[1;37m\]\u\[\e[0;31m\]@\[\e[m\]\h\[\e[0;31m\]:\[\e[1;31m\]\w\[\e[0;31m\]]\[\e[0m\] "
    PS2="\[\e[0;31m\]]\[\e[0m\] "
else
    PS1="\[\e[0;32m\][\[\e[1;37m\]\u\[\e[0;32m\]@\[\e[m\]\h\[\e[0;32m\]:\[\e[1;32m\]\w\[\e[0;32m\]]\[\e[0m\] "
    PS2="\[\e[0;32m\]]\[\e[0m\] "
    #[user@host:working/dir]
    #PS1="\[\e[0;32m\][\[\e[1;37m\]\u\[\e[0;32m\]@\[\e[m\]\h\[\e[0;32m\]:\[\e[1;32m\]\w\[\e[0;32m\]]\[\e[0m\] "
    #PS2="\[\e[0;32m\]]\[\e[0m\] "
fi

# make less the preferred pager if available
unalias less 2> /dev/null # some which implementations return aliases otherwise
LESS_PATH=$(which less)
if [ "$LESS_PATH" -a -x "$LESS_PATH" ]; then
    export LESS="-R" # make sure ANSI color codes come through correctly
    export LESS="$LESS -F" # quit automatically after printing short files
    export LESS="$LESS -X" # don't clear the screen when starting less

    export PAGER='less'


	if [ "$OS" = "OpenBSD" -a $(uname -r) = "5.7" ]; then
		MAN_HIGHLIGHT_COLOUR='0;33'
		export MANPAGER="env LESS_TERMCAP_mb=[1;31m LESS_TERMCAP_md=[${MAN_HIGHLIGHT_COLOUR}m LESS_TERMCAP_me=[0m LESS_TERMCAP_se=[0m LESS_TERMCAP_so=[${MAN_HIGHLIGHT_COLOUR};7m LESS_TERMCAP_ue=[0m LESS_TERMCAP_us=[1m less"
	else
		MAN_HIGHLIGHT_COLOUR='0\;33'
		export MANPAGER="env LESS_TERMCAP_mb=[1\;31m LESS_TERMCAP_md=[${MAN_HIGHLIGHT_COLOUR}m LESS_TERMCAP_me=[0m LESS_TERMCAP_se=[0m LESS_TERMCAP_so=[${MAN_HIGHLIGHT_COLOUR}\;7m LESS_TERMCAP_ue=[0m LESS_TERMCAP_us=[1m less"
	fi
	unset MAN_HIGHLIGHT_COLOUR
else
    _INTERNAL_LESS_ERROR="less could not be found on this system"
fi
unset LESS_PATH

# make vim the preferred editor if available
unalias vim 2> /dev/null
VIM_PATH=$(which vim)
if [ "$VIM_PATH" -a -x "$VIM_PATH" ]; then
    export VISUAL=vim
    export EDITOR=vim
    alias vi='vim'
else
    _INTERNAL_VIM_ERROR="vim could not be found on this system"
fi
unset VIM_PATH


# other aliases
alias su='su -'
alias clear='history -c; cat /dev/null > ~/.bash_history; clear; echo "cl34r3d"'
alias less='less -R' # make sure ANSI color codes come through correctly
alias screen='screen -U' # enforce UTF-8 mode for screen
alias tmux='tmux -u -2' # enforce UTF-8 mode and 256 colours for tmux
alias ll='ls -lh'
alias la='ls -A'
alias multidl='curl -L -A "Mozilla/4.0" --remote-name-all'

# appends a directory to the $PATH if it exists and we have +x on it
# TODO make this accept a colon-separated list of paths as an argument too
append_path() {
    if [ -d "$1" -a -x "$1" ] ; then # make sure it's a directory with +x
        IFS=":"
        for DIRECTORY in $PATH; do # first make sure it's not in $PATH already
            if [ "$DIRECTORY" = "$1" ]; then
				unset IFS
                return 0
            fi
        done

        if [ "$PATH" = "" ] ; then
            PATH="$1" # just set it for the first directory
        else
            PATH="$PATH:$1" # append with a : for all others
        fi
    fi
	unset IFS
}

# set up $PATH to include a collection of common directories
INITIAL_PATH="$PATH"
unset PATH
# append directories from the initial $PATH received by the system
IFS=":"
for DIRECTORY in $INITIAL_PATH; do
    append_path "$DIRECTORY"
done
unset INITIAL_PATH
# append directories from getconf PATH
for DIRECTORY in $(getconf PATH); do
    append_path "$DIRECTORY"
done
unset IFS
# lastly append a manually compiled list of directories
append_path "/bin"
append_path "/sbin"
append_path "/usr/bin"
append_path "/usr/sbin"
append_path "/usr/local/bin"
append_path "/usr/local/sbin"
append_path "/usr/games"
append_path "/usr/X11R6/bin"
append_path "/opt/local/bin"
append_path "/opt/local/sbin"
append_path "$HOME/bin"
append_path "/usr/local/bin"
export PATH

# gnuls colours
export LS_COLORS="fi=00:di=36:ln=35:ex=32:or=05;37;41:mi=05;37;41"
if [ -x /usr/local/bin/gls ] ; then
	if [ $USER = "root" ] ; then
		alias ls='gls -F -A --color=auto'
	else
		alias ls='gls -F --color=auto'
	fi
elif [ -x /usr/local/bin/gnuls ] ; then
	if [ $USER = "root" ] ; then
		alias ls='gnuls -F -A --color=auto'
	else
		alias ls='gnuls -F --color=auto'
	fi
elif [ "$OS" = "Linux" ] ; then # linux, assume it's GNU ls
	if [ $USER = "root" ] ; then
		alias ls='ls -F -A --color=auto'
	else
		alias ls='ls -F --color=auto'
	fi
elif [ "$OS" = "Darwin" ] ; then # os x, make its ls behave like gnuls
    export LSCOLORS="GxHxxxxxCxxxxxxxxxxxxx"
    alias ls='ls -FG'
fi

# other os dependant stuff
case "$OS" in
'Darwin')
    bind "set completion-ignore-case on"
;;
esac

# prints notifications above the prompt if needed/applicable
print_prompt_notifications() {
    # if a process exits with an error exit status, display it above the prompt
    if [ $1 -gt 256 ]; then # these codes will not be returned on bash >= 4
        echo [31m[ [1mbash internal error [0m[31m: [0m$1 [31m][0m
    elif [ ! $1 = 0 ]; then
        local SIGNAL_NAME=$(kill -l $1 2> /dev/null)
        if [ ! -z "$SIGNAL_NAME" -a $1 -gt 128 ]; then
            local SIGNAL_STRING="[31m([0m$SIGNAL_NAME[31m) [0m"
        else
            local SIGNAL_STRING=""
        fi
        echo [31m[ [1mexit status [0m[31m: [0m$1 $SIGNAL_STRING[31m][0m
    fi

    # show a notification if there are any background jobs, running or stopped
    local JOBS=$(printf "%d" $(jobs -p | wc -l))
    if [ "$JOBS" -gt 0 ]; then
        local STOPPED=$(printf "%d" $(jobs -ps | wc -l))
        if [ "$STOPPED" -eq "$JOBS" ]; then
            STOPPED="[0mstopped "
        elif [ "$STOPPED" -gt 0 ]; then
            STOPPED="[0;${COLOR}m([0m$STOPPED stopped[${COLOR}m) [0m"
        else
            STOPPED=""
        fi
        echo "[${COLOR}m[ [${HIGHLIGHT_COLOR}mjobs [0;${COLOR}m: [0m$JOBS $STOPPED[${COLOR}m][0m"
    fi
}
PROMPT_COMMAND="print_prompt_notifications \$?"

# set the window title to "$user@$host : $path" if the terminal can handle it
for TERMINAL in xterm xterm-color xterm-256color screen-256color; do
    if [ "$TERM" = "$TERMINAL" ]; then
	PROMPT_COMMAND+=';echo -ne "\033]0;${USER}@`hostname -s` : `dirs`\007"'
        break # no need to test for the rest
    fi
done

if [ "$TERM" = "xterm" ] ; then
    export TERM='xterm-256color'
fi

# prints a theme-colored message on the form "[$1] $2"
print_message() {
    # default to cyan if no color has been set
    if [ ! $BASH_THEME_COLOR ]; then
        export BASH_THEME_COLOR="0;36"
    fi
    if [ ! $HIGHLIGHT_COLOR ]; then
        export HIGHLIGHT_COLOR="1;36"
    fi

    echo "[${BASH_THEME_COLOR}m[[${HIGHLIGHT_COLOR}m$1[${BASH_THEME_COLOR}m] [0m$2"
}


# special stuff for interactive shells
case $- in
    *i*)
        shopt -s checkwinsize # update $COLUMNS and $LINES if they change
        # disable stop/start signals on ^S and ^Q
        stty -ixon
        # set default theme depending on root or user
    ;;
esac


if [ -f ~/.bashrc.local -a -r ~/.bashrc.local ] ; then
    source ~/.bashrc.local
fi

# TODO make a generic _ERROR variable and append stuff separated by some char
# display warnings if the shell is interactive
case $- in
    *i*)
        if [ ! -z "$_INTERNAL_READLINE_ERROR" ]; then
            print_message "!" "$_INTERNAL_READLINE_ERROR"
        fi
        if [ ! -z "$_INTERNAL_VIM_ERROR" ]; then
            print_message "!" "$_INTERNAL_VIM_ERROR"
        fi
        if [ ! -z "$_INTERNAL_LESS_ERROR" ]; then
            print_message "!" "$_INTERNAL_LESS_ERROR"
        fi
        if [ ! -z "$_INTERNAL_UMASK_ERROR" ]; then
            print_message "!" "$_INTERNAL_UMASK_ERROR"
        fi
        if [ -z "$TERM" -o "$TERM" = "dumb" ]; then
            print_message "!" "\$TERM missing or running inside a dumb terminal"
        fi
        if [ -z "$PATH" -o "$PATH" = "" ]; then
            print_message "!" "\$PATH is unset or empty"
        fi
        if [ -z "$MAIL" ]; then
            print_message "!" "\$MAIL is unset or empty"
        elif [ ! -r "$MAIL" ]; then
            print_message "!" "\$MAIL is set but unreadable"
        fi
    ;;
esac
# clear internal variables
unset _INTERNAL_VIM_ERROR
unset _INTERNAL_LESS_ERROR
unset _INTERNAL_READLINE_ERROR
unset OS

# if login shell, display stuff
# XXX if we're not in an interactive shell, the variables will not have been set
shopt -q login_shell
if [ $? = 0 ]; then # XXX should this comparison not be "-eq" instead?
    if [ ! -z "$SSH_CONNECTION" ]; then # if remote login, display connection
        echo $SSH_CONNECTION | awk '{printf "[%smconnected from: [0m%s[%sm:[0m%d[%sm\tto: [0m%s[%sm:[0m%d\n\n",
            ENVIRON["COLOR"], $1, ENVIRON["COLOR"], $2, ENVIRON["COLOR"], $3,
            ENVIRON["COLOR"], $4;}'
    fi
    echo -n "[${HIGHLIGHT_COLOR}m" && uptime # show uptime
    echo -n "[${COLOR}m" && w | tail -n +2 # -h skips headers on some systems
    echo "[0;0m"
fi
