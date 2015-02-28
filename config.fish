# fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'

function spawn -d 'Spawns a process, independent from the shell'
  nohup $argv > /dev/null ^ /dev/null &
end

function vim -d 'You removed vim. Stop typing this'
  read -p 'echo "There is no vim. Launch emacs? [Y/n] "' choice
  switch $choice
  case N n
       exit
  case '*'
       emacs -nw $argv
  end
end

function getRepo -d 'Finds out which repo owns a given package'
	 pacman -Ss (printf '^%s$' $argv) | head -n 1 | cut -d'/' -f 1
end

function isCommunity -d 'Tells if pkg is under community or multilib'
	 if test (count $argv) -ne 1
	    return 1
	 end

	 switch (getRepo $argv)
	 case community multilib
	      return 0
	 case '*'
	      return 1
	 end
end

function pbfetch -d 'Gets a PKGBUILD'
	 if test (count $argv) -eq 1

	    set REPO (getRepo $argv)
	    if test -z "$REPO"
	       echo $argv not found! >&2
	       return 1
	    end

	    switch $REPO
	    case extra core
	    	 set SRC packages
	    case multilib community
	    	 set SRC community
	    case '*'
	    	 echo Unknown repo $REPO >&2
		 return 1
	    end

	    svn checkout svn://svn.archlinux.org/$SRC/$argv/repos/$REPO-(uname -m) /tmp/$argv
	    or svn checkout svn://svn.archlinux.org/$SRC/$argv/repos/$REPO-any /tmp/$argv
	 end
end

function installpkg -d 'Installs packages from current directory'
	 sudo pacman -U --noconfirm $PWD/*.pkg.tar.*
end

function pkg -d 'Builds a PKGBUILD'
	 set CPWD (pwd)

	 if test (count $argv) -eq 1
	    pbfetch $argv
	    and cd /tmp/$argv
	    and fixpkgbuild $argv
	    and makepkg --skippgpcheck
	    and installpkg
	 end

	 cd $CPWD
end

function pkgupdate -d 'Builds updates from source. Pretty rough'
	 sudo pacman -Sy
	 and if test (count (pacman -Qqu)) -ne 0
	     set_color --bold -u white; echo 'Updates: '; set_color normal
	     pacman -Qqu
	     read -p 'echo "Update now? [Y/n] "' answer

	     switch $answer
	     case n N
	     	  return 0
             case '*'

             	pacman -Qqu | while read pkg
			     	echo 'Building' $pkg
	 			
				pkg $pkg
		
		              end
	     end
	 end
end


function compiler -d 'Checks compiler for a binary'
	 if test (count $argv) -ne 1
	    exit 1
	 end

	 set CHECK (if test -e $argv; echo $argv; else; which $argv; end)
	 or return 1

	 if not strings $CHECK | grep 'clang version' ^ /dev/null
	    if not strings $CHECK | grep 'GCC:' ^ /dev/null
	       echo 'Unknown compiler'
	    end
	 end
end

function fixpkgbuild -d 'Stop putting gcc everywhere'
	 if test (count $argv) -eq 1
	    set PKGBUILD /tmp/$argv/PKGBUILD
	    sed -i s/'CC="gcc'/'CC="clang'/g $PKGBUILD
	    and sed -i s/'CXX="g++'/'CXX="clang++'/g $PKGBUILD
	 end
end

set -gx CC /usr/lib/ccache/bin/clang
set -gx CXX /usr/lib/ccache/bin/clang++
set -gx CFLAGS '-march=native -pipe -O2'
set -gx CXXFLAGS '-march=native -pipe -O2'
set -gx MAKEFLAGS '-j8'
set -gx KOTLIN_HOME '/usr/share/kotlin'
set -gx EDITOR "emacs -nw"
set -gx GOPATH "/mnt/data/Go"
set -gx PATH "$HOME/.gem/ruby/2.2.0/bin/" "$HOME/Workspace/forklift/first-step/build" "$HOME/.local/bin" "/opt/kotlin/bin" $PATH /opt/cuda/bin
set -gx GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias raspivpn "ssh raspivpn"
alias visio "env WINEARCH=win32 WINEPREFIX=$HOME/.wine32 $HOME/.wine32/drive_c/Program\ Files/Microsoft\ Office/Office14/VISIO.EXE"
alias git hub
alias emacs "/usr/bin/emacs -nw"
alias gemacs /usr/bin/emacs