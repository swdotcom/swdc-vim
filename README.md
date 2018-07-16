# ***Software*** for Vim

***Software* is currently in private beta. To use this plugin, please join the waitlist at https://software.com**

*Software* measures activity in your text editor or IDE so you can see the times during the day when you are the most productive. We also help you see how much you code at work or at nights and weekends, how meetings impact the amount you code, and more. 

## Commands

* `:SoftwareKPM` - get the last minute's KPM and code time for the active session
* `:SoftwareLogin` - log in to Software.com

## Setup

<!--- Begin: setup --->

### Install ***Software***

The *Software* plugin can be installed either manually or via your plugin manager of choice (see install instructions below).

![Install](https://user-images.githubusercontent.com/27828739/42648340-75daea6c-85bb-11e8-83c3-6cbde3f2fd16.gif)


#### Manual

1. Create or find your .vim directory
2. Create a 'bundle' directory inside of your .vim folder 
3. Clone the *Software* for Vim plugin to your .vim/bundle directory: `git clone 'swdotcom/swdc-vim'`
4. If you haven't created a .vimrc file, you'll have to create it first in your home directory.
5. Set the runtime path in your .vimrc file:

```
set runtimepath^=~/.vim/bundle/swdc-vim.vim
```

5. Source your .vimrc in Vim: `:source ~/.vimrc` 
6. Log in to *Software*: `:SoftwareLogin`


#### With VimPlug

1. Add `Plug 'swdotcom/swdc-vim'` to your .vimrc so it looks something like this: 

```
call plug#begin('~/.vim/plugins')
Plug 'swdotcom/swdc-vim'
call plug#end()
```

2. Source your .vimrc in Vim: `:source ~/.vimrc`
3. Install *Software* with `:PlugInstall`
4. Log in to *Software*: `:SoftwareLogin`


#### With Vundle

1. Add `Plugin 'swdotcom/swdc-vim'` to your .vimrc so it looks something like this: 

```
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'swdotcom/swdc-vim'
call vundle#end()
```

2. Install *Software* with `:PluginInstall`
3. Log in to *Software*: `:SoftwareLogin`


#### With Pathogen

1. Run the following commands in your terminal: 

```
cd ~/.vim/bundle
git clone https://github.com/swdotcom/swdc-vim.git
```

2. If you're a new Pathogen user, set up your .vimrc so it looks something like this: 

```
execute pathogen#infect()
syntax on
filetype plugin indent on
```

3. Log in to *Software*: `:SoftwareLogin`


#### With NeoBundle

1. Add `NeoBundle 'swdotcom/swdc-vim'` to your .vimrc so it looks something like this: 

```
set runtimepath+=~/.vim/bundle/neobundle.vim/

call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'swdotcom/swdc-vim'
call neobundle#end()

filetype plugin indent on
```

2. Install *Software* with `:NeoBundleInstall`

3. Log in to *Software*: `:SoftwareLogin`


### Uninstall ***Software***

1. **Remove** `'swdotcom/swdc-vim'` from your .vimrc
2. **Run** your package manager's Vim command to remove *Software* (e.g. `:PluginClean` for VimPlug)
3. **Remove** the `.software` folder in your home directory


## Resources and Troubleshooting

Helpful links for getting started with Vim plugins: [VimPlug](https://github.com/junegunn/vim-plug), [Vundle](https://github.com/VundleVim/Vundle.vim), [Pathogen](https://github.com/tpope/vim-pathogen), [NeoBundle](https://github.com/Shougo/neobundle.vim), and [installing manually](https://howchoo.com/g/ztmyntqzntm/how-to-install-vim-plugins-without-a-plugin-manager).

<!--- End: setup --->

## Privacy

Your code is safe! We never process, send or store your code and we respect developer privacy. We give developers full control over their personal information, and we are fully committed to the spirit of privacy frameworks, such as GDPR. For more information, please review our [Privacy Policy](https://software.com/privacy-policy).
