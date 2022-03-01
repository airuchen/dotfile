if [ -f ~/.bashrc -a -r ~/.bashrc ] ; then
    source ~/.bashrc
fi

if [ -f ~/.bash_profile.local -a -r ~/.bash_profile.local ] ; then
    source ~/.bash_profile.local
fi
