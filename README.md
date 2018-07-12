# *Software* for Vim

***Software* is currently in private beta. To use this plugin, please join the wait list at https://software.com**

*Software* measures activity in your text editor or IDE so you can see the times during the day when you are the most productive. We also help you see how much you code at work or at nights and weekends, how meetings impact the amount you code, and more. 

## Setup

<!--- Begin: setup --->

### Install

#### VimPlug

1. Place this in your .vimrc: `Plug 'swdotcom/swdc-vim'`
2. **Source** your .vimrc: `:source ~/.vimrc`
3. **Install** *Software*: `:PlugInstall`
4. **Log in** to authenticate your account: `:SoftwareLogIn` (only required for the first plugin you install)

![Install](https://user-images.githubusercontent.com/27828739/42648340-75daea6c-85bb-11e8-83c3-6cbde3f2fd16.gif)

#### Vundle

1. Place this in your .vimrc: `Plugin 'swdotcom/swdc-vim'`
2. **Source** your .vimrc: `:source ~/.vimrc`
3. **Install** *Software*: `:PluginInstall`
4. **Log in** to authenticate your account: `:SoftwareLogIn` 

For Vundle version < 0.10.2, replace Plugin with Bundle above.

#### Pathogen

Run the following commands in your terminal: 

```
cd ~/.vim/bundle
git clone git://github.com/swdotcom/swdc-vim.git
```

**Log in** to authenticate your account: `:SoftwareLogIn` 

#### NeoBundle

1. Place this in your .vimrc: `NeoBundle 'swdotcom/swdc-vim'`
2. **Source** your .vimrc: `:source ~/.vimrc`
3. **Install** *Software*: `:NeoBundleInstall`
4. **Log in** to authenticate your account: `:SoftwareLogIn` 


### Commands

* `:SoftwareKPM` - retrieve last minute's KPM
* `:SoftwareSessionTime` - retrieve total time for current session
* `:SoftwareLogIn` - log in to Software.com

### Uninstall

1. **Remove** `'swdotcom/swdc-vim'` from your .vimrc
2. **Run** `:PluginClean` in Vim
3. **Remove** the `.software` folder from your home directory

<!--- End: setup --->

## Privacy

Your code is safe! We never process, send or store your code and we respect developer privacy. We give developers full control over their personal information, and we are fully committed to the spirit of privacy frameworks, such as GDPR. For more information, please review our [Privacy Policy](https://software.com/privacy-policy).
