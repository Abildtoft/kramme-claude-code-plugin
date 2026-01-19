#!/usr/bin/env bash
# UI library with Gum wrappers and bash fallback
# shellcheck disable=SC2034

# Check if gum is available
HAS_GUM=false
if command -v gum &> /dev/null; then
    HAS_GUM=true
fi

# Colors for bash fallback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print styled header
ui_header() {
    local text="$1"
    if $HAS_GUM; then
        gum style --foreground 212 --bold --border double --padding "1 4" "$text"
    else
        echo ""
        echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════${NC}"
        echo -e "${BOLD}${MAGENTA}  $text${NC}"
        echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════${NC}"
        echo ""
    fi
}

# Print info message
ui_info() {
    local text="$1"
    if $HAS_GUM; then
        gum style --foreground 39 "$text"
    else
        echo -e "${CYAN}$text${NC}"
    fi
}

# Print success message
ui_success() {
    local text="$1"
    if $HAS_GUM; then
        gum style --foreground 46 "✓ $text"
    else
        echo -e "${GREEN}✓ $text${NC}"
    fi
}

# Print warning message
ui_warn() {
    local text="$1"
    if $HAS_GUM; then
        gum style --foreground 214 "⚠ $text"
    else
        echo -e "${YELLOW}⚠ $text${NC}"
    fi
}

# Print error message
ui_error() {
    local text="$1"
    if $HAS_GUM; then
        gum style --foreground 196 "✗ $text"
    else
        echo -e "${RED}✗ $text${NC}"
    fi
}

# Confirmation dialog - returns 0 for yes, 1 for no
ui_confirm() {
    local prompt="$1"
    if $HAS_GUM; then
        gum confirm "$prompt"
        return $?
    else
        echo -e "${BOLD}$prompt${NC} [y/N] "
        read -r response
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# Multi-select from a list of options
# Usage: ui_choose_multi "header" option1 option2 option3
# Returns selected options, one per line (menu displayed on stderr)
ui_choose_multi() {
    local header="$1"
    shift
    local options=("$@")

    if $HAS_GUM; then
        printf '%s\n' "${options[@]}" | gum choose --no-limit --header "$header"
    else
        # Bash fallback with numbered selection
        # Display menu to stderr so command substitution only captures results
        echo -e "\n${BOLD}${CYAN}$header${NC}" >&2
        echo -e "${YELLOW}Enter numbers separated by spaces (e.g., 1 3 5), or 'all' for everything, or 'none' to skip:${NC}\n" >&2

        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt" >&2
            ((i++))
        done
        echo "" >&2

        read -r -p "> " selection

        if [[ "$selection" == "all" ]]; then
            printf '%s\n' "${options[@]}"
        elif [[ "$selection" == "none" || -z "$selection" ]]; then
            return
        else
            for num in $selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#options[@]} )); then
                    echo "${options[$((num-1))]}"
                fi
            done
        fi
    fi
}

# Single select from a list of options
# Usage: ui_choose_single "header" option1 option2 option3
# Returns selected option to stdout (menu displayed on stderr)
ui_choose_single() {
    local header="$1"
    shift
    local options=("$@")

    if $HAS_GUM; then
        printf '%s\n' "${options[@]}" | gum choose --header "$header"
    else
        # Display menu to stderr so command substitution only captures the result
        echo -e "\n${BOLD}${CYAN}$header${NC}\n" >&2

        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt" >&2
            ((i++))
        done
        echo "" >&2

        while true; do
            read -r -p "> " selection
            if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#options[@]} )); then
                echo "${options[$((selection-1))]}"
                return
            else
                echo -e "${RED}Please enter a number between 1 and ${#options[@]}${NC}" >&2
            fi
        done
    fi
}

# Show a spinner while a command runs
# Usage: ui_spin "message" command arg1 arg2
ui_spin() {
    local message="$1"
    shift

    if $HAS_GUM; then
        gum spin --spinner dot --title "$message" -- "$@"
    else
        echo -n "$message... "
        "$@" > /dev/null 2>&1
        local status=$?
        if [[ $status -eq 0 ]]; then
            echo -e "${GREEN}done${NC}"
        else
            echo -e "${RED}failed${NC}"
        fi
        return $status
    fi
}

# Display a formatted list of items
ui_list() {
    local header="$1"
    shift
    local items=("$@")

    echo -e "\n${BOLD}$header${NC}"
    for item in "${items[@]}"; do
        echo -e "  ${GREEN}•${NC} $item"
    done
    echo ""
}
