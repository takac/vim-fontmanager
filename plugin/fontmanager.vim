" Author: Tom Cammann 
"
" Cycle through common fonts
" different fonts for different syntaxs

let g:common_fonts = ["Inconsolata", "Ubuntu Mono", "Consolas", "Terminal"]
let g:default_size = 13

" Formats:
"    Unix: font\ name:hSIZE:format
"    Mac: font\ name:hSIZE:format
"    Windows: font_name\ SIZE

function! CheckFont(name)
    let current = &guifont
    let check = FormatFont(a:name, 12)
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
    

function! FormatFont(name, size)
    if has("gui_macvim")
        let name = substitute(a:name, " ", "\\ ", "g")
        return name . ":h" . a:size
    elseif has("gui_gtk2")
        let name = substitute(a:name, " ", "\\ ", "g")
        return name . "\\ " . a:size
    elseif has("gui_win32") || has("gui_win64")
        let name = substitute(a:name, " ", "_", "g")
        return name . ":h" . a:size
    else
        " OH NO
    endif
    "
endfunction

function! WindowsReadFonts()
    let tmp_file = 'out.txt'
    exec 'silent !regedit /e ' . tmp_file . ' "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"'
    let fonts = []
    for line in readfile("out.txt")
        let x = substitute(line, '[^A-Za-z0-9 :.,?@#~}{=)(*&^%$£!-]', "", "g")
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
  
function! ListUseableFonts()
    " let fonts = ["Consolas", "Jibe", "Jab", "Fixedsys"]
    let fonts = WindowsReadFonts()
    let useable = []
    for i in fonts
        if CheckFont(i)
            call add(useable, i)
        endif
    endfor
    echom len(useable)
    return useable
endfunction

