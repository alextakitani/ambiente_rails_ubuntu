#!/bin/bash

function usage {
  echo "Uso: $0 -n seu_nome -e seu_email"
}

#processa parametros
if [ $# -eq 0 ] ; then
	usage
	exit 1
fi
while [ $# -gt 1 ] ; do
	case $1 in
		-n) nome=$2 ; shift 2 ;;
		-e) email=$2 ; shift 2 ;;
		-*) usage
			exit 1 ;;
		*) shift 1 ;;
	esac
done

	
if [ "$nome" = "" ]; then
	echo 'Erro: nome é obrigatorio'
	usage
	exit 1
fi

if [ "$email" = "" ]; then
	echo 'Erro: email é obrigatorio'
	usage
	exit 1
fi

#instala as dependencias
sudo apt-get install aptitude -y

sudo aptitude install ruby1.8 ruby1.8-dev libgtkmm-2.4-dev libnotify-bin libqtwebkit-dev libgnomeui-0 -y
sudo aptitude install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev  g++ openjdk-6-jre-headless subversion libmysqlclient-dev libcurl4-openssl-dev libmagick9-dev libpq-dev -y

#instala o rvm
if ! [ -s "$HOME/.rvm/scripts/rvm" ] ; then
curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o rvm-installer ; chmod +x rvm-installer ; ./rvm-installer --version latest

# se nao tiver bashrc, cria
if [ ! -s "$HOME/.bashrc" ] ; then
  echo 'if [[ -s "$HOME/.rvm/scripts/rvm" ]]  ; then source "$HOME/.rvm/scripts/rvm" ; fi' > ~/.bashrc
fi

source ~/.bashrc
rm rvm-installer
fi

#instala rvm ou o ruby
if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
	~/.rvm/bin/rvm install 1.9.3	
	~/.rvm/bin/rvm use 1.9.3 --default
else
	echo 'Erro: Não consegui encontrar o rvm.'
	exit 1
fi

#cria o gemrc e configura para não instalar ri e rdoc
echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

#configura usuario e senha do git
git config --global user.name $nome
git config --global user.email $email

#instala o vim e as dependencias
sudo aptitude install vim-gtk exuberant-ctags ack-grep -y
sudo ln -s /usr/bin/ack-grep /usr/local/bin/ack

~/.rvm/bin/rvm use system

git clone git://github.com/alextakitani/vimfiles.git ~/.vim
cd ~/.vim
~/.rvm/bin/rake install

echo ".vimrc copiado, não esqueça de editar..."
cp ~/.vim/vimrc ~/.vimrc.temp

cd ~/.vim/bundle/command-t/ruby/command-t/
make clean
/usr/bin/ruby extconf.rb
make
cd ~

~/.rvm/bin/rvm use 1.9.3

#gem install bundler

#substitui o leader do .vimrc
sed 's/","/";"/gp' ~/.vimrc.temp > ~/.vimrc
rm .vimrc.temp

##carrega minhas configs de vim
# .vimrc.local

cat > .vimrc.local <<End-of-message
"configura fonte
set guifont=Monospace\ 12

"eu gosto de usar as setas do teclado!
map <Left> <Left>
map <Right> <Right>
map <Up> <Up>
map <Down> <Down>
imap <up> <up>
imap <down> <down>
imap <left> <left>
imap <right> <right>

"configura o mouse 
set mouse=a
set ttymouse=xterm2

"control+s salva
nmap <C-s> :w<CR>
imap <silent><C-s> <ESC>:w<CR>a

End-of-message


