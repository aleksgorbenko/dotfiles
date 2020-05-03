#!/usr/bin/env bash

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

function ok() {
    echo "\r$COL_GREEN[ok]$COL_RESET "$1
}

function bot() {
    echo "\r$COL_GREEN\[._.]/$COL_RESET - "$1
}

function running() {
    echo "\r$COL_YELLOW ⇒ $COL_RESET"$1": "
}

function action() {
    echo "\r$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo "\r$COL_YELLOW[warning]$COL_RESET "$1
}

function error() {
    echo "\r$COL_RED[error]$COL_RESET "$1
}

function print_error() {
    printf " [✖] %s\n" "$1"
}

function print_result() {
    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"
}

function print_success() {
    printf " [✔] %s\n" "$1"
}
