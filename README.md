# Code Time for Vim

> **Code Time** is an open source plugin that provides programming metrics right in your code editor.

<!-- <p align="center" style="margin: 0 10%">
  <img src="" alt="Code Time for Vim" />
</p> -->

## Power up your development

**In-editor dashboard**
Get daily and weekly reports of your programming activity right in your code editor.

**Status bar metrics**
After installing our plugin, your status bar will show real-time metrics about time coded per day.

**Weekly email reports**
Get a weekly report delivered right to your email inbox.

**Data visualizations**
Go to our web app to get simple data visualizations, such as a rolling heatmap of your best programming times by hour of the day.

**Calendar integration**
Integrate with Google Calendar to automatically set calendar events to protect your best programming times from meetings and interrupts.

**More stats**
See your best music for coding and the speed, frequency, and top files across your commits.

## Why you should try it out

-   Automatic time reports by project
-   See what time you code your best—find your “flow”
-   Defend your best code times against meetings and interrupts
-   Find out what you can learn from your data

## It’s safe, secure, and free

**We never access your code**
We do not process, send, or store your proprietary code. We only provide metrics about programming, and we make it easy to see the data we collect. 

**Your data is private**
We will never share your individually identifiable data with your boss. In the future, we will roll up data into groups and teams but we will keep your data anonymized.

**Free for you, forever**
We provide 90 days of data history for free, forever. In the future, we will provide premium plans for advanced features and historical data access.

<!--- Begin: setup --->

## Getting started

The Code Time plugin for Vim can be installed either manually or via your plugin manager of choice.

### Manually
1. Create or find your `.vim` directory
2. Create a directory called `bundle` inside of your `.vim` folder
3. Clone the Code Time plugin for Vim to your `.vim/bundle` directory:

```bash
git clone swdotcom/swdc-vim
```

4. If you haven't created a `.vimrc` file, you'll have to create it first in your home directory
5. Set the runtime path in your .vimrc file: 

```
set runtimepath^=~/.vim/bundle/swdc-vim.vim
```

6. Source your .vimrc in Vim: `:source ~/.vimrc`
7. Log in: `:SoftwareLogin`

### With VimPlug 
1. Add `Plug 'swdotcom/swdc-vim'` to your `.vimrc` so it looks something like this: 

```
call plug#begin('~/.vim/plugins')
Plug 'swdotcom/swdc-vim'
call plug#end()
```

2. Source your .vimrc in Vim: `:source ~/.vimrc`
3. Install Code Time with `:PlugInstall`
4. Log in: `:SoftwareLogin`

### With Vundle
1. Add `Plugin 'swdotcom/swdc-vim'` to your `.vimrc` so it looks something like this:

```
set nocompatiblefiletype offset rtp+=~/.vim/bundle/Vundle.vimcall 
vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'swdotcom/swdc-vim'
call vundle#end()
```

2. Install Code Time with `:PluginInstall`
3. Log in: `:SoftwareLogin`

### With Pathogen
1. Run the following commands in your terminal: 

```
cd ~/.vim/bundlegit
clone https://github.com/swdotcom/swdc-vim.git
```

2. If you're a new Pathogen user, set up your `.vimrc` so it looks something like this:

```
execute pathogen#infect() syntax on filetype plugin indent on
```

3. Log in: `:SoftwareLogin`

### With NeoBundle

1. Add `NeoBundle 'swdotcom/swdc-vim'` to your `.vimrc` so it looks something like this:

```
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'swdotcom/swdc-vim'
call neobundle#end()‍
filetype plugin indent on
```

2. Install Code Time with ```:NeoBundleInstall```
3. Log in: `:SoftwareLogin`‍

<!--- End: setup --->
