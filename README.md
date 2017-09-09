# zpacker

Lightweighted ZSH plugin management framework

## Installation

```zsh
git clone https://github.com/happyslowly/zpacker $HOME/.zpacker
cp $HOME/.zpacker/.zshrc.example $HOME/.zshrc
```

## zshrc example

```zsh
source $HOME/.zpacker/zpacker.zsh

# git plugin from famous oh-my-zsh
zpacker plugin 'robbyrussell/oh-my-zsh' lib/git.zsh

# syntax highlighting
zpacker plugin 'zsh-users/zsh-syntax-highlighting'

# for theme
zpacker theme 'happyslowly/clean'

# local profiles
zpacker local $HOME/.profiles

zpacker end
```

## License

[MIT](LICENSE.txt)
