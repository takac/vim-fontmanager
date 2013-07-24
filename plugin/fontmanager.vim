" Author: Tom Cammann 
"
" Cycle through common fonts
" different fonts for different syntaxs
" IN VIMRC =
"
" let g:fontman_font = "Ubuntu Mono derivative Powerline"
" let g:fontman_size = 13
" let g:fontman_syntax_map = { "java" : "Consolas", "txt" : "Fixedsys" }
"
"let g:fonts = ["Inconsolata", "Ubuntu Mono", "Consolas", "Terminal"]

let g:default_size = 13

let s:current_dir = expand("<sfile>:p:h")
let s:font_file = s:current_dir . "\\fonts.txt"

function! SetFontAndStyle(name, style, size)
	exec "set guifont=". FormatFont(a:name, a:style, a:size)
endfunction

function! SetFont(name, size)
    if a:name =~? "\\<bold\\>.*\\<italic\\>" || a:name =~? "\\<italic\\>.*\\<bold\\>"
        exec "set guifont=". FormatFont(a:name, "bi", a:size)
    elseif a:name =~? "\\<bold\\>"
        exec "set guifont=". FormatFont(a:name, "b", a:size)
    elseif a:name =~? "\\<italic\\>"
        exec "set guifont=". FormatFont(a:name, "i", a:size)
    else
        exec "set guifont=". FormatFont(a:name, "", a:size)
    endif
endfunction

" Formats:
"    Unix: font\ name:hSIZE:format
"    Mac: font\ name:hSIZE:format
"    Windows: font_name\ SIZE

function! CheckFont(name)
    let current = &guifont
    let check = FormatFont(a:name,"", 12)
	let t_list = [ check ]
	call writefile(t_list, expand("~") . "/tmp-font.txt", "")
    try
		exec "set guifont=" . check
    catch /Invalid.*/
    endtry
    " echom check . " == " . &guifont
    if &guifont == check
        let &guifont = current
        return 1
    else
        let &guifont = current
        return 0
    endif
endfunction

" can be negative
function! IncreaseFontSize(n)
    call SetFont(GetCurrentFont(), GetCurrentFontSize() + a:n)
endfunction
function! SetFontSize(n)
    call SetFont(GetCurrentFont(), a:n)
endfunction


function! GetCurrentFontSize()
    let font = &guifont

    if font == ""
        " Not set!
        return 12
    elseif has("gui_macvim")
        " dostuff ..
        " split(":")
    elseif has("gui_gtk2")
        " dostuff ..
        " split(":")
    elseif has("gui_win32") || has("gui_win64")
        if font =~? ":h\\d\\+"
			let size = matchstr(font, ":h\\zs\\d\\+") 
			echo size
            return size
        else
			" If size has been removed from guifont for some reason...
            return g:default_size
        endif
        return name
    else
        " OH NO Console!
    endif
endfunction

function! SetBoldFont(name, size)
    exec "set guifont=". FormatFont(a:name, "b", a:size)
endfunction

    
function! GetCurrentFont()
    let font = &guifont

    if font == ""
        " Not set! Probably a console
        return ""
    elseif has("gui_macvim")
        " dostuff ..
        " split(":")
    elseif has("gui_gtk2")
        " dostuff ..
        " split(":")
    elseif has("gui_win32") || has("gui_win64")
        let name = split(font, ":")[0]
        let name = substitute(name, "_", " ", "g")
        return name
    else
        " OH NO Console!
    endif
endfunction

function! FormatFont(name, style, size)
    if has("gui_macvim")
        let name = substitute(a:name, " ", "\\ ", "g")
        return name . ":h" . a:size
    elseif has("gui_gtk2")
        let name = substitute(a:name, " ", "\\ ", "g")
        return name . "\\ " . a:size
    elseif has("gui_win32") || has("gui_win64")
        let name = substitute(a:name, " ", "_", "g")[:30]
        return name . ":" . a:style . ":h" . a:size
    else
        " OH NO Console!
    endif
endfunction

function! WindowsReadFonts()
    let tmp_file = expand("$TMP") . '\out.txt'
    exec 'silent !regedit /e ' . tmp_file . ' "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"'
    let fonts = []
    for line in readfile(tmp_file)
        let x = substitute(line, '[^A-Za-z0-9 :.,?@#~}{=)(*&^%$£!-]', "", "g")
        if x =~ " ("
            let f = split(x, " (")
            call add(fonts, f[0])
        endif
    endfor
    return fonts
endfunction

function! ShowFontList()
	if exists("t:bufferName")
		let n = bufwinnr(t:bufferName)
		if n > -1
			exec n . " wincmd w"
		else
			topleft new
			exec "buffer " . t:bufferName
		endif
	else
		let t:bufferName = "font_1"
		topleft new
		silent! exec "edit " . t:bufferName
	endif
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap modifiable
	0,$d
    let b:fonts = sort(UseableFonts())
    for i in b:fonts
        call append("$", i)
    endfor
	silent 1d
	setlocal so=0 nomodifiable
	autocmd! BufUnload <buffer> unlet t:bufferName
	nnoremap <buffer> <CR> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
    nnoremap <buffer> q <C-W>q
	nnoremap <buffer> <2-LeftMouse> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
endfunction
  
function! UseableFonts()
    if exists("g:avialable_fonts")
        return g:avialable_fonts
	elseif filereadable(s:font_file)
		return ReadUseableFontsFile()
    endif
    call UpdateUseableFonts()
    return g:avialable_fonts
endfunction

function! UpdateUseableFonts()
    let fonts = WindowsReadFonts()
    let g:avialable_fonts = []
    for i in fonts
        if CheckFont(i)
            call add(g:avialable_fonts, i)
        endif
    endfor
	call PersistUseableFonts(g:avialable_fonts)
endfunction

function! PersistUseableFonts(fonts)
	call writefile(a:fonts, s:font_file)
endfunction

function! ReadUseableFontsFile()
	let g:avialable_fonts = readfile(s:font_file)
	return g:avialable_fonts 
endfunction


if has("gui")
	if exists("g:fontman_font")
		if exists("g:fontman_size")
			call SetFont(g:fontman_font, g:fontman_size)
		else
			call SetFont(g:fontman_font, g:default_size)
		endif
	endif
endif

command! FontSizeIncrease :call IncreaseFontSize(1)
command! FontSizeDecrease :call IncreaseFontSize(-1)
