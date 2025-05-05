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
alias gchi=git_checkout_local_branch
alias grmb=removing_local_branches_by_format

# aliases
alias ....="cd ../../.."
alias ...="cd ../../"
alias ..="cd ../"
alias cur='cursor $@'

# default overvrites
alias grep='grep --color=auto'

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
