#!/usr/bin/env bash
# Setup wizard for customizing the kramme-cc-workflow plugin
# Generates a customized version in ./dist/ with only selected components
# Compatible with bash 3.2 (macOS default)

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$PLUGIN_ROOT/dist"

# Source UI library
# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"

# Component lists (simple arrays for bash 3.2 compatibility)
COMMANDS=(
    "kramme:create-pr|Create clean PRs with narrative commits"
    "kramme:define-linear-issue|Create/refine well-structured Linear issues"
    "kramme:deslop|Remove AI-generated code slop from branch"
    "kramme:explore-interview|In-depth interview about topics/proposals"
    "kramme:find-bugs|Find bugs and security vulnerabilities"
    "kramme:fixup-changes|Intelligently fixup changes into existing commits"
    "kramme:implement-linear-issue|Start implementing a Linear issue"
    "kramme:iterate-pr|Iterate on PR until CI passes"
    "kramme:recreate-commits|Recreate branch with narrative-quality commits"
    "kramme:resolve-review-findings|Resolve code review findings"
    "kramme:review-pr|Comprehensive PR review with specialized agents"
    "kramme:verify|Run verification checks (tests, lint, build)"
)

AGENTS=(
    "kramme:code-reviewer|Review code for guidelines and best practices"
    "kramme:code-simplifier|Simplify code for clarity and maintainability"
    "kramme:comment-analyzer|Analyze comments for accuracy and quality"
    "kramme:deslop-reviewer|Detect AI-generated code patterns"
    "kramme:pr-relevance-validator|Filter out pre-existing issues in reviews"
    "kramme:pr-test-analyzer|Analyze test coverage quality"
    "kramme:silent-failure-hunter|Find inadequate error handling"
    "kramme:type-design-analyzer|Analyze type design quality"
)

SKILLS=(
    "kramme:changelog-generator|Auto-generate changelogs from commits"
    "kramme:connect-existing-feature-documentation-writer|Write Connect feature docs"
    "kramme:connect-migrate-legacy-store-to-ngrx-component-store|Migrate to NgRx ComponentStore"
    "kramme:connect-modernize-legacy-angular-component|Modernize Angular components"
    "kramme:markdown-converter|Convert documents to Markdown"
    "kramme:pr-description-generator|Generate PR descriptions"
    "kramme:recreate-commits|Recreate commits with clean history"
    "kramme:reimplement-in-clean-branch|Reimplement in a clean branch"
    "kramme:structured-implementation-workflow|Track complex implementations"
    "kramme:verification-before-completion|Verify before claiming complete"
)

HOOKS=(
    "block-rm-rf|Block dangerous rm -rf commands (safety)"
    "context-links|Display PR/Linear links when stopping"
)

# Selected components (populated by presets or custom selection)
SELECTED_COMMANDS=()
SELECTED_AGENTS=()
SELECTED_SKILLS=()
SELECTED_HOOKS=()

# Helper to extract key from "key|description" format
get_key() {
    echo "${1%%|*}"
}

# Helper to extract description from "key|description" format
get_desc() {
    echo "${1#*|}"
}

# Build display options array
build_display_options() {
    local -a items=("${!1}")
    for item in "${items[@]}"; do
        local key=$(get_key "$item")
        local desc=$(get_desc "$item")
        echo "$key - $desc"
    done | sort
}

# Preset bundles
preset_pr_workflow() {
    SELECTED_COMMANDS=("kramme:create-pr" "kramme:review-pr" "kramme:iterate-pr" "kramme:recreate-commits" "kramme:fixup-changes" "kramme:deslop")
    SELECTED_AGENTS=("kramme:code-reviewer" "kramme:code-simplifier" "kramme:deslop-reviewer" "kramme:pr-relevance-validator" "kramme:pr-test-analyzer" "kramme:silent-failure-hunter" "kramme:comment-analyzer" "kramme:type-design-analyzer")
    SELECTED_SKILLS=("kramme:pr-description-generator" "kramme:recreate-commits" "kramme:reimplement-in-clean-branch" "kramme:verification-before-completion")
    SELECTED_HOOKS=("context-links")
}

preset_linear_workflow() {
    SELECTED_COMMANDS=("kramme:define-linear-issue" "kramme:implement-linear-issue" "kramme:explore-interview")
    SELECTED_AGENTS=()
    SELECTED_SKILLS=("kramme:structured-implementation-workflow")
    SELECTED_HOOKS=("context-links")
}

preset_safety() {
    SELECTED_COMMANDS=("kramme:verify" "kramme:find-bugs")
    SELECTED_AGENTS=("kramme:code-reviewer" "kramme:silent-failure-hunter")
    SELECTED_SKILLS=("kramme:verification-before-completion")
    SELECTED_HOOKS=("block-rm-rf")
}

preset_all() {
    SELECTED_COMMANDS=()
    for item in "${COMMANDS[@]}"; do
        SELECTED_COMMANDS+=("$(get_key "$item")")
    done

    SELECTED_AGENTS=()
    for item in "${AGENTS[@]}"; do
        SELECTED_AGENTS+=("$(get_key "$item")")
    done

    SELECTED_SKILLS=()
    for item in "${SKILLS[@]}"; do
        SELECTED_SKILLS+=("$(get_key "$item")")
    done

    SELECTED_HOOKS=()
    for item in "${HOOKS[@]}"; do
        SELECTED_HOOKS+=("$(get_key "$item")")
    done
}

# Extract keys from selected display lines (removes " - description" part)
extract_keys() {
    while IFS= read -r line; do
        echo "${line%% - *}"
    done
}

# Custom selection workflow
custom_selection() {
    ui_info "Select the components you want to include:"

    # Commands
    ui_header "Commands"
    local cmd_options=()
    while IFS= read -r line; do
        cmd_options+=("$line")
    done < <(build_display_options COMMANDS[@])

    local selected_cmd_lines=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && selected_cmd_lines+=("$line")
    done < <(ui_choose_multi "Select commands to include:" "${cmd_options[@]}")

    SELECTED_COMMANDS=()
    for line in "${selected_cmd_lines[@]}"; do
        SELECTED_COMMANDS+=("$(echo "$line" | extract_keys)")
    done

    # Agents
    ui_header "Agents"
    local agent_options=()
    while IFS= read -r line; do
        agent_options+=("$line")
    done < <(build_display_options AGENTS[@])

    local selected_agent_lines=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && selected_agent_lines+=("$line")
    done < <(ui_choose_multi "Select agents to include:" "${agent_options[@]}")

    SELECTED_AGENTS=()
    for line in "${selected_agent_lines[@]}"; do
        SELECTED_AGENTS+=("$(echo "$line" | extract_keys)")
    done

    # Skills
    ui_header "Skills"
    local skill_options=()
    while IFS= read -r line; do
        skill_options+=("$line")
    done < <(build_display_options SKILLS[@])

    local selected_skill_lines=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && selected_skill_lines+=("$line")
    done < <(ui_choose_multi "Select skills to include:" "${skill_options[@]}")

    SELECTED_SKILLS=()
    for line in "${selected_skill_lines[@]}"; do
        SELECTED_SKILLS+=("$(echo "$line" | extract_keys)")
    done

    # Hooks
    ui_header "Hooks"
    local hook_options=()
    while IFS= read -r line; do
        hook_options+=("$line")
    done < <(build_display_options HOOKS[@])

    local selected_hook_lines=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && selected_hook_lines+=("$line")
    done < <(ui_choose_multi "Select hooks to include:" "${hook_options[@]}")

    SELECTED_HOOKS=()
    for line in "${selected_hook_lines[@]}"; do
        SELECTED_HOOKS+=("$(echo "$line" | extract_keys)")
    done
}

# Check if array contains element
array_contains() {
    local needle="$1"
    shift
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Generate hooks.json based on selected hooks
generate_hooks_json() {
    local output_file="$1"
    local has_pretooluse=false
    local has_stop=false

    array_contains "block-rm-rf" "${SELECTED_HOOKS[@]}" && has_pretooluse=true
    array_contains "context-links" "${SELECTED_HOOKS[@]}" && has_stop=true

    cat > "$output_file" << 'HEADER'
{
  "description": "Workflow hooks for kramme-cc-workflow plugin (customized)",
  "hooks": {
HEADER

    local need_comma=false

    # Add PreToolUse if needed
    if $has_pretooluse; then
        need_comma=true
        cat >> "$output_file" << 'PRETOOLUSE'
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/block-rm-rf.sh"
          }
        ]
      }
    ]
PRETOOLUSE
    fi

    # Add Stop if needed
    if $has_stop; then
        if $need_comma; then
            # Add comma to previous section
            printf '%s\n' "$(sed '$ s/]$/],/' "$output_file")" > "$output_file"
        fi
        cat >> "$output_file" << 'STOP'
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/context-links.sh"
          }
        ]
      }
    ]
STOP
    fi

    # Close JSON
    cat >> "$output_file" << 'FOOTER'
  }
}
FOOTER
}

# Generate the customized plugin
generate_plugin() {
    ui_header "Generating customized plugin"

    # Clean and create dist directory
    rm -rf "$DIST_DIR"
    mkdir -p "$DIST_DIR"

    # Copy plugin manifest
    mkdir -p "$DIST_DIR/.claude-plugin"
    cp "$PLUGIN_ROOT/.claude-plugin/plugin.json" "$DIST_DIR/.claude-plugin/"

    # Copy selected commands
    if [[ ${#SELECTED_COMMANDS[@]} -gt 0 ]]; then
        mkdir -p "$DIST_DIR/commands"
        for cmd in "${SELECTED_COMMANDS[@]}"; do
            if [[ -f "$PLUGIN_ROOT/commands/$cmd.md" ]]; then
                cp "$PLUGIN_ROOT/commands/$cmd.md" "$DIST_DIR/commands/"
                ui_success "Added command: $cmd"
            fi
        done
    fi

    # Copy selected agents
    if [[ ${#SELECTED_AGENTS[@]} -gt 0 ]]; then
        mkdir -p "$DIST_DIR/agents"
        for agent in "${SELECTED_AGENTS[@]}"; do
            if [[ -f "$PLUGIN_ROOT/agents/$agent.md" ]]; then
                cp "$PLUGIN_ROOT/agents/$agent.md" "$DIST_DIR/agents/"
                ui_success "Added agent: $agent"
            fi
        done
    fi

    # Copy selected skills
    if [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
        mkdir -p "$DIST_DIR/skills"
        for skill in "${SELECTED_SKILLS[@]}"; do
            if [[ -d "$PLUGIN_ROOT/skills/$skill" ]]; then
                cp -r "$PLUGIN_ROOT/skills/$skill" "$DIST_DIR/skills/"
                ui_success "Added skill: $skill"
            fi
        done
    fi

    # Generate hooks
    if [[ ${#SELECTED_HOOKS[@]} -gt 0 ]]; then
        mkdir -p "$DIST_DIR/hooks"
        generate_hooks_json "$DIST_DIR/hooks/hooks.json"

        # Copy required hook scripts
        for hook in "${SELECTED_HOOKS[@]}"; do
            if [[ -f "$PLUGIN_ROOT/hooks/$hook.sh" ]]; then
                cp "$PLUGIN_ROOT/hooks/$hook.sh" "$DIST_DIR/hooks/"
            fi
        done
        ui_success "Added hooks configuration"
    fi

    # Create a README noting this is customized
    {
        echo "# kramme-cc-workflow (Customized)"
        echo ""
        echo "This is a customized version of the kramme-cc-workflow plugin."
        echo ""
        echo "## Included Components"
        echo ""
        echo "### Commands (${#SELECTED_COMMANDS[@]})"
        for cmd in "${SELECTED_COMMANDS[@]}"; do
            echo "- \`/$cmd\`"
        done
        echo ""
        echo "### Agents (${#SELECTED_AGENTS[@]})"
        for agent in "${SELECTED_AGENTS[@]}"; do
            echo "- \`$agent\`"
        done
        echo ""
        echo "### Skills (${#SELECTED_SKILLS[@]})"
        for skill in "${SELECTED_SKILLS[@]}"; do
            echo "- \`$skill\`"
        done
        echo ""
        echo "### Hooks (${#SELECTED_HOOKS[@]})"
        for hook in "${SELECTED_HOOKS[@]}"; do
            echo "- \`$hook\`"
        done
        echo ""
        echo "## Installation"
        echo ""
        echo "\`\`\`bash"
        echo "claude /plugin install $DIST_DIR"
        echo "\`\`\`"
        echo ""
        echo "Generated on: $(date)"
    } > "$DIST_DIR/README.md"
}

# Show summary
show_summary() {
    ui_header "Selection Summary"

    echo -e "\n${BOLD}Commands (${#SELECTED_COMMANDS[@]})${NC}"
    for item in "${SELECTED_COMMANDS[@]}"; do
        echo -e "  ${GREEN}•${NC} $item"
    done

    echo -e "\n${BOLD}Agents (${#SELECTED_AGENTS[@]})${NC}"
    for item in "${SELECTED_AGENTS[@]}"; do
        echo -e "  ${GREEN}•${NC} $item"
    done

    echo -e "\n${BOLD}Skills (${#SELECTED_SKILLS[@]})${NC}"
    for item in "${SELECTED_SKILLS[@]}"; do
        echo -e "  ${GREEN}•${NC} $item"
    done

    echo -e "\n${BOLD}Hooks (${#SELECTED_HOOKS[@]})${NC}"
    for item in "${SELECTED_HOOKS[@]}"; do
        echo -e "  ${GREEN}•${NC} $item"
    done
    echo ""
}

# Main
main() {
    ui_header "kramme-cc-workflow Setup Wizard"
    ui_info "This wizard helps you create a customized version of the plugin"
    ui_info "with only the components you need."
    echo ""

    # Check for gum
    if ! $HAS_GUM; then
        ui_warn "Gum not found. Using basic bash interface."
        ui_info "For a better experience, install gum: brew install gum"
        echo ""
    fi

    # Choose preset or custom
    preset=$(ui_choose_single "How would you like to configure the plugin?" \
        "PR Workflow - Commands for PR creation, review, and iteration" \
        "Linear Integration - Commands for Linear issue management" \
        "Safety - Safety hooks and verification commands" \
        "All - Include all components" \
        "Custom - Pick individual components")

    case "$preset" in
        "PR Workflow"*) preset_pr_workflow ;;
        "Linear Integration"*) preset_linear_workflow ;;
        "Safety"*) preset_safety ;;
        "All"*) preset_all ;;
        "Custom"*) custom_selection ;;
    esac

    # Show summary
    show_summary

    # Confirm
    if ui_confirm "Generate customized plugin with these selections?"; then
        generate_plugin
        echo ""
        ui_success "Customized plugin generated at: $DIST_DIR"
        echo ""
        ui_info "To install, run:"
        echo ""
        echo "  claude /plugin install $DIST_DIR"
        echo ""
    else
        ui_warn "Cancelled. No files were generated."
        exit 1
    fi
}

main "$@"
