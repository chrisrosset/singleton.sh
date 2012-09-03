#!/bin/sh
#
# singleton.sh
#
# Runs a program in a tmux session. If the program is already running, the script
# reattaches to the already running session.

# global variables
expected_args=1

# Exit error codes
e_args=1
e_not_in_path=2
e_tmux_not_available=3

error()
{
	case $1 in
	$e_args)
		echo "Usage: singleton <program_name>"
		;;
	$e_not_in_path)
		echo 'Requested program not in $PATH.'
		;;
	$e_tmux_not_available)
		echo "Tmux not in $PATH."
		;;
	esac

	exit $1
}

if [ $# -ne 1 ]
then
	error $e_args
fi

which tmux > /dev/null 2>&1
prog_in_path=$?

if [ $prog_in_path -ne 0 ]
then
	error $e_not_in_path
fi

which $1 > /dev/null 2>&1
prog_in_path=$?

if [ $prog_in_path -ne 0 ]
then
	error $e_not_in_path
fi

# get session list
tmux has-session -t $1
tmux_running=$?

if [ $tmux_running -ne 0 ]
then
	# tmux server not running or session unavailable, run new session
	tmux new-session -s $1 $1
else
	# session running, reattach
	tmux attach-session -t $1
fi
