## Logins

alias root='su -l'

## Status & Infos

alias whatsup='service --status-all'

alias ports='nmap localhost'
alias dns="sudo systemd-resolve --status | grep 'DNS Servers'"

## Usual Instructions

alias please='sudo $(fc -ln -1)'
alias ims='sudo $(fc -ln -1)'

alias c='clear'
alias h='history'
alias hg='history | grep $1'                                                                                                    #**Search using>

alias wg='wget -c '
alias al="echo ------------Your curent aliases are:------------¡';alias"

alias sup="sudo apt update && sudo apt upgrade -y"
alias up='apt update && apt upgrade -y'

## List

alias ll='ls -la'
alias lf='ls -alF'
alias la='ls -A'
alias ls='ls -CF'
alias lt='ls --human-readable --size -1 -S --classify'
alias lh='ls -ahlt'
alias lu='du -sh * | sort -h'
alias lt='ls -t -1 -long'
alias lc='find . -type f | wc -l'
alias ld='ls -d */'
alias list='ls -lah'

## Files, folders and resources

alias fh='find . -name '
alias ..='cd ..'
alias ....='cd ../..'

## More Jump down

alias 1d="cd .."
alias 2d="cd ..;cd .."
alias 3d="cd ..;cd ..;cd .."
alias 4d="cd ..;cd ..;cd ..;cd .."
alias 5d="cd ..;cd ..;cd ..;cd ..;cd .."

## Zip & Tar

alias untar='tar -zxvf $1'
alias tar='tar -czvf $1'

## Others

alias df="df -Tha --total"
