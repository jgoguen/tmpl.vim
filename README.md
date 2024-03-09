# tmpl.vim

`tmpl.vim` provides autoloading new file templates for vim and Neovim. Templates
are kept in any `templates` directory on the `runtimepath`, allowing you to
easily add your own templates separately from this plugin. By setting
`g:tmplvim_default_environment`, different templates for the same file type may
be loaded in different environments (e.g. work versus personal).

Template names are constructed as `environment.type`. The environment may be set
using `g:tmplvim_default_environment`, which defaults to `default`. For file
names with an extension the file extension is taken as the template type, or for
files with no extension the lower-case name of the file is used as the template
type.

## Installation

It is recommended to use a plugin manager to install `tmpl.vim`.

### With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'jgoguen/tmpl.vim'
```

### With [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('jgoguen/tmpl.vim')
```

### With [minpac](https://github.com/k-takata/minpac)

```vim
call minpac#add('jgoguen/tmpl.vim')
```

### With vim 8 plugins

Clone the repository to `pack/plugins/start`:

For vim 8:
```sh
mkdir -p ~/.vim/pack/plugins/start
git clone https:/github.com/jgoguen/tmpl.vim.git ~/.vim/pack/plugins/start/tmpl.vim
```

For Neovim:
```sh
mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/pack/plugins/start"
git clone https://github.com/jgoguen/tmpl.vim.git "${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/pack/plugins/start"
```

## Configuration

To set the template environment, set `g:tmplvim_default_environment`. To
override the template environment on a per-buffer basis, set
`b:tmplvim_default_environment` for the specific buffers. If this is not given,
the default value is `default`.

To set the replacement value for the `<# AUTHOR #>` tag, set `g:tmplvim_author`.
If this is not given, the default value is the `${USER}` environment variable.

To set the replacement value for arbitrary template tags, use the dictionary
`g:tmplvim_template_vars`. Set the tag name as the dictionary key and the value
as the tag replacement value.

## Template tags

Templates may contain tags which will be automatically expanded when the
template is loaded into the buffer. There are two types of tags:

1. Template variables
2. Template includes

Template includes are processed first, then variables once includes have been
inserted into the buffer. Nested includes are not currently supported.

### Template variables

Template variable tags are upper-case letters surrounded by `<#` and `#>`. The
value of a template variable comes from `g:tmplvim_template_vars`, except for
some specific reserved tag names:

1. `DATE`: Always replaced with the value of `strftime('%Y-%m-%d')` (e.g.
   `2020-03-04`)
2. `YEAR`: Always replaced with the value of `strftime('%Y')` (e.g. `2020`)
3. `TIME`: Always replaced with the value of `strftime('%H:%M:%S')` (e.g.
   `13:03:34`)
4. `AUTHOR`: Always replaced with the value of `g:tmplvim_author`, or the value
   of `$USER` if that is not set.
5. `DIRNAME`: Always replaced with the name of the directory the file is in.
6. `BASENAME`: Always replaced with the name of the file without extensions.
7. `UPPERBASENAME`: Always replaced with the name of the file without extensions
	 in upper-case.

### Template includes

Template include tags are letters, numbers, or periods surrounded by `<$` and
`$>`. The tag name is expected to be the name of another template, which may
include template variables but may not include other template includes. For
example, the include tag `<$ LICENSE.MIT $>` will be replaced with the contents
of the template file named `LICENSE.MIT`.

To accommodate including files in source code templates, an include with the
same extension as the current buffer will be searched for and preferred if
found. For example, the include tag `<$ LICENSE.MIT $>` in `setup.py` would use
the template named `LICENSE.MIT.py` if it exists, or `LICENSE.MIT` if not.

## Usage

When a new file is opened, the corresponding template is automatically loaded.
