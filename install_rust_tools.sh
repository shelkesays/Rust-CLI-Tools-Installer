#!/usr/bin/env bash

# Rust CLI Tools Auto-Installer Script
# Based on: https://medium.com/@Smyekh/your-terminal-is-boring-lets-fix-it-with-these-rust-cli-tools-03069693a2d1
# Author: Rahul Shelke
# Description: Interactive installer for Rust CLI tools with OS detection
# Compatible with bash 3.x+ and POSIX shells

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Global variables
OS=""
ARCH=""
VERSION=""
DISTRO=""
PKG_MANAGER=""

# Tool definitions using arrays instead of associative arrays
# Format: name|command|description|category|install_method|package_info
TOOLS_DATA=(
    "eza|eza|Modern replacement for ls with colors, icons, and Git integration|file|package|eza:eza:eza:eza:eza"
    "bat|bat|Cat clone with syntax highlighting and Git integration|file|package|bat:bat:bat:bat:bat"
    "ripgrep|rg|Blazingly fast grep alternative|file|package|ripgrep:ripgrep:ripgrep:ripgrep:ripgrep"
    "fd|fd|Simple, fast, and user-friendly alternative to find|file|package|fd:fd:fd-find:fd:fd"
    "dust|dust|Intuitive disk usage analyzer|file|cargo_or_package|du-dust:dust:du-dust:du-dust:dust"
    "tokei|tokei|Fast code statistics tool|file|cargo_or_package|tokei:tokei:tokei:tokei:tokei"
    "xh|xh|Friendly and fast HTTP client (curl alternative)|file|cargo|xh"
    "hexyl|hexyl|Colorful hex viewer|file|package|hexyl:hexyl:hexyl:hexyl:hexyl"
    "broot|broot|Interactive tree-view file explorer with fuzzy search|file|cargo_or_package|broot:broot:broot:broot:broot"
    "yazi|yazi|Blazing fast terminal file manager|file|cargo_or_package|yazi:yazi:yazi:yazi:yazi"
    "procs|procs|Modern replacement for ps with colored output|monitor|cargo|procs"
    "bottom|btm|Graphical system monitor (htop alternative)|monitor|package|bottom:bottom:bottom:bottom:bottom"
    "gping|gping|Ping with graph visualization|monitor|cargo|gping"
    "bandwhich|bandwhich|Terminal bandwidth utilization tool|monitor|cargo|bandwhich"
    "zellij|zellij|Terminal workspace with panes and tabs (tmux alternative)|productivity|cargo_or_package|zellij:zellij:zellij:zellij:zellij"
    "zoxide|zoxide|Smarter cd command that learns your habits|productivity|package|zoxide:zoxide:zoxide:zoxide:zoxide"
    "starship|starship|Fast and customizable shell prompt|productivity|package|starship:starship:starship:starship:starship"
    "hyperfine|hyperfine|Command-line benchmarking tool|productivity|package|hyperfine:hyperfine:hyperfine:hyperfine:hyperfine"
    "tealdeer|tldr|Fast tldr client for simplified man pages|productivity|cargo|tealdeer"
    "gitui|gitui|Terminal UI for Git|productivity|cargo_or_package|gitui:gitui:gitui:gitui:gitui"
    "cargo-update|cargo-install-update|Update all cargo-installed packages|productivity|cargo|cargo-update"
    "cargo-edit|cargo-add|Add/remove dependencies from command line|productivity|cargo|cargo-edit"
)

# Selection state (will be a space-separated string of selected indices)
SELECTED_TOOLS=""

# Helper functions to parse tool data
get_tool_name() {
    echo "$1" | cut -d'|' -f1
}

get_tool_command() {
    echo "$1" | cut -d'|' -f2
}

get_tool_description() {
    echo "$1" | cut -d'|' -f3
}

get_tool_category() {
    echo "$1" | cut -d'|' -f4
}

get_tool_install_method() {
    echo "$1" | cut -d'|' -f5
}

get_tool_packages() {
    echo "$1" | cut -d'|' -f6
}

# Check if a tool index is selected
is_selected() {
    local index="$1"
    echo "$SELECTED_TOOLS" | grep -q " $index " && return 0
    return 1
}

# Toggle selection for a tool
toggle_selection() {
    local index="$1"
    if is_selected "$index"; then
        # Remove from selection
        SELECTED_TOOLS=$(echo "$SELECTED_TOOLS" | sed "s/ $index / /g")
    else
        # Add to selection
        SELECTED_TOOLS="${SELECTED_TOOLS}$index "
    fi
}

# Detect OS and Architecture
detect_os() {
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        ARCH=$(uname -m)
        
        # Detect Linux distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$NAME
            VERSION=$VERSION_ID
            
            # Detect package manager
            if command -v apt-get &> /dev/null; then
                PKG_MANAGER="apt"
            elif command -v dnf &> /dev/null; then
                PKG_MANAGER="dnf"
            elif command -v yum &> /dev/null; then
                PKG_MANAGER="yum"
            elif command -v pacman &> /dev/null; then
                PKG_MANAGER="pacman"
            elif command -v zypper &> /dev/null; then
                PKG_MANAGER="zypper"
            elif command -v apk &> /dev/null; then
                PKG_MANAGER="apk"
            fi
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        ARCH=$(uname -m)
        VERSION=$(sw_vers -productVersion)
        PKG_MANAGER="brew"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="Windows"
        ARCH=$(uname -m)
        if command -v choco &> /dev/null; then
            PKG_MANAGER="choco"
        elif command -v scoop &> /dev/null; then
            PKG_MANAGER="scoop"
        fi
    else
        OS="Unknown"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Display system information
show_system_info() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}           System Information${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}OS:${NC} $OS"
    echo -e "  ${BOLD}Architecture:${NC} $ARCH"
    [ -n "$DISTRO" ] && echo -e "  ${BOLD}Distribution:${NC} $DISTRO"
    echo -e "  ${BOLD}Version:${NC} $VERSION"
    echo -e "  ${BOLD}Package Manager:${NC} ${PKG_MANAGER:-Not detected}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
}

# Check and install Rust/Cargo if not present
check_rust() {
    if ! command_exists rustc || ! command_exists cargo; then
        echo ""
        log_warning "Rust/Cargo not found!"
        echo -e "${YELLOW}This installer requires Rust to install some tools.${NC}"
        echo ""
        read -p "Would you like to install Rust now? (y/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ "$OS" == "Windows" ]]; then
                log_info "Please install Rust from https://rustup.rs/"
                log_info "After installation, restart your terminal and run this script again."
                exit 1
            else
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
            fi
            
            if command_exists cargo; then
                log_success "Rust installed successfully"
            else
                log_error "Failed to install Rust. Please install manually from https://rustup.rs/"
                exit 1
            fi
        else
            log_warning "Some tools require Rust and won't be available for installation."
            echo ""
            read -p "Continue anyway? (y/n): " -n 1 -r
            echo ""
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
        fi
    else
        log_success "Rust is installed ($(rustc --version | cut -d' ' -f2))"
    fi
}

# Display tool selection menu
display_tool_menu() {
    # Only clear screen initially, not on every refresh
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}        ${BOLD}Rust CLI Tools Interactive Installer${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    show_system_info
    
    echo -e "${BOLD}Available Tools:${NC}"
    echo ""
    
    # File & Directory Navigation Tools
    echo -e "${MAGENTA}【 File & Directory Navigation Tools 】${NC}"
    local num=1
    for tool_data in "${TOOLS_DATA[@]}"; do
        local category=$(get_tool_category "$tool_data")
        if [ "$category" = "file" ]; then
            display_tool_line "$num" "$tool_data"
            ((num++))
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}【 System Monitoring Tools 】${NC}"
    for tool_data in "${TOOLS_DATA[@]}"; do
        local category=$(get_tool_category "$tool_data")
        if [ "$category" = "monitor" ]; then
            display_tool_line "$num" "$tool_data"
            ((num++))
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}【 Productivity & Workflow Tools 】${NC}"
    for tool_data in "${TOOLS_DATA[@]}"; do
        local category=$(get_tool_category "$tool_data")
        if [ "$category" = "productivity" ]; then
            display_tool_line "$num" "$tool_data"
            ((num++))
        fi
    done
    
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────${NC}"
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${BOLD}1-22${NC} - Toggle specific tool selection"
    echo -e "  ${BOLD}A${NC} - Select all tools"
    echo -e "  ${BOLD}N${NC} - Deselect all tools"
    echo -e "  ${BOLD}F${NC} - Select all File & Directory tools"
    echo -e "  ${BOLD}M${NC} - Select all System Monitoring tools"
    echo -e "  ${BOLD}P${NC} - Select all Productivity tools"
    echo -e "  ${BOLD}I${NC} - Install selected tools"
    echo -e "  ${BOLD}Q${NC} - Quit"
    echo -e "${CYAN}───────────────────────────────────────────────────────────${NC}"
    
    # Show selected count
    local selected_count=0
    for i in $SELECTED_TOOLS; do
        ((selected_count++))
    done
    echo -e "${BOLD}Selected: $selected_count tools${NC}"
}

# Display a single tool line in the menu
display_tool_line() {
    local num="$1"
    local tool_data="$2"
    local name=$(get_tool_name "$tool_data")
    local command=$(get_tool_command "$tool_data")
    local description=$(get_tool_description "$tool_data")
    
    local status=""
    if command_exists "$command"; then
        status="${GREEN}[Installed]${NC}"
    else
        status="${YELLOW}[Not Installed]${NC}"
    fi
    
    if is_selected "$num"; then
        echo -e "  ${GREEN}✓${NC} ${BOLD}$num.${NC} ${BOLD}$name${NC} - $description $status"
    else
        echo -e "    ${BOLD}$num.${NC} $name - $description $status"
    fi
}

# Select all tools in a category
select_category() {
    local category="$1"
    local num=1
    
    SELECTED_TOOLS=" "  # Reset with initial space
    
    for tool_data in "${TOOLS_DATA[@]}"; do
        local tool_category=$(get_tool_category "$tool_data")
        
        if [ "$category" = "all" ] || [ "$tool_category" = "$category" ]; then
            SELECTED_TOOLS="${SELECTED_TOOLS}$num "
        fi
        ((num++))
    done
}

# Deselect all tools
deselect_all() {
    SELECTED_TOOLS=" "
}

# Install package using appropriate package manager
install_package() {
    local package=$1
    local cargo_fallback=$2
    local brew_package=${3:-$package}
    local apt_package=${4:-$package}
    local dnf_package=${5:-$package}
    local pacman_package=${6:-$package}
    
    case "$PKG_MANAGER" in
        brew)
            log_info "Installing $package with Homebrew..."
            brew install "$brew_package"
            ;;
        apt)
            log_info "Installing $package with apt..."
            sudo apt-get update -qq && sudo apt-get install -y "$apt_package"
            ;;
        dnf)
            log_info "Installing $package with dnf..."
            sudo dnf install -y "$dnf_package"
            ;;
        yum)
            log_info "Installing $package with yum..."
            sudo yum install -y "$dnf_package"
            ;;
        pacman)
            log_info "Installing $package with pacman..."
            sudo pacman -S --noconfirm "$pacman_package"
            ;;
        zypper)
            log_info "Installing $package with zypper..."
            sudo zypper install -y "$package"
            ;;
        apk)
            log_info "Installing $package with apk..."
            sudo apk add "$package"
            ;;
        choco)
            log_info "Installing $package with Chocolatey..."
            choco install -y "$package"
            ;;
        scoop)
            log_info "Installing $package with Scoop..."
            scoop install "$package"
            ;;
        *)
            if [ "$cargo_fallback" = "true" ] && command_exists cargo; then
                log_info "Installing $package with cargo..."
                cargo install "$package"
            else
                log_warning "No package manager found. Please install $package manually."
                return 1
            fi
            ;;
    esac
}

# Install selected tools
install_selected_tools() {
    local selected_count=0
    for i in $SELECTED_TOOLS; do
        ((selected_count++))
    done
    
    if [ $selected_count -eq 0 ]; then
        log_warning "No tools selected for installation."
        return
    fi
    
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                ${BOLD}Installing Selected Tools${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local installed_count=0
    local failed_count=0
    
    for selected_index in $SELECTED_TOOLS; do
        local tool_data="${TOOLS_DATA[$((selected_index-1))]}"
        local name=$(get_tool_name "$tool_data")
        local command=$(get_tool_command "$tool_data")
        local install_method=$(get_tool_install_method "$tool_data")
        local packages=$(get_tool_packages "$tool_data")
        
        echo -n "Installing ${BOLD}$name${NC}... "
        
        if command_exists "$command"; then
            log_success "Already installed"
            ((installed_count++))
        else
            echo ""
            
            if [ "$install_method" = "cargo" ]; then
                if command_exists cargo; then
                    # For cargo-only packages, the package name is the full packages string
                    cargo install "$packages"
                else
                    log_error "Cargo not available. Skipping $name"
                    ((failed_count++))
                    continue
                fi
            else
                IFS=':' read -r pkg brew_pkg apt_pkg dnf_pkg pacman_pkg <<< "$packages"
                
                if [ "$install_method" = "package" ]; then
                    install_package "$pkg" "false" "$brew_pkg" "$apt_pkg" "$dnf_pkg" "$pacman_pkg"
                elif [ "$install_method" = "cargo_or_package" ]; then
                    install_package "$pkg" "true" "$brew_pkg" "$apt_pkg" "$dnf_pkg" "$pacman_pkg"
                fi
            fi
            
            if command_exists "$command"; then
                log_success "$name installed successfully"
                ((installed_count++))
            else
                log_error "Failed to install $name"
                ((failed_count++))
            fi
        fi
    done
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "  Successfully installed/verified: ${GREEN}$installed_count${NC} tools"
    [ $failed_count -gt 0 ] && echo -e "  Failed: ${RED}$failed_count${NC} tools"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    
    # Show post-installation instructions
    show_post_install_instructions
}

# Show post-installation instructions
show_post_install_instructions() {
    echo ""
    echo -e "${BOLD}Post-Installation Setup:${NC}"
    echo ""
    
    local has_starship=false
    local has_zoxide=false
    local has_broot=false
    
    for selected_index in $SELECTED_TOOLS; do
        local tool_data="${TOOLS_DATA[$((selected_index-1))]}"
        local name=$(get_tool_name "$tool_data")
        
        [ "$name" = "starship" ] && has_starship=true
        [ "$name" = "zoxide" ] && has_zoxide=true
        [ "$name" = "broot" ] && has_broot=true
    done
    
    if [ "$has_starship" = true ] && command_exists starship; then
        echo -e "${YELLOW}Starship Shell Prompt:${NC}"
        echo "  Add to your shell config:"
        echo "    Bash (~/.bashrc): eval \"\$(starship init bash)\""
        echo "    Zsh (~/.zshrc): eval \"\$(starship init zsh)\""
        echo "    Fish (~/.config/fish/config.fish): starship init fish | source"
        echo ""
    fi
    
    if [ "$has_zoxide" = true ] && command_exists zoxide; then
        echo -e "${YELLOW}Zoxide (Smart cd):${NC}"
        echo "  Add to your shell config:"
        echo "    Bash: eval \"\$(zoxide init bash)\""
        echo "    Zsh: eval \"\$(zoxide init zsh)\""
        echo "    Fish: zoxide init fish | source"
        echo ""
    fi
    
    if [ "$has_broot" = true ] && command_exists broot; then
        echo -e "${YELLOW}Broot File Explorer:${NC}"
        echo "  Run: broot --install"
        echo ""
    fi
    
    # Check if cargo bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
        echo -e "${YELLOW}PATH Configuration:${NC}"
        echo "  Add to your shell config:"
        echo "    export PATH=\"\$HOME/.cargo/bin:\$PATH\""
        echo ""
    fi
}

# Create optional aliases file
create_aliases_file() {
    echo ""
    read -p "Would you like to create an aliases file for the installed tools? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        {
            echo "# Rust CLI Tools Aliases"
            echo "# Source this file in your shell config: source ~/.rust_cli_aliases"
            echo ""
            
            for selected_index in $SELECTED_TOOLS; do
                local tool_data="${TOOLS_DATA[$((selected_index-1))]}"
                local name=$(get_tool_name "$tool_data")
                local command=$(get_tool_command "$tool_data")
                
                if command_exists "$command"; then
                    case "$name" in
                        eza)
                            echo "# File listings"
                            echo "alias ls='eza'"
                            echo "alias ll='eza -l'"
                            echo "alias la='eza -la'"
                            echo "alias lt='eza --tree'"
                            echo ""
                            ;;
                        bat)
                            echo "# File viewing"
                            echo "alias cat='bat'"
                            echo ""
                            ;;
                        ripgrep)
                            echo "# Searching"
                            echo "alias grep='rg'"
                            echo ""
                            ;;
                        fd)
                            echo "# Finding files"
                            echo "alias find='fd'"
                            echo ""
                            ;;
                        dust)
                            echo "# Disk usage"
                            echo "alias du='dust'"
                            echo ""
                            ;;
                        procs)
                            echo "# Process monitoring"
                            echo "alias ps='procs'"
                            echo ""
                            ;;
                        bottom)
                            echo "# System monitoring"
                            echo "alias top='btm'"
                            echo "alias htop='btm'"
                            echo ""
                            ;;
                        gping)
                            echo "# Network tools"
                            echo "alias ping='gping'"
                            echo ""
                            ;;
                        xh)
                            echo "# HTTP requests"
                            echo "alias curl='xh'"
                            echo ""
                            ;;
                        hexyl)
                            echo "# Hex viewer"
                            echo "alias xxd='hexyl'"
                            echo ""
                            ;;
                        tealdeer)
                            echo "# Documentation"
                            echo "alias help='tldr'"
                            echo "alias man='tldr'"
                            echo ""
                            ;;
                        gitui)
                            echo "# Git"
                            echo "alias gits='gitui'"
                            echo ""
                            ;;
                    esac
                fi
            done
        } > "$HOME/.rust_cli_aliases"
        
        log_success "Aliases file created at ~/.rust_cli_aliases"
        echo "Add 'source ~/.rust_cli_aliases' to your shell config to use these aliases"
    fi
}

# Main interactive loop
interactive_menu() {
    # Initialize with no selections
    SELECTED_TOOLS=" "
    
    while true; do
        clear
        display_tool_menu
        
        echo ""
        echo -n "Enter your choice: "
        read -r choice
        
        # Debug output (remove this line after testing)
        # echo "Debug: You entered '$choice'"
        
        case "$choice" in
            [1-9])
                toggle_selection "$choice"
                ;;
            1[0-9]|2[0-2])
                toggle_selection "$choice"
                ;;
            [Aa]|a|A)
                select_category "all"
                ;;
            [Nn]|n|N)
                deselect_all
                ;;
            [Ff]|f|F)
                select_category "file"
                ;;
            [Mm]|m|M)
                select_category "monitor"
                ;;
            [Pp]|p|P)
                select_category "productivity"
                ;;
            [Ii]|i|I)
                install_selected_tools
                echo ""
                echo "Press Enter to continue..."
                read -r
                ;;
            [Qq]|q|Q)
                echo ""
                log_info "Exiting installer..."
                exit 0
                ;;
            "")
                # Handle empty input
                continue
                ;;
            *)
                echo ""
                log_error "Invalid choice: '$choice'. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Main function
main() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}Rust CLI Tools Interactive Installer${NC}                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     ${BOLD}Transform Your Terminal Experience${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    # Detect OS
    detect_os
    
    # Show system info
    show_system_info
    
    # Check for Rust/Cargo
    check_rust
    
    echo ""
    log_info "Starting interactive tool selection..."
    sleep 1
    
    # Start interactive menu
    interactive_menu
}

# Trap Ctrl+C to exit gracefully
trap 'echo ""; log_info "Installation cancelled by user"; exit 1' INT

# Run the main function
main "$@"