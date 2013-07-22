" Author: Tom Cammann 
"
" Cycle through common fonts
" different fonts for different syntaxs

let g:common_fonts = ["Inconsolata", "Ubuntu Mono", "Consolas", "Terminal"]
let g:default_size = 13

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
            let name = split(font, ":")[-1][1:]
            return name
        else
            " Default not set to 12 - This will/could be wrong if size has
            " been removed
            return 12
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
        " Not set! TODO return Something
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
        let name = substitute(a:name, " ", "_", "g")
        return name . ":" . a:style . ":h" . a:size
    else
        " OH NO Console!
    endif
endfunction

function! WindowsReadFonts()
    let tmp_file = 'out.txt'
    exec 'silent !regedit /e ' . tmp_file . ' "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"'
    let fonts = []
    for line in readfile("out.txt")
        let x = substitute(line, '[^A-Za-z0-9 :.,?@#~}{=)(*&^%$�!-]', "", "g")
        " Bitstream kills vim!
        if x =~? "bitstream"
            continue
        elseif x =~ " ("
            let f = split(x, " (")
            call add(fonts, f[0])
        endif
    endfor
    return fonts
endfunction

function! ShowList()
	topleft new
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    let b:fonts = sort(UseableFonts())
    for i in b:fonts
        call append("$", i)
    endfor
	silent 1d
	nnoremap <buffer> <CR> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
    nnoremap <buffer> q <C-W>q
	nnoremap <buffer> <2-LeftMouse> :call SetFont(b:fonts[line(".")-1], GetCurrentFontSize())<CR>
endfunction
  
function! UseableFonts()
    if exists("g:avialable_fonts")
        return g:avialable_fonts
    endif

    let fonts = WindowsReadFonts()
    let g:avialable_fonts = []
    for i in fonts
        if CheckFont(i)
            call add(g:avialable_fonts, i)
        endif
    endfor
    return g:avialable_fonts
endfunction

