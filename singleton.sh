#!/bin/sh
#
# singleton.sh
#
# Runs a program in a tmux session. If the program is already running, the script
# reattaches to the already running session.

# Exit error codes
e_args=1
e_not_in_path=2
e_tmux_not_available=3

error()
{
	case $1 in
	$e_args)
		echo "Usage: singleton <program_name> [session_name]"
		echo "If not specified, session_name will be derived from program_name."
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


# global variables
command="$1"
session="$2"
program=`echo $1 | cut -d" " -f 1`



if [ $# -eq 2 ]; then
	sleep 1
elif [ $# -eq 1 ]; then
	session="$program"
else
	error $e_args
fi

which tmux > /dev/null 2>&1
prog_in_path=$?

if [ $prog_in_path -ne 0 ]; then
	error $e_tmux_not_available
fi

which $program > /dev/null 2>&1
prog_in_path=$?

if [ $prog_in_path -ne 0 ]; then
	error $e_not_in_path
fi

# get session list
tmux has-session -t "$session" > /dev/null 2>&1
tmux_running=$?

if [ $tmux_running -ne 0 ]
then
	# tmux server not running or session unavailable, run new session
	tmux new-session -s "$session" "$command"
else
	# session running, reattach
	tmux attach-session -t "$session"
fi
