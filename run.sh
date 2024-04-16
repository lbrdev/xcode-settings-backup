#!/bin/bash

# Get the username
USER="$(whoami)"
XC_USER_DATA="/Users/$USER/Library/Developer/Xcode/UserData"
BACKUP_BASE_DIR="./Backup"

# Function to select the backup directory
choose_backup_dir() {
    echo 'Select backup date:'
    select backup_dir in "$BACKUP_BASE_DIR"/*; do
        if [ -n "$backup_dir" ]; then
            echo "Using backup directory: $backup_dir"
            break
        else
            echo "Invalid backup selection, try again."
            return 1
        fi
    done
}

# Function to backup a specific theme
backup_theme() {
    echo 'Available color themes:'
    THEME_DIR="$XC_USER_DATA/FontAndColorThemes"
    i=1
    declare -a themes
    for theme in "$THEME_DIR"/*
    do
        themes[i]=$(basename "$theme")
        echo "$i. ${themes[i]}"
        ((i++))
    done

    read -p "Enter the number of the theme you want to backup: " choice
    theme_file="${themes[choice]}"

    if [[ -n "$theme_file" && -f "$THEME_DIR/$theme_file" ]]; then
        DEST="./Backup/$(date +"%Y-%m-%d_%H-%M-%S")/FontAndColorThemes/"
        mkdir -p "$DEST"
        cp "$THEME_DIR/$theme_file" "$DEST"
        echo "$theme_file backed up successfully."
    else
        echo "Invalid selection, exiting..."
        exit 1
    fi
}

# Function to backup template
backup_template() {
    echo 'Backing up header templates...'
    DEST="./Backup/$(date +"%Y-%m-%d_%H-%M-%S")"
    mkdir -p "$DEST"
    cp "$XC_USER_DATA/IDETemplateMacros.plist" "$DEST"
}

# Function to backup breakpoints
backup_breakpoints() {
    echo 'Backing up breakpoints...'
    DEST="./Backup/$(date +"%Y-%m-%d_%H-%M-%S")/xcdebugger/"
    mkdir -p "$DEST"
    cp "$XC_USER_DATA/xcdebugger/Breakpoints_v2.xcbkptlist" "$DEST"
}

# Function to install a theme
install_theme() {
    THEME_DIR="$backup_dir/FontAndColorThemes/"
    if [ -d "$THEME_DIR" ]; then
        echo "Available color themes:"
        i=1
        declare -a themes
        for theme_file in "$THEME_DIR"/*.xccolortheme; do
            themes[i]=$(basename "$theme_file")
            echo "$i. ${themes[i]}"
            ((i++))
        done
        read -p "Choose a theme to install (number): " theme_choice
        if [[ -n "${themes[theme_choice]}" && -f "$THEME_DIR/${themes[theme_choice]}" ]]; then
            mkdir -p "$XC_USER_DATA/FontAndColorThemes/"
            cp "$THEME_DIR/${themes[theme_choice]}" "$XC_USER_DATA/FontAndColorThemes/"
            echo "Theme ${themes[theme_choice]} installed successfully."
        else
            echo "Invalid selection, exiting..."
            exit 1
        fi
    else
        echo "No themes available in selected backup."
        exit 1
    fi
}

# Function to install template
install_template() {
    TEMPLATE_FILE="$backup_dir/IDETemplateMacros.plist"
    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$XC_USER_DATA"
        echo "Template installed successfully."
    else
        echo "Template file not found in backup, exiting..."
        exit 1
    fi
}

# Function to install breakpoints
install_breakpoints() {
    BP_DIR="$backup_dir/xcdebugger/"
    BP_FILE="$BP_DIR/Breakpoints_v2.xcbkptlist"
    if [ -f "$BP_FILE" ]; then
        mkdir -p "$XC_USER_DATA/xcdebugger/"
        cp "$BP_FILE" "$XC_USER_DATA/xcdebugger/"
        echo "Breakpoints installed successfully."
    else
        echo "Breakpoints file not found in backup, exiting..."
        exit 1
    fi
}

# Main menu
echo "Select an operation:"
echo "1. Backup"
echo "2. Install"
read -p "Enter your choice (1/2): " main_choice

if [ "$main_choice" == "1" ]; then
    echo "Select what to backup:"
    echo "1. Specific Color Theme"
    echo "2. Template"
    echo "3. Breakpoints"
    echo "4. All"
    read -p "Enter your choice (1/2/3/4): " choice
    case $choice in
        1)
            backup_theme
            ;;
        2)
            backup_template
            ;;
        3)
            backup_breakpoints
            ;;
        4)
            backup_theme
            backup_template
            backup_breakpoints
            ;;
        *)
            echo "Invalid input, exiting..."
            exit 1
            ;;
    esac
elif [ "$main_choice" == "2" ]; then
    if choose_backup_dir; then
        echo "Select what to install:"
        echo "1. Color Theme"
        echo "2. Template"
        echo "3. Breakpoints"
        echo "4. All"
        read -p "Enter your choice (1/2/3/4): " choice
        case $choice in
            1)
                install_theme
                ;;
            2)
                install_template
                ;;
            3)
                install_breakpoints
                ;;
            4)
                install_theme
                install_template
                install_breakpoints
                ;;
            *)
                echo "Invalid input, exiting..."
                exit 1
                ;;
        esac
    fi
else
    echo "Invalid operation, exiting..."
    exit 1
fi

echo 'Operation completed successfully.'
