#!/usr/bin/sh

set -ev

mkdir -p ~/venvs

echo "Installing cmake language server..."
python3 -m venv --clear ~/venvs/cmake_lsp/
~/venvs/cmake_lsp/bin/python -m pip install cmake_language_server cmakelang

echo "Installing esbonio..."
python3 -m venv --clear ~/venvs/esbonio/
~/venvs/esbonio/bin/python -m pip install esbonio

echo "Installing pylsp..."
python3 -m venv --clear ~/venvs/pylsp/
~/venvs/pylsp/bin/python -m pip install "python-lsp-server[all]" pylsp-mypy python-lsp-black pyright
