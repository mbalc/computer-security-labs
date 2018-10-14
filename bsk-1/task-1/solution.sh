#!/bin/bash

wrong_number_of_args() {
	if [ $# -ne 3 ]
	then
		echo "Error: Wrong number of arguments: required 3 and gotten $# instead"
		echo "Usage: $0 [users_desc_path] [master_id] [task_count]"
		exit 1
	fi
}

wrong_path_given() {
	 if [[ ! -f $1 ]]
	 then
		echo "Error: $1 is not a valid file path"
		exit 1
	 fi
}

wrong_number_of_tasks() {
	is_number_regex='^[0-9]+$'
	if ! [[ $3 =~ $is_number_regex ]]
	then
	   echo "Error: Given task_count=$3 is not a number" >&2
	   exit 1
	fi
}

check_arguments_invalid() {
	wrong_number_of_args "$@"
	wrong_path_given "$@"
	wrong_number_of_tasks "$@"
}

new_dir() {
	sudo rm -rf $1
	sudo mkdir -p $1
	sudo chmod 000 $1
}


create_documents_dir() {
	new_dir documents
	sudo setfacl -m g:bsk-students:rx ./documents
	sudo setfacl -d -m g:bsk-students:r ./documents
	sudo setfacl -d -m g:bsk-masters:rw ./documents
}

create_tasks_dir() {
	new_dir tasks
	sudo setfacl -m g:bsk-students:rx ./tasks
	sudo setfacl -d -m g:bsk-students:r ./tasks
	sudo setfacl -d -m g:bsk-masters:rwx ./tasks
}

create_solutions_dir() {
	new_dir solutions
	sudo setfacl -m g:bsk-students:rx ./solutions
	sudo setfacl -m g:bsk-masters:rwx ./solutions
	sudo setfacl -d -m g:bsk-masters:rwx ./solutions
}

create_base_dirs() {
	create_documents_dir
	create_tasks_dir
	create_solutions_dir
}

task_dir_name() {
	echo "solutions/$user_login-$task_id"
}

create_solutions_subdirs() {
	for task_id in `seq 1 $task_count`
	do
		path=$(task_dir_name)
		new_dir $path
		sudo setfacl -m u:$user_login:rwx $path
		sudo setfacl -d -m u:$user_login:rwx $path
		sudo setfacl -m g:bsk-masters:rwx $path
		sudo setfacl -d -m g:bsk-masters:rwx $path
	done
}

remember_master_credentials() {
	master_first_name=$fname
	master_last_name=$lname
	master_login=$user_login

	sudo usermod -a -G bsk-masters $user_login
}

handle_user_description() {
	create_solutions_subdirs
}

create_files_from_arg_contents() {
	create_base_dirs
	for user_login in $all_user_logins
	do
		handle_user_description
	done
}

name_args() {
	users_desc_path="$1"
	master_id="$2"
	task_count="$3"
}

get_string_nth_subword() {
	echo $1 | awk "{print \$$2}"
}

create_unique_user_login() {
	user_id=$1
	fname=$2
	lname=$3
	initials=${fname:0:1}${lname:0:1}
	user_login=$initials$user_id

	sudo useradd $user_login -p $user_login
	sudo usermod -a -G bsk-students $user_login
}

require_master_id_valid() {
	if [[ $master_login == "" ]]
	then
		echo "Error: master_id=$master_id not present in $users_desc_path"
		exit 1
	fi
}

prepare_users() {
	sudo groupadd -f bsk-students
	sudo groupadd -f bsk-masters
	while read -r user_description
	do
		create_unique_user_login $user_description
		all_user_logins="$all_user_logins $user_login" #append
		if [ $master_id = $user_id ]
		then
			remember_master_credentials
		fi
	done < $users_desc_path

	require_master_id_valid
}

create_file() {
	echo "printf \"$2\" > $1" | sudo bash
}


generate_test_dir_content() {
	create_file documents/the_ultimate_programmers_guide.txt "Use Google\!"
	for task_id in `seq 1 $task_count`
	do
		create_file "tasks/task$task_id.txt" "what is the answer to life the universe and everything?"
	done
	for path in `sudo ls solutions`
	do
		create_file "solutions/$path/solution.cpp" "#include <cstdio>\n\nint main() {\n  printf("42");\n}\n"
	done
}

main() {
	check_arguments_invalid $@
	name_args "$@"
	prepare_users
	create_files_from_arg_contents
	generate_test_dir_content

	echo "Done!"
}

main $@

