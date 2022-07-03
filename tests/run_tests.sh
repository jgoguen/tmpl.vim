#!/bin/sh
# vim: set filetype=sh noexpandtab ts=2 sts=2 sw=2 foldmethod=marker:
# vim: set foldmarker=[[[,]]]:

set -e

cd "$(dirname "${0}")"

${VIM_BIN:-nvim} -Nu test_vimrc.vim -c 'Vader! *'
