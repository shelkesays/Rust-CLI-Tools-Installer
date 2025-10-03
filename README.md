# Rust CLI Tools Interactive Installer

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Compatibility](https://img.shields.io/badge/compatible-Linux%20|%20macOS%20|%20Windows-brightgreen.svg)](#compatibility)

> Transform your terminal experience with modern Rust-powered CLI tools

An interactive shell script that simplifies the installation and management of powerful Rust CLI tools across different operating systems and package managers. Say goodbye to tedious manual installations and hello to a supercharged terminal workflow!

## 🚀 Features

- **Interactive Selection**: Choose exactly which tools you want to install
- **Cross-Platform Support**: Works on Linux, macOS, and Windows
- **Smart Package Manager Detection**: Automatically detects and uses your system's package manager
- **Rust Auto-Installation**: Automatically installs Rust/Cargo if needed
- **Category Organization**: Tools grouped by File Navigation, System Monitoring, and Productivity
- **Installation Status**: Shows which tools are already installed
- **Post-Install Setup**: Provides shell configuration instructions
- **Alias Generation**: Optionally creates convenient aliases for installed tools

## 📦 Included Tools

### 🗂️ File & Directory Navigation Tools

| Tool | Command | Description |
|------|---------|-------------|
| **eza** | `eza` | Modern replacement for `ls` with colors, icons, and Git integration |
| **bat** | `bat` | Cat clone with syntax highlighting and Git integration |
| **ripgrep** | `rg` | Blazingly fast grep alternative |
| **fd** | `fd` | Simple, fast, and user-friendly alternative to find |
| **dust** | `dust` | Intuitive disk usage analyzer |
| **tokei** | `tokei` | Fast code statistics tool |
| **xh** | `xh` | Friendly and fast HTTP client (curl alternative) |
| **hexyl** | `hexyl` | Colorful hex viewer |
| **broot** | `broot` | Interactive tree-view file explorer with fuzzy search |
| **yazi** | `yazi` | Blazing fast terminal file manager |

### 📊 System Monitoring Tools

| Tool | Command | Description |
|------|---------|-------------|
| **procs** | `procs` | Modern replacement for ps with colored output |
| **bottom** | `btm` | Graphical system monitor (htop alternative) |
| **gping** | `gping` | Ping with graph visualization |
| **bandwhich** | `bandwhich` | Terminal bandwidth utilization tool |

### ⚡ Productivity & Workflow Tools

| Tool | Command | Description |
|------|---------|-------------|
| **zellij** | `zellij` | Terminal workspace with panes and tabs (tmux alternative) |
| **zoxide** | `zoxide` | Smarter cd command that learns your habits |
| **starship** | `starship` | Fast and customizable shell prompt |
| **hyperfine** | `hyperfine` | Command-line benchmarking tool |
| **tealdeer** | `tldr` | Fast tldr client for simplified man pages |
| **gitui** | `gitui` | Terminal UI for Git |
| **cargo-update** | `cargo-install-update` | Update all cargo-installed packages |
| **cargo-edit** | `cargo-add` | Add/remove dependencies from command line |

## 🛠️ Installation

### Quick Start

```bash
# Download and run the installer
curl -sSL https://raw.githubusercontent.com/shelkesays/Rust-CLI-Tools-Installer/main/install_rust_tools.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/shelkesays/Rust-CLI-Tools-Installer.git
cd Rust-CLI-Tools-Installer

# Make the script executable
chmod +x install_rust_tools.sh

# Run the installer
./install_rust_tools.sh
```

## 🎮 Usage

The installer provides an interactive menu with the following options:

- **1-22**: Toggle individual tool selection
- **A**: Select all tools
- **N**: Deselect all tools  
- **F**: Select all File & Directory tools
- **M**: Select all System Monitoring tools
- **P**: Select all Productivity tools
- **I**: Install selected tools
- **Q**: Quit

### Example Workflow

1. Run the script: `./install_rust_tools.sh`
2. Review system information and available tools
3. Select tools by entering their numbers (e.g., `1`, `5`, `12`)
4. Press `I` to install selected tools
5. Follow post-installation instructions for shell configuration

## 🖥️ Compatibility

### Operating Systems
- **Linux**: Ubuntu, Debian, Fedora, CentOS, Arch, openSUSE, Alpine
- **macOS**: All versions with Homebrew support
- **Windows**: With Git Bash, WSL, or Cygwin

### Package Managers
- **Linux**: apt, dnf, yum, pacman, zypper, apk
- **macOS**: Homebrew
- **Windows**: Chocolatey, Scoop
- **Fallback**: Cargo (Rust package manager)

### Shell Compatibility
- Bash 3.x+
- Zsh
- Fish (with bash compatibility)
- POSIX-compliant shells

## ⚙️ Configuration

### Post-Installation Setup

The installer provides setup instructions for optimal tool usage:

#### Shell Prompt (Starship)
```bash
# Add to ~/.bashrc or ~/.zshrc
eval "$(starship init bash)"  # For Bash
eval "$(starship init zsh)"   # For Zsh
```

#### Smart Directory Navigation (Zoxide)
```bash
# Add to shell config
eval "$(zoxide init bash)"  # For Bash
eval "$(zoxide init zsh)"   # For Zsh
```

#### File Explorer (Broot)
```bash
# Run after installation
broot --install
```

### Generated Aliases

The installer can create convenient aliases in `~/.rust_cli_aliases`:

```bash
# File operations
alias ls='eza'
alias cat='bat'
alias grep='rg'
alias find='fd'

# System monitoring
alias top='btm'
alias ps='procs'

# Add to shell config
source ~/.rust_cli_aliases
```

## 🔧 Advanced Usage

### Environment Variables

- `CARGO_HOME`: Custom Cargo installation directory
- `PATH`: Ensure `~/.cargo/bin` is in your PATH

### Custom Installation

```bash
# Install specific tools only
./install_rust_tools.sh
# Then select only the tools you need

# Check installation status
which eza bat rg fd  # Check if tools are available
```

## 🚨 Troubleshooting

### Common Issues

**Rust not found**
```bash
# The installer will offer to install Rust automatically
# Or install manually:
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Package manager not detected**
- Ensure your package manager is installed and in PATH
- The installer will fall back to Cargo for most tools

**Permission denied**
```bash
chmod +x install_rust_tools.sh
```

**PATH issues**
```bash
# Add to your shell config
export PATH="$HOME/.cargo/bin:$PATH"
```

### Debug Mode

To see detailed installation logs, check the terminal output during installation.

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Add new tools**: Edit the `TOOLS_DATA` array in the script
2. **Improve compatibility**: Test on different systems
3. **Enhance features**: Add new installation options
4. **Fix bugs**: Report issues and submit fixes

### Tool Data Format
```bash
"name|command|description|category|install_method|package_info"
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the article: [Your Terminal is Boring, Let's Fix It with These Rust CLI Tools](https://medium.com/@Smyekh/your-terminal-is-boring-lets-fix-it-with-these-rust-cli-tools-03069693a2d1)
- Thanks to all the Rust CLI tool developers for creating amazing software
- The Rust community for fostering innovation in command-line tools

## 📚 Related Resources

- [The Rust Programming Language](https://www.rust-lang.org/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Awesome Rust CLI](https://github.com/rust-unofficial/awesome-rust#command-line)

---

**Transform your terminal today!** 🚀
