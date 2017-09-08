#!/usr/bin/env zsh

ROOT=$HOME/.zpacker
REPOS=$ROOT/.repos

[ -d $REPOS ] || mkdir -p $REPOS

GITHUB=https://github.com
OH_MY_ZSH=oh-my-zsh

autoload -U compaudit compinit

zpacker() {
    option=$1

    case $option in
        refresh)
            for repo in $REPOS/*
            do
                echo "refreshing $repo ..."
                cd $repo && git pull && cd - >/dev/null
            done
            # source profile again
            source $HOME/.zshrc
            ;;
        pack)
            shift
            _zpacker_pack $*
            ;;
        theme)
            shift
            _zpacker_theme $*
            ;;
        local)
            shift
            _zpacker_local $*
            ;;
        *)
            cat <<EOF
zpacker <option> [arguments]

where options:
  refresh       - refresh the local plugin repos
  pack          - load plugin
  theme         - load theme
  local         - load local personal profiles
EOF
            ;;
    esac

}

_zpacker_clone_repo() {
    repo_name=$1
    if [[ "$repo_name" =~ "/" ]]; then
        echo $repo_name | tr '/' ' ' | read author name
        if [[ ! -d $REPOS/$name ]]; then
            git clone $GITHUB/$author/$name $REPOS/$name
        fi
        echo $name
    else
        echo $repo_name
    fi
}

_zpacker_pack() {
    name=$(_zpacker_clone_repo $1)

    shift

    if [ $# -eq 0 ]; then
        if [ -f $REPOS/$name/$name.zsh ]; then
            source $REPOS/$name/$name.zsh
        else
            for possible in $REPOS/$name/*.zsh
            do
                source $possible
            done
        fi
    else
        for plugin in $*
        do
            source $REPOS/$name/$plugin
        done
    fi
}

_zpacker_theme() {
    autoload -U colors && colors
    setopt PROMPT_SUBST
    name=$(_zpacker_clone_repo $1)

    if [ -f $REPOS/$name/${name}.zsh-theme ]; then
        source $REPOS/$name/${name}.zsh-theme
    elif [ -f $REPOS/$name/${name}.zsh ]; then
        source $REPOS/$name/${name}.zsh
    elif [ -f $REPOS/$name/$name ]; then
        source $REPOS/$name/$name
    fi
}

_zpacker_local() {
    profile_path=$1
    if [[ -f "$profile_path" ]]; then
        source $profile_path
    elif [[ -d "$profile_path" ]]; then
        for profile in $profile_path/*
        do
            source $profile
        done
    fi
}
