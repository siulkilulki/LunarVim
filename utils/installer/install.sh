#!/bin/bash

set -o nounset # error when referencing undefined variable
set -o errexit # exit when command fails

installnodemac() {
  brew install lua
  brew install node
  brew install yarn
}

installnodeubuntu() {
  sudo apt -y install nodejs
  sudo apt -y install npm
}

moveoldnvim() {
  echo "Another ~/.config/nvim is present."
  echo -n "Do you want to continue (y/n)?"
  read answer
  if [ "$answer" == "${answer#[Yy]}" ]; then
    exit
  fi
}

installnodearch() {
  sudo pacman -S nodejs
  sudo pacman -S npm
}

installnodefedora() {
    sudo dnf install -y nodejs 
    sudo dnf install -y npm
}

installnodegentoo() {
	echo "Printing current node status..."
	emerge -pqv net-libs/nodejs
	echo "Make sure the npm USE flag is enabled for net-libs/nodejs"
	echo "If it isn't enabled, would you like to enable it with flaggie? (Y/N)"
	read answer
        [ "$answer" != "${answer#[Yy]}" ] && sudo flaggie net-libs/nodejs +npm
	sudo emerge -avnN net-libs/nodejs
}

installnode() {
	echo "Installing node..."
	[ "$(uname)" == "Darwin" ] && installnodemac
	[ -n "$(cat /etc/os-release | grep Ubuntu)" ] && installnodeubuntu
	[ -f "/etc/arch-release" ] && installnodearch
	[ -f "/etc/artix-release" ] && installnodearch
	[ -f "/etc/fedora-release" ] && installnodefedora
	[ -f "/etc/gentoo-release" ] && installnodegentoo
	[ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ] && echo "Windows not currently supported"
	# sudo npm i -g neovim
}

installpiponmac() {
  sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  rm get-pip.py
}

installpiponubuntu() {
  sudo apt -y install python3-pip >/dev/null
}

installpiponarch() {
  pacman -Syu python-pip
}

installpiponfedora() {
  sudo dnf install -y pip >/dev/nul
}

installpipongentoo() {
	sudo emerge -avn dev-python/pip
}

installpip() {
	echo "Installing pip..."
	[ "$(uname)" == "Darwin" ] && installpiponmac
	[ -n "$(cat /etc/os-release | grep Ubuntu)" ] && installpiponubuntu
	[ -f "/etc/arch-release" ] && installpiponarch
	[ -f "/etc/fedora-release" ] && installpiponfedora
	[ -f "/etc/gentoo-release" ] && installpipongentoo
	[ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ] && echo "Windows not currently supported"
}

installpynvim() {
	echo "Installing pynvim..."
	if [ -f "/etc/gentoo-release" ]; then
		echo "Installing using Portage"
		sudo emerge -avn dev-python/pynvim
	else
		pip3 install pynvim --user
	fi
}

installpacker() {
  git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
}

cloneconfig() {
  echo "Cloning LunarVim configuration"
  git clone https://github.com/siulkilulki/LunarVim.git ~/.config/nvim
  # mv $HOME/.config/nvim/init.lua $HOME/.config/nvim/init.lua.tmp
  # mv $HOME/.config/nvim/utils/init.lua $HOME/.config/nvim/init.lua
  # rm $HOME/.config/nvim/init.lua
  # mv $HOME/.config/nvim/init.lua.tmp $HOME/.config/nvim/init.lua
}

asktoinstallnode() {
  echo "node not found"
  echo -n "Would you like to install node now (y/n)? "
  read answer
  [ "$answer" != "${answer#[Yy]}" ] && installnode
}

asktoinstallhackfont() {
    echo -n "Would you like to install hack font (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        installhackfont
    fi;
}

asktoinstallpip() {
  # echo "pip not found"
  # echo -n "Would you like to install pip now (y/n)? "
  # read answer
  # [ "$answer" != "${answer#[Yy]}" ] && installpip
  echo "Please install pip3 before continuing with install"
  exit
}

installonmac() {
  brew install ripgrep fzf ranger
  npm install -g tree-sitter-cli
}

pipinstallueberzug() {
  which pip3 >/dev/null && pip3 install ueberzug --user || echo "Not installing ueberzug pip not found"
}

installpillowsimd() {
  sudo pip3 uninstall -y pillow
  CC="cc -mavx2" pip3 install --no-cache-dir -I -U --force-reinstall pillow-simd \
    --global-option="build_ext" \
    --global-option="--enable-zlib" \
    --global-option="--enable-jpeg" \
    --global-option="--enable-tiff" \
    --global-option="--enable-freetype" \
    --global-option="--enable-lcms" \
    --global-option="--enable-webp" \
    --global-option="--enable-webpmux" \
    --global-option="--enable-jpeg2000"
}

installonubuntu() {
  sudo apt -y install ripgrep fzf ranger
  sudo apt -y install libjpeg-turbo8-dev zlib1g-dev libtiff5-dev liblcms2-dev libfreetype6-dev libwebp-dev libharfbuzz-dev libfribidi-dev libopenjp2-7-dev libraqm0 python-dev python3-dev libxtst-dev

  pip3 show  >/dev/null && echo "pillow-simd installed, moving on..." || installpillowsimd
  # install ueberzug
  pip3 install ueberzug --user
  pip3 install neovim-remote --user
  npm install -g tree-sitter-cli
}

installonarch() {
  sudo pacman -S ripgrep fzf ranger
  which yay >/dev/null && yay -S python-ueberzug-git || pipinstallueberzug
  pip3 install neovim-remote --user
  npm install -g tree-sitter-cli
}

installonfedora() {
    sudo dnf groupinstall "X Software Development"
    sudo dnf install -y fzf ripgrep ranger
    pip3 install wheel ueberzug
}

installongentoo() {
	sudo emerge -avn sys-apps/ripgrep app-shells/fzf app-misc/ranger dev-python/neovim-remote virtual/jpeg sys-libs/zlib
	pipinstallueberzug
	npm install -g tree-sitter-cli
}

installextrapackages() {
	  [ "$(uname)" == "Darwin" ] && installonmac
	  [ -n "$(cat /etc/os-release | grep Ubuntu)" ] && installonubuntu
	  [ -f "/etc/arch-release" ] && installonarch
	  [ -f "/etc/artix-release" ] && installonarch
	  [ -f "/etc/fedora-release" ] && installonfedora
	  [ -f "/etc/gentoo-release" ] && installongentoo
	  [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ] && echo "Windows not currently supported"
}

installhackfont() {
    fontdir=~/.local/share/fonts
    echo "Installing hack nerd font with ligatures"
    wget $(curl -s https://api.github.com/repos/gaplo917/Ligatured-Hack/releases/latest | grep 'browser_' | cut -d\" -f4) -O $fontdir/hack.zip
    unzip -o $fontdir/hack.zip -d $fontdir
    rm $fontdir/hack.zip
    echo "Installing hack nerd font without ligatures"
    wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip -O $fontdir/hack.zip
    unzip -o $fontdir/hack.zip -d $fontdir
    rm $fontdir/*Windows*.ttf
    rm $fontdir/hack.zip
}

# Welcome
echo 'Installing LunarVim'

# move old nvim directory if it exists
[ -d "$HOME/.config/nvim" ] && moveoldnvim

# install pip
which pip3 >/dev/null && echo "pip installed, moving on..." || asktoinstallpip

# install node and neovim support
which node >/dev/null && echo "node installed, moving on..." || asktoinstallnode

# install pynvim
pip3 list | grep pynvim >/dev/null && echo "pynvim installed, moving on..." || installpynvim

if [ -e "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]; then
	echo 'packer already installed'
else
  installpacker
fi

asktoinstallhackfont

if [ -a "$HOME/.config/nvim/init.lua" ]; then
  echo 'LunarVim already installed'
else
  # clone down config
  cloneconfig
  # echo 'export PATH=$HOME/.config/nvim/utils/bin:$PATH' >>~/.zshrc
  # echo 'export PATH=$HOME/.config/nvcode/utils/bin:$PATH' >>~/.bashrc
fi
installextrapackages

nvim -u $HOME/.config/nvim/init.lua +PackerInstall
echo "I recommend you also install and activate a font from here: https://github.com/ryanoasis/nerd-fonts"

# echo "I also recommend you add 'set preview_images_method ueberzug' to ~/.config/ranger/rc.conf"

# echo 'export PATH=/home/$USER/.config/nvcode/utils/bin:$PATH appending to zshrc/bashrc'
