#!/usr/bin/env zsh

ROOT=$HOME/.zpacker
REPOS=$ROOT/.repos

[ -d $REPOS ] || mkdir -p $REPOS

GITHUB=https://github.com

zpacker() {
    option=$1

    case $option in
        upgrade)
            for repo in $REPOS/*
            do
                echo "refreshing $repo ..."
                cd $repo && git pull && cd - >/dev/null
            done
            ;;
        clean)
            candidates=$(comm -23 <(\ls .zpacker/.repos/ | sort -u) \
                <(egrep 'plugin|theme' .zshrc | awk '{print $3}' | tr -d "'" | awk -F"/" '{print $2}' | sort -u))
            echo $candidates | while read candidate
            do
                rm -r $REPOS/$candidate
            done
            ;;
        plugin)
            shift
            _zpacker_plugin $*
            ;;
        theme)
            shift
            _zpacker_theme $*
            ;;
        local)
            shift
            _zpacker_local $*
            ;;
        end)
            # some housekeeping work
            # autocomplete
            autoload -U compinit && compinit
            zstyle ':completion:*' menu select=2
            ;;
        *)
            cat <<EOF
zpacker <option> [arguments]

where options:
    upgrade     - upgrade plugins
    clean       - cleanup non used plugins
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

_zpacker_plugin() {
    name=$(_zpacker_clone_repo $1)

    shift

    if [ $# -eq 0 ]; then
        if [ -f $REPOS/$name/$name.zsh ]; then
            source $REPOS/$name/$name.zsh
        elif [ -f $REPOS/$name/$name.sh ]; then
            source $REPOS/$name/$name.sh
        else
            for possible in $REPOS/$name/*.(zsh|sh)
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

    shift

    for dependency in $*
    do
        source $REPOS/$name/$dependency
    done

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
