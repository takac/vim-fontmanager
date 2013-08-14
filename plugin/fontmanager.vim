" Author: Tom Cammann 
" Version: 0.2

if !has("gui_running") || &cp || version < 700
	finish
end

let g:default_size = 12

let s:current_dir = expand("<sfile>:p:h")

function! s:GetUseableFontFile()
    let font_file = "fonts.txt"
    if has("unix")
        return s:current_dir . "/" . font_file
    else
        return s:current_dir . "\\" . font_file
    endif
endfunction

function! s:SetFontAndStyle(name, style, size)
	exec "set guifont=". s:FormatFont(a:name, a:style, a:size)
endfunction

function! SetFont(name, size)
    if a:name =~? "\\<bold\\>.*\\<italic\\>" || a:name =~? "\\<italic\\>.*\\<bold\\>"
        exec "set guifont=". s:FormatFont(a:name, "bi", a:size)
    elseif a:name =~? "\\<bold\\>"
        exec "set guifont=". s:FormatFont(a:name, "b", a:size)
    elseif a:name =~? "\\<italic\\>"
        exec "set guifont=". s:FormatFont(a:name, "i", a:size)
    else
        exec "set guifont=". s:FormatFont(a:name, "", a:size)
    endif
endfunction

" Formats:
"    Unix: font\ name:hSIZE:format
"    Mac: font\ name:hSIZE:format
"    Windows: font_name\ SIZE

function! s:CheckFont(name)
    let current = &guifont
    let check = s:FormatFont(a:name,"", 11)
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
function! s:DecreaseFontSize(n)
    call SetFont(GetCurrentFont(), GetCurrentFontSize() - a:n)
endfunction

function! s:IncreaseFontSize(n)
    call SetFont(GetCurrentFont(), GetCurrentFontSize() + a:n)
endfunction

function! s:SetFontSize(n)
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

function! GetCurrentFont()
    let font = &guifont

    if font == ""
        " Not set!
        " Probably Monospace
        return "Monospace"
    elseif has("gui_macvim")
        let name = split(font, ":")[0]
        " dostuff ..
    elseif has("gui_gtk2") || has("gui_gnome")
        if font =~? " \\d\\+$"
            let name = matchstr(font, ".* \\ze\\d\\+")
            let name = substitute(name, "\\s*$", "", "")
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

function! s:ExpandStyle(style)
	if a:style == "italic" || a:style == "i"
		return "Italic"
	elseif a:style == "bold" || a:style == "b"
		return "Bold"
	elseif a:style == "italic bold" || a:style == "bi" || a:style == "ib" || a:style == "bold italic"
		return "Bold Italic"
    else 
        return ""
    endif
endfunction

function! s:FormatFont(name, style, size)
    if has("gui_macvim")
        let name = substitute(a:name, " ", "\\\\ ", "g")
        return name . ":h" . a:size
    elseif has("gui_gtk2") || has("gui_gnome")
        let font = substitute(a:name, " Bold", "", "g")
        let font = substitute(font, " Italic", "", "g")
        let expanded_style = s:ExpandStyle(a:style)
        if expanded_style != ""
            let font = font . " " . expanded_style . " " . a:size
        else
            let font = font . " " . a:size
        endif
        return substitute(font, " ", "\\\\ ", "g")
    elseif has("gui_win32") || has("gui_win64")
        let name = substitute(a:name, " ", "_", "g")[:30]
        return name . ":" . a:style . ":h" . a:size
    else
        " OH NO Console!
    endif
endfunction

function! s:SetFontStyle(style)
	let font = GetCurrentFont()
	let size = GetCurrentFontSize()
	if a:style == "italic" || a:style == "i"
		call s:SetFontAndStyle(font, "i", size)
	elseif a:style == "bold" || a:style == "b"
		call s:SetFontAndStyle(font, "b", size)
	elseif a:style == "italic bold" || a:style == "bi" || a:style == "ib" || a:style == "bold italic"
		call s:SetFontAndStyle(font, "bi", size)
	else
		call s:SetFontAndStyle(font, "", size)
	endif
endfunction

function! s:LinuxReadFonts()
    let list = split(system('fc-list | cut -d":" -f2 | sed "s/^ //"'), "\n")
    let d = {}
    for i in list
        let d[i] = ''
    endfor
    let d["Monospace"] = ""
    return sort(keys(d))
endfunction

function! s:WindowsReadFonts()
    let tmp_file = expand("$TMP") . '\\out.txt'
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

function! s:MacOsxReadFonts()
    " Possible python solution on OS X 10.5+
    " import Cocoa
    " manager = Cocoa.NSFontManager.sharedFontManager()
    " font_families = list(manager.availableFontFamilies())
    "
    " check for fc-list binary, if not then try python
endfunction

function! s:ShowFontList()
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
    let b:fonts = sort(s:ListUseableFonts())
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
  
function! s:ListUseableFonts()
    if exists("g:avialable_fonts")
        return g:avialable_fonts
	elseif filereadable(s:GetUseableFontFile())
		return s:ReadUseableFontsFile()
    endif
    call s:UpdateUseableFonts()
    return g:avialable_fonts
endfunction

function! s:UpdateUseableFonts()
    if has("win32") || has("win64")
        let fonts = s:WindowsReadFonts()
    elseif has("unix") && system("uname") == "Linux\n"
        let fonts = s:LinuxReadFonts()
    elseif has("gui_macvim")
        let fonts = s:MacOsxReadFonts()
	else
		throw "Font manager could not determine OS being used, aborting."
    endif

    let g:avialable_fonts = []
    for i in fonts
        if s:CheckFont(i)
            call add(g:avialable_fonts, i)
        endif
    endfor
	call s:PersistUseableFonts(g:avialable_fonts)
endfunction

function! s:PersistUseableFonts(fonts)
	call writefile(a:fonts, s:GetUseableFontFile())
endfunction

function! s:ReadUseableFontsFile()
	let g:avialable_fonts = readfile(s:GetUseableFontFile())
	return g:avialable_fonts 
endfunction

function! s:ListStyles()
	return ["None", "Bold", "Italic", "Bold Italic"]
endfunction

function! s:CompleteStyles(A, L, P)
	let fonts = ""
	for i in s:ListStyles()
		let fonts = fonts . i . "\n"
	endfor
	return fonts
endfunction

function! s:CompleteFonts(A, L, P)
	let fonts = ""
	for i in s:ListUseableFonts()
		let fonts = fonts . i . "\n"
	endfor
	return fonts
endfunction

function! s:CompleteSize(A, L, P)
    let current_size = GetCurrentFontSize()
    let sizes = []
    let i = 1
    while i < 6
        call add(sizes, string(current_size + i))
        call add(sizes, string(current_size - i))
        let i += 1
    endwhile
    return sizes
endfunction

if has("gui_running")
	if exists("g:fontman_font")
		if exists("g:fontman_size")
			call SetFont(g:fontman_font, g:fontman_size)
		else
			call SetFont(g:fontman_font, g:default_size)
		endif
	endif
	if exists("g:fontman_style")
		call s:SetFontStyle(g:fontman_style)
	endif
endif

command! -nargs=* -complete=customlist,s:CompleteSize FontSize call s:SetFontSize(<args>)
command! -nargs=0 FontList call s:ShowFontList()
command! -nargs=* -complete=custom,s:CompleteStyles FontStyle call s:SetFontStyle("<args>")
command! -nargs=* -complete=custom,s:CompleteFonts Font call SetFont("<args>", GetCurrentFontSize())
command! -nargs=0 FontResetUseableList call s:UpdateUseableFonts()
