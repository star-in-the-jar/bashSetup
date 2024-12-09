# git
alias glo="~/code/bashSetup/gitmoji-log.sh"
alias g.="git add ."
alias gll="git pull"
alias gsh="git push"
alias gch="git checkout"
alias gco="git commit"
alias gs="git status"
alias gb="git branch"
alias gr="git rebase"
alias grc="git rebase --continue"
alias gst="git stash"
alias gstp="git stash pop"
alias gsta="git stash apply"
alias gpu="git push --set-upstream origin"
alias gchd="git checkout develop"
alias gchb="git checkout -"
alias grd="git rebase develop"
alias gch-="git checkout -"
alias gconoe="git commit --amend --no-edit"
alias gchb='function _gchb(){ branch_name="feature/RPA-$1"; echo "checking out to $branch_name"; git checkout "$branch_name"; };_gchb'
alias get="git reset"
alias gst="git stash"
alias gop="git stash pop"
alias gap="git stash apply"
alias ge="git merge"
alias gcb='git_checkout_local_branch'
alias gbd="removing_local_branches_by_format"

# scripts
alias mvgo='function _mvgo() { mv "$1" "$2" && cd "$2"; unset -f _mvgo; }; _mvgo'
alias cpgo='function _cpgo() { cp "$1" "$2" && cd "$2"; unset -f _cpgo; }; _cpgo'
alias publish-sdk="bash $HOME/code/scripts/publish_rb-sdk.sh"

# aliases
alias ...="cd ../../"
alias ..="cd ../"
alias cur='cursor .'

# fixes
alias ghci='/c/Program\ Files\ \(x86\)/ghc-9.8.2-x86_64-unknown-mingw32/bin/ghci.exe'
alias cursor='function _cursor(){ $HOME/AppData/Local/Programs/cursor/Cursor.exe $1 &>/dev/null & disown; }; _cursor'
alias cbot="node $HOME/nvm/nodejs/bin/node_modules/@runbotics/cryptobotics/index.js"
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"

# default overvrites
function _rminfo() {
    if [[ "$1" == "-s" ]]; then
        shift
        rm -rf "$@"
        echo "File(s) permanently deleted."
    else
        trash "$@"
        echo "File(s) moved to the Trash."
    fi
}
alias rm='_rminfo'
alias grep='grep --color=auto'

# original commands
alias rmold='"C:\Program Files\Git\usr\bin\rm.exe"'

# nvm
alias node18="nvm link 18 && node -v"
alias node14="nvm link 14 && node -v"

# PS1
export PS1="\[$(tput sgr0)\]\[\033[38;5;13m\]\W\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;33m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;46m\]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"

# --- RUNBOTICS --- #

# rb cli enchanced
function r() {
    if [ -z "$1" ]; then
        cd $HOME/code/runbotics
    elif [ "$1" = "sch" ]; then
        echo Y | rb scheduler
    else
        echo Y | rb "$1"
    fi
}

# typeorm migrations
function mig:gen() {
    if [ -z "$1" ]
    then
        echo "You have to provide migration name, e.g. mig:gen myMigration"
        return 1
    fi

    cd "$HOME/code/runbotics/runbotics/runbotics-scheduler"
    rmold -rf dist/
    rushx build
    rushx typeorm migration:generate "src/migrations/$1"
    rmold -rf dist/
}

function mig:rev() {
    cd "$HOME/code/runbotics/runbotics/runbotics-scheduler"
    rmold -rf dist/
    rushx build
    rushx typeorm migration:revert
    rmold -rf dist/
    rushx build
}

# windows terminal tabs
function tabs() {
    local instance=$1
    if [[ "$instance" == "dev" || "$instance" == "prod" ]]; then
        wt -w 0 nt -p "bash" --title "${instance} scheduler"
        wt -w 0 nt -p "bash" --title "${instance} bot-1"
        wt -w 0 nt -p "bash" --title "${instance} bot-2"
        wt -w 0 nt -p "bash" --title "${instance} nginx"
        wt -w 0 nt -p "bash" --title "${instance} orchestrator"
        wt -w 0 nt -p "bash" --title "${instance} bot-guest"
    else
        echo "Error: Invalid instance. Use 'dev' or 'prod'."
    fi
}

# server logs
function logs() {
    local instance=$1
    local service=$2
    local t=${3:-150}

    if [[ "$instance" != "dev" && "$instance" != "prod" && "$instance" != "aws" ]]; then
        echo "Invalid instance. Use 'dev', 'prod' or 'aws'."
        return 1
    fi

    case $service in
        scheduler)
            service_name="runbotics-orchestrator_runbotics-scheduler"
            ;;
        orchestrator)
            service_name="runbotics-orchestrator_runbotics-orchestrator"
            ;;
        botone)
            service_name="runbotics-desktop_runbotics-desktop"
            ;;
        bottwo)
            service_name="runbotics-desktop-2_runbotics-desktop-2"
            ;;
        nginx)
            service_name="runbotics-nginx_runbotics-nginx"
            ;;
        *)
            echo "Invalid service. Use 'botone', 'bottwo', 'scheduler', 'orchestrator', or 'nginx'."
            return 1
            ;;
    esac

    ssh $instance docker service logs -f --tail $t $service_name
}

# github pull request creation
function openpr() {
        branchName=$(git branch --show-current)
        taskNumber=$(echo "$branchName" | cut -d'-' -f2-)
        read -p "Enter PR title: " prTitle
        gh pr create --title "[RPA-$taskNumber] $prTitle." --web
}

git_checkout_local_branch() {
    local branches
    local selected=0
    local key

    IFS=$'\n' branches=($(git branch | sed 's/^\* //' | sed 's/^  //'))
    local branch_count=${#branches[@]}

    if [[ $branch_count -eq 0 ]]; then
        echo "No local branches available."
        return
    fi

    display_branches() {
        clear
        echo "Select a branch (use 'j', 'k', Enter):"
        for i in "${!branches[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo "> ${branches[$i]}"
            else
                echo "  ${branches[$i]}"
            fi
        done
    }

    while true; do
        display_branches
        read -rsn1 key

        case $key in
            j)
                ((selected = (selected + 1) % branch_count))
                ;;
            k)
                ((selected = (selected - 1 + branch_count) % branch_count))
                ;;
            "")
                git checkout "${branches[$selected]}"
                break
                ;;
            q)
                echo "Aborted."
                break
                ;;
        esac
    done
}

function removing_local_branches_by_format() {
    local pattern=$1

    echo "running: git branch | grep $pattern | xargs git branch -D"

    git branch | grep $pattern | xargs git branch -D
}

# PS1
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)';
PS1='\[\e[48;5;42m\] \[\e[30m\]\W\[\e[39m\] \[\e[48;5;69m\] \[\e[30;2m\]${PS1_CMD1}\[\e[22;39m\] \[\e[0m\] \[\e[38;5;42m\]\\$\[\e[0m\] '