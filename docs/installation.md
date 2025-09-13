---
layout: default
title: Installation and Setup
description: Complete installation guide for PGN Parser on all platforms
---

# Installation and Setup

## System Requirements

### Minimum Requirements
- **OCaml**: version 4.14 or higher
- **OPAM**: OCaml package manager
- **Dune**: build system (version 3.0 or higher)

### Recommended Requirements
- **OCaml**: version 5.0 or higher
- **OPAM**: latest stable version
- **Dune**: version 3.19 or higher

## Installing OCaml and OPAM

### macOS

#### Using Homebrew (recommended)
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install OPAM
brew install opam

# Initialize OPAM
opam init
eval $(opam env)

# Install OCaml
opam switch create 4.14 ocaml.4.14.0
opam switch 4.14
```

#### Using MacPorts
```bash
# Install OPAM
sudo port install opam

# Initialize OPAM
opam init
eval $(opam env)

# Install OCaml
opam switch create 4.14 ocaml.4.14.0
opam switch 4.14
```

### Ubuntu/Debian

```bash
# Add OPAM repository
sudo add-apt-repository ppa:avsm/ppa
sudo apt-get update

# Install OPAM
sudo apt-get install opam

# Initialize OPAM
opam init --disable-sandboxing
eval $(opam env)

# Install OCaml
opam switch create 4.14 ocaml.4.14.0
opam switch 4.14
```

### CentOS/RHEL/Fedora

```bash
# Install dependencies
sudo dnf install gcc make git

# Install OPAM from source
wget https://github.com/ocaml/opam/releases/download/2.1.5/opam-2.1.5-x86_64-linux
sudo mv opam-2.1.5-x86_64-linux /usr/local/bin/opam
sudo chmod +x /usr/local/bin/opam

# Initialize OPAM
opam init --disable-sandboxing
eval $(opam env)

# Install OCaml
opam switch create 4.14 ocaml.4.14.0
opam switch 4.14
```

### Windows

#### Using WSL2 (recommended)
```bash
# In WSL2 Ubuntu
sudo add-apt-repository ppa:avsm/ppa
sudo apt-get update
sudo apt-get install opam

opam init --disable-sandboxing
eval $(opam env)

opam switch create 4.14 ocaml.4.14.0
opam switch 4.14
```

#### Using OCaml for Windows
1. Download installer from [ocaml.org](https://ocaml.org/learn/install.html#Windows)
2. Run installer and follow instructions
3. Install OPAM through installer

## Installing PGN Parser

### Cloning Repository

```bash
# Clone repository
git clone https://github.com/Ckaf/pgn_parser.git
cd pgn_parser
```

### Installing Dependencies

```bash
# Update OPAM
opam update

# Install project dependencies
opam install . --deps-only --with-test --with-doc
```

### Building Project

```bash
# Build project
dune build

# Build with optimization
dune build --profile release
```

## Verifying Installation

### Running Tests

```bash
# Run all tests
dune runtest

# Run specific tests
dune exec test/test_pgn_parser        # Property-based tests
dune exec test/test_zobrist           # Zobrist hash tests
dune exec test/test_advanced_moves    # Advanced moves
dune exec test/test_unfinished_games  # Unfinished games
```

### Running Examples

```bash
# Basic PGN parsing
dune exec examples/simple_demo

# Board visualization
dune exec examples/board_demo

# Zobrist hashing
dune exec examples/zobrist_demo

# Lichess API
dune exec examples/lichess_demo

# Chess.com API
dune exec examples/chess_com_demo

# PGN parsing
dune exec examples/pgn_demo
```

## Installing via OPAM

### Installing from OPAM Repository

```bash
# Install main package
opam install pgn_parser

# Install Lichess API client
opam install lichess_api

# Install Chess.com API client
opam install chess_com_api
```

### Using in Project

Create a `dune-project` file in your project:

```dune
(lang dune 3.19)
(name your_project)
(package
 (name your_project)
 (depends
  (pgn_parser)
  (lichess_api)
  (chess_com_api)))
```

## IDE Setup

### Visual Studio Code

1. Install "OCaml Platform" extension
2. Install "OCaml and Reason IDE" extension
3. Configure OCaml path:

```json
{
  "ocaml.sandbox": {
    "kind": "opam",
    "switch": "4.14"
  }
}
```

### Emacs

1. Install `tuareg-mode`:
```bash
opam install tuareg
```

2. Add to `.emacs`:
```elisp
(require 'tuareg)
(setq auto-mode-alist
      (append '(("\\.ml\\'" . tuareg-mode)
                ("\\.mli\\'" . tuareg-mode))
              auto-mode-alist))
```

### Vim/Neovim

1. Install `ocaml-vim`:
```bash
opam install ocaml-vim
```

2. Add to `.vimrc`:
```vim
set runtimepath^=~/.opam/4.14/share/ocaml-vim
```

## Troubleshooting

### OPAM Issues

#### Error "opam: command not found"
```bash
# Add OPAM to PATH
echo 'eval $(opam env)' >> ~/.bashrc
source ~/.bashrc
```

#### Sandboxing Issues
```bash
# Disable sandboxing
opam init --disable-sandboxing
```

#### Package Installation Errors
```bash
# Clear OPAM cache
opam clean --all
opam update
```

### Dune Issues

#### Error "dune: command not found"
```bash
# Install Dune
opam install dune
```

#### Build Errors
```bash
# Clear build cache
dune clean
dune build
```

### Dependency Issues

#### Version Conflicts
```bash
# Create new switch for project
opam switch create pgn_parser ocaml.4.14.0
opam switch pgn_parser
opam install . --deps-only --with-test --with-doc
```

#### Network Issues
```bash
# Use OPAM mirrors
opam repository add default https://opam.ocaml.org
opam update
```

## Development

### Setting Up Development Environment

```bash
# Clone repository
git clone https://github.com/Ckaf/pgn_parser.git
cd pgn_parser

# Create development switch
opam switch create dev ocaml.4.14.0
opam switch dev

# Install development dependencies
opam install . --deps-only --with-test --with-doc --with-dev-setup

# Install development tools
opam install ocamlformat ocp-indent merlin
```

### Code Formatting

```bash
# Automatic formatting
dune build @fmt --auto-promote

# Check formatting
dune build @fmt
```

### Linting

```bash
# Check code
dune build @check

# Check warnings
dune build --profile dev
```

## Performance

### Optimized Build

```bash
# Build with optimization
dune build --profile release

# Build with debug information
dune build --profile dev
```

### Profiling

```bash
# Install profiling tools
opam install ocaml-migrate-parsetree ppx_profiling

# Build with profiling
dune build --profile profiling
```

## Docker

### Using Docker for Development

Create `Dockerfile`:

```dockerfile
FROM ocaml/opam:ubuntu-22.04-ocaml-4.14

# Install dependencies
RUN sudo apt-get update && sudo apt-get install -y git

# Clone and build project
WORKDIR /workspace
COPY . .
RUN opam install . --deps-only --with-test --with-doc
RUN dune build

# Run tests
CMD ["dune", "runtest"]
```

Build and run:

```bash
# Build image
docker build -t pgn_parser .

# Run tests
docker run pgn_parser
```

## CI/CD

### GitHub Actions

The project is already configured with GitHub Actions workflows:

- `ci.yml` - main CI/CD pipeline
- `docs.yml` - documentation deployment to GitHub Pages
- `compatibility.yml` - compatibility tests
- `performance.yml` - performance tests

### Local CI Testing

```bash
# Install act for local GitHub Actions testing
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run local tests
act -j test
```