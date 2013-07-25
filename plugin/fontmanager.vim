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

if !has("gui") || &cp || version < 700
	finish
end

let g:default_size = 12

let s:current_dir = expand("<sfile>:p:h")

function! GetUseableFontFile()
    let font_file = "fonts.txt"
    if has("unix")
        return s:current_dir . "/" . font_file
    else
        return s:current_dir . "\\" . font_file
    endif
endfunction

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
    let check = FormatFont(a:name,"", 11)
	let t_list = [ check ]
	call writefile(t_list, expand("~") . "/tmp-font.txt", "")
    try
		exec "set guifont=" . check
    catch /Invalid.*/
    endtry
    "echo substitute(check, "\\", "", "g") . " == " . &guifont
    if &guifont == substitute(check, "\\", "", "g")
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
    elseif has("gui_gtk2") || has("gui_gnome")
        if font =~? "\\d\\+$"
            let size = matchstr(font, " \\zs\\d\\+")
            return size
        endif
    elseif has("gui_win32") || has("gui_win64")
        if font =~? ":h\\d\\+"
			let size = matchstr(font, ":h\\zs\\d\\+") 
            return size
        endif
    endif
    " If size has been removed from guifont for some reason...
    return g:default_size
endfunction

function! SetBoldFont(name, size)
    exec "set guifont=". FormatFont(a:name, "b", a:size)
endfunction

    
function! GetCurrentFont()
    let font = &guifont

    if font == ""
        " Monospace
        " Not set! Probably a console
        return "Monospace"
    elseif has("gui_macvim")
        " dostuff ..
        " split(":")
    elseif has("gui_gtk2") || has("gui_gnome")
        if font =~? " \\d\\+$"
            let name = matchstr(font, ".* \\ze\\d\\+")
            return name
        else
            return font
        endif
    elseif has("gui_win32") || has("gui_win64")
        let name = split(font, ":")[0]
        let name = substitute(name, "_", " ", "g")
        return name
    endif
    return font
endfunction

function! FormatFont(name, style, size)
    if has("gui_macvim")
        let name = substitute(a:name, " ", "\\\\ ", "g")
        return name . ":h" . a:size
    elseif has("gui_gtk2") || has("gui_gnome")
        let name = substitute(a:name, " ", "\\\\ ", "g")
        return name . "\\ " . a:size
    elseif has("gui_win32") || has("gui_win64")
        let name = substitute(a:name, " ", "_", "g")[:30]
        return name . ":" . a:style . ":h" . a:size
    else
        " OH NO Console!
    endif
endfunction

function! SetFontStyle(style)
	let font = GetCurrentFont()
	let size = GetCurrentFontSize()
	if a:style == "italic" || a:style == "i"
		call SetFontAndStyle(font, "i", size)
	elseif a:style == "bold" || a:style == "b"
		call SetFontAndStyle(font, "b", size)
	elseif a:style == "italic bold" || a:style == "bi" || a:style == "ib" || a:style == "bold italic"
		call SetFontAndStyle(font, "bi", size)
	else
		call SetFontAndStyle(font, "", size)
	endif
endfunction

function! LinuxReadFonts()
    let list = split(system('fc-list | cut -d":" -f2 | sed "s/^ //"'), "\n")
    let d = {}
    for i in list
        let d[i] = ''
    endfor
    let d["Monospace"] = ""
    return sort(keys(d))
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
	if exists("t:bufferName") && bufnr(t:bufferName) > -1
		let n = bufwinnr(t:bufferName)
		if n > -1
			exec n . " wincmd w"
		else
			topleft new
			exec "buffer " . t:bufferName
		endif
	else
		let t:bufferName = "font_list"
		topleft new
		silent! exec "edit " . t:bufferName
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap modifiable
	0,$d
    let b:fonts = sort(ListUseableFonts())
    for i in b:fonts
        call append("$", i)
    endfor
	silent 1d
	setlocal so=0 nomodifiable
	autocmd! BufUnload <buffer> unlet t:bufferName
	nnoremap <buffer> <CR> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
    nnoremap <buffer> q <C-W>q
	nnoremap <buffer> <2-LeftMouse> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
	endif
endfunction
  
function! ListUseableFonts()
    if exists("g:avialable_fonts")
        return g:avialable_fonts
	elseif filereadable(GetUseableFontFile())
		return ReadUseableFontsFile()
    endif
    call UpdateUseableFonts()
    return g:avialable_fonts
endfunction

function! UpdateUseableFonts()
    if has("win")
        let fonts = WindowsReadFonts()
    elseif has("unix") && system("uname") == "Linux\n"
        let fonts = LinuxReadFonts()
    elseif has("mac") "???
    endif

    let g:avialable_fonts = []
    for i in fonts
        if CheckFont(i)
            call add(g:avialable_fonts, i)
        endif
    endfor
	call PersistUseableFonts(g:avialable_fonts)
endfunction

function! PersistUseableFonts(fonts)
	call writefile(a:fonts, GetUseableFontFile())
endfunction

function! ReadUseableFontsFile()
	let g:avialable_fonts = readfile(GetUseableFontFile())
	return g:avialable_fonts 
endfunction

function! ListStyles()
	return ["None", "Bold", "Italic", "Bold Italic"]
endfunction

function! CompleteStyles(A, L, P)
	let fonts = ""
	for i in ListStyles()
		let fonts = fonts . i . "\n"
	endfor
	return fonts
endfunction

function! CompleteFonts(A, L, P)
	let fonts = ""
	for i in ListUseableFonts()
		let fonts = fonts . i . "\n"
	endfor
	return fonts
endfunction

if has("gui")
	if exists("g:fontman_font")
		if exists("g:fontman_size")
			call SetFont(g:fontman_font, g:fontman_size)
		else
			call SetFont(g:fontman_font, g:default_size)
		endif
	endif
	if exists("g:fontman_style")
		call SetFontStyle(g:fontman_style)
	endif
endif

command! -nargs=0 FontSizeIncrease call IncreaseFontSize(1)
command! -nargs=0 FontSizeDecrease call IncreaseFontSize(-1)
command! -nargs=0 FontListShow call ShowFontList()
command! -nargs=* -complete=custom,CompleteStyles FontSetStyle call SetFontStyle("<args>")
command! -nargs=* -complete=custom,CompleteFonts FontSet call SetFont("<args>", GetCurrentFontSize())
command! -nargs=0 FontResetUseableList call UpdateUseableFonts()
