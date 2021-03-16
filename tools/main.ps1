#!/usr/bin/env bash

# import global variables
. require_once "$devbox_root/tools/system/constants.ps1"
# import output functions (print messages)
. require_once "$devbox_root/tools/system/output.ps1"
# import infrastructure functions
. require_once "$devbox_root/tools/docker/infrastructure.ps1"
# import main project functions entrypoint
. require_once "$devbox_root/tools/project/project-main.ps1"
# import common functions for all projects structure
. require_once "$devbox_root/tools/project/all-projects.ps1"
# import platform-tools functions
. require_once "$devbox_root/tools/project/platform-tools.ps1"
# import functions to show project information after start
. require_once "$devbox_root/tools/print/print-project-info.ps1"

############################ Public functions ############################

function start_devbox_project($_selected_project = "") {
    show_success_message "Starting DevBox project '${_selected_project}'" "1"

    ensure_project_configured ${_selected_project}
    if ((is_project_started $_selected_project)) {
        show_warning_message "Project '${_selected_project}' is already started."
        show_warning_message "Please ensure selected project is correct, or stop it and try to start again."
        exit 1
    }

    # initialize basic project variables and directories
    init_selected_project "$_selected_project"

    show_success_message "Starting common infrastructure." "1"
    # Start common infra services, e.g. portainer, nginx-reverse-proxy, mailer, etc.
    dotenv_export_variables "${dotenv_infra_filepath}"
    start_infrastructure "${dotenv_infra_filepath}"

    show_success_message "Starting project" "1"
    # Prepare all required configs and start project services
    start_project

    show_success_message "Project '${_selected_project}' was successfully started" "1"

    # Print final project info
    print_info

    # Run platform tools menu inside web-container
    run_platform_tools

    # Unset all used variables
    dotenv_unset_variables "${dotenv_infra_filepath}"
    dotenv_unset_variables "$project_up_dir/.env"
}

function stop_devbox_project($_selected_project = "") {
    ensure_project_configured ${_selected_project}
    if (-not (is_project_started $_selected_project)) {
        show_warning_message "DevBox project '${_selected_project}' is already stopped" "1"
        return
    }
    show_success_message "Stopping DevBox project '${_selected_project}'" "1"

    # initialize basic project variables and directories
    init_selected_project "${_selected_project}"

    stop_current_project

    show_success_message "Project '${_selected_project}' was successfully stopped" "1"
}

function down_and_clean_devbox_project($_selected_project = "") {
    show_success_message "Stopping and cleaning DevBox project '${_selected_project}'" "1"

    # initialize basic project variables and directories
    init_selected_project "${_selected_project}"

    down_and_clean_current_project

    show_success_message "Project '${_selected_project}' was successfully stopped and cleaned" "1"
}

function stop_devbox_all() {
    show_success_message "Stopping all DevBox projects" "1"

    # Stop all project containers
    foreach ($_selected_project in ((get_project_list).Split(','))) {
        if (is_project_configured ${_selected_project}) {
            stop_devbox_project "$_selected_project"
        }
    }

    show_success_message "Stopping common infrastructure." "1"
    stop_infrastructure "${dotenv_infra_filepath}"

    show_success_message "DevBox was successfully stopped" "1"
}

function down_and_clean_devbox_all() {
    show_success_message "Stopping and cleaning all DevBox projects" "1"

    # Stop all project containers
    foreach ($_selected_project in ((get_project_list).Split(','))) {
        if (is_project_configured ${_selected_project}) {
            down_and_clean_devbox_project "$_selected_project"
        }
    }

    show_success_message "Downing common infrastructure." "1"
    stop_infrastructure "${dotenv_infra_filepath}"

    show_success_message "DevBox was successfully stopped and cleaned" "1"
}

function docker_destroy() {
    show_success_message "Purging all DevBox services, containers and volumes" "1"
    show_warning_message "Pay attention this action is only for emergency purposes when something went wrong and regular stopping does not work"
    show_warning_message "All files left of places and you will need to cleanup it manually if required."
    show_warning_message "This operation will kill and destroy all running docker data e.g. containers and volumes"

    destroy_all_docker_services

    show_success_message "Docker data was successfully purged" "1"
}

############################ Public functions end ############################