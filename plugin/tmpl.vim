" vim: set syntax=vim filetype=vim noexpandtab ts=2 sts=2 sw=2 autoindent:
" vim: set foldmarker=[[[,]]] foldmethod=marker foldlevel=0:

autocmd BufNewFile * silent call tmpl#LoadTemplateFile()

command! -complete=customlist,tmpl#TemplateCommandCompletion -nargs=+ LoadTemplateFile call tmpl#LoadTemplateFile(<f-args>)
