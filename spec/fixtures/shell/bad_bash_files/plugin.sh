#!/bin/bash
#
#	Bash script to "plugin" to the dotfile repository, does a lot of fun stuff
#		like turning the normal dotfiles (eg .bashrc) into symlinks to this
#		repository's versions of those files (ensure that updates are just a
#		'git pull' away), optionally moving old files so that they can be
#		preserved, setting up a cron job to automate the aforementioned git
#		pull, and maybe some more fun stuff
#

shopt -s nocasematch	# This makes pattern matching case-insensitive

POSTFIX="local"
URL="https://github.com/brcooley/.f.git"
PUSHURL="git@github.com:brcooley/.f.git"

overwrite=true

print_help () {
	echo -e "\nA script to keep dotfiles up to date\n"
	echo "Options:"
	echo "    -k, --keep-local    Keeps local copies of dotfiles by appending"
	echo "                        \"$POSTFIX\" to them"
	exit 0
}


for opt in $@; do
	case $opt in
		-k | --keep-local) overwrite=false;;
		-h | --help) print_help;;
	esac
done



for f in .*; do
	if [ "$f" = ".git" -o "$f" = "." -o "$f" = ".." -o "$f" = ".f" ]; then continue; fi
	if [ -f "$HOME/$f" ]; then
		if [ $overwrite = false ]; then
			mv "$HOME/$f" "$HOME/${f}_$POSTFIX"
		else
			rm "$HOME/$f"
		fi
		# echo "Moving ~/$f to $HOME/${f}_$POSTFIX"
	fi
	ln -s "$PWD/$f" "$HOME/$f"
done

# Git versions prior to 1.7.? (1.7.1 confirmed) do not have a --local option
git config --local remote.origin.url "$URL"
git config --local remote.origin.pushurl "$PUSHURL"
crontab .jobs.cron
source ~/.bashrc
echo "Plugin succesful"