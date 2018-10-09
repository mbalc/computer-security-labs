#!/bin/bash

wrong_number_of_args() {
	if [ $# -ne 3 ]
	then
		echo "Wrong number of arguments: required 3 and gotten $# instead"
		echo "Usage: $0 [users_desc_path] [master_id] [task_count]"
		exit 1
	fi
}

wrong_path_given() {
	 if [[ ! -f $1 ]]
	 then
		echo "$1 is not a valid file path"
		exit 1
	 fi
}

check_arguments_invalid() {
	wrong_number_of_args "$@"
	wrong_path_given "$@"
}

create_documents_dir() {
	mkdir documents
}

create_tasks_dir() {
	mkdir tasks
}

create_solutions_dir() {
	mkdir solutions
}

create_dirs() {
	create_documents_dir
	create_tasks_dir
	create_solutions_dir
}

create_solutions_subdirs() {
	echo
}

handle_master_permissions() {
	echo
}

handle_line() {
	echo $line
}

create_files_from_arg_contents() {
	#create_dirs
	cat $users_desc_path | while read line
	do
		handle_line
	done
}

parse_args() {
	users_desc_path="$1"
	master_id="$2"
	task_count="$3"
}

main() {
	check_arguments_invalid $@
	parse_args "$@"
	create_files_from_arg_contents
	echo "Done!"
}

main $@

