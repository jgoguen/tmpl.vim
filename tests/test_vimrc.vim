filetype off
let s:tmplvim_dir = expand('%:p:h:h')
let s:vader_dir = printf('%s/../vader.vim', s:tmplvim_dir)
let &runtimepath = s:tmplvim_dir.','.&runtimepath
if isdirectory(s:vader_dir)
	let &runtimepath .= ','.s:vader_dir
endif
filetype plugin indent on
syntax enable
set nomore
set noswapfile
set viminfo=
