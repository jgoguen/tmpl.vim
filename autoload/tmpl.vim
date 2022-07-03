" vim: set syntax=vim filetype=vim noexpandtab ts=2 sts=2 sw=2 autoindent:
" vim: set foldmarker=[[[,]]] foldmethod=marker foldlevel=0:

let s:tmplVarTag = '<# *\([A-Z]\+\) *#>'
let s:tmplIncludeTag = '<\$ *\([A-Za-z0-9\.]\+\) *\$>'
let s:specialChars = '^[]\:*$'

function! tmpl#LoadTemplateFile(...) abort
	let template_environment = ''
	let template_format = ''

	if a:0 >= 2
		" Both format and environment are given
		let template_format = a:1
		let template_environment = a:2
	elseif a:0 == 1
		" Got format but not environment
		let template_format = a:1
	endif

	if template_environment ==? ''
		let template_environment = get(b:, 'tmplvim_default_environment', get(g:, 'tmplvim_default_environment', 'default'))
	endif

	if template_format ==? ''
	" Either a file extension or a file basename is needed to create the
	" template path.
	" - script.sh -> default.sh
	" - Makefile -> default.makefile
	" - project.py -> default.py
		let file_extension = tolower(expand('%:e'))
		if len(file_extension) == 0
			let file_name = tolower(expand('%:t'))
			if len(file_name) == 0
				throw 'Cannot load template, need file extension or name'
			else
				let template_format = file_name
			endif
		else
			let template_format = file_extension
		endif
	endif

	let template_name = printf('%s.%s', template_environment, template_format)

	let templates = <SID>templates_for_glob(template_name)
	if empty(templates)
		return 0
	endif

	execute printf('silent! 0r%s', templates[0])
	call tmpl#ExpandIncludeVars()
	call tmpl#ExpandTmplVars()
	set nomodified
endfunction

function! tmpl#TemplateCommandCompletion(arglead, cmdline, cursorpos) abort
	" Why use a dictionary? So we don't repeat values! Given there can be multiple
	" environments it's likely there will be repeat types, and since there's
	" multiple environments, well, there's repeat environments.
	let resultset = {}
	let templates = <SID>templates_for_glob('*')
	let num_args = len(split(a:cmdline, ' '))

	for tmpl_file in templates
		if num_args == 1
			" Format first
			let resultset[fnamemodify(tmpl_file, ':e')] = 1
		elseif num_args == 2
			" Environment second
			let resultset[fnamemodify(tmpl_file, ':t:r')] = 1
		endif
	endfor

	return keys(resultset)
endfunction

function! s:templates_for_glob(glob) abort
	let templates = filter(split(globpath(&runtimepath, printf('templates/%s', a:glob)), "\n"), 'filereadable(v:val)')
	if empty(templates)
		return []
	endif

	return templates
endfunction

function! tmpl#ExpandTmplVars() abort
	let old_winstate = winsaveview()
	let old_query = getreg('/')

	let [matchline, matchcol] = searchpos(s:tmplVarTag)
	let template_vars = get(g:, 'tmplvim_template_vars', {'KEY': 'MYKEY'})
	while matchline != 0
		let matches = matchlist(getline(matchline), printf('^%s', s:tmplVarTag), matchcol-1)
		if len(matches) > 0
			let key = matches[1]
			let value = ''

			if key ==# 'DATE'
				let value = strftime('%Y-%m-%d')
			elseif key ==# 'YEAR'
				let value = strftime('%Y')
			elseif key ==# 'TIME'
				let value = strftime('%H:%M:%S')
			elseif key ==# 'AUTHOR'
				let value = get(g:, 'tmplvim_author', expand($USER))
			elseif key ==# 'DIRNAME'
				let value = expand('%:p:h:t')
			elseif key ==# 'BASENAME'
				let value = expand('%:t:r')
			elseif key ==# 'UPPERBASENAME'
				let value = toupper(expand('%:t:r'))
			elseif index(keys(template_vars), key) != -1
				let value = template_vars[matches[1]]
			endif

			execute printf('silent %ds/^.\{%d\}\zs%s/%s/g', matchline, (matchcol-1), escape(matches[0], s:specialChars), expand(value, s:specialChars))
		endif

		let [matchline, matchcol] = searchpos(s:tmplVarTag)
	endwhile

	call setreg('/', old_query)
	call winrestview(old_winstate)
endfunction

function! tmpl#ExpandIncludeVars()
	let old_winstate = winsaveview()
	let old_query = getreg('/')
	let format = expand('%:e')

	let [matchline, matchcol] = searchpos(s:tmplIncludeTag)
	while matchline != 0
		let matches = matchlist(getline(matchline), printf('^%s', s:tmplIncludeTag), matchcol-1)
		if len(matches) > 0
			let templates = <SID>templates_for_glob(matches[1])
			if !empty(templates)
				let tmpl_file = templates[0]
				if filereadable(printf('%s.%s', tmpl_file, format))
					let tmpl_file = printf('%s.%s', tmpl_file, format)
				endif
				execute printf('silent! %ds/^.\{%d\}\zs%s//', matchline, (matchcol-1), escape(matches[0], s:specialChars))
				execute printf('silent! %dr%s', matchline-1, tmpl_file)
			endif
		endif

		let [matchline, matchcol] = searchpos(s:tmplIncludeTag)
	endwhile

	call setreg('/', old_query)
	call winrestview(old_winstate)
endfunction
