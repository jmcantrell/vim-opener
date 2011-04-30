" Filename:    opener.vim
" Description: Open a file or URL
" Maintainer:  Jeremy Cantrell <jmcantrell@gmail.com>

if exists('g:opener_loaded') || &cp
    finish
endif

let g:opener_loaded = 1

if !exists('g:opener_cmd')
    if has('mac')
        let g:opener_cmd = 'open'
    elseif has('unix')
        let g:opener_cmd = 'xdg-open'
    else " has('win32') || has('win64')
        let g:opener_cmd = 'start cmd /cstart /b'
    endif
endif

if !hasmapto('<plug>Opener', 'n')
    nmap <unique> gO <plug>Opener
endif

if !hasmapto('<plug>Opener', 'v')
    vmap <unique> gO <plug>Opener
endif

nmap <unique> <script> <plug>Opener <sid>Opener
vmap <unique> <script> <plug>Opener <sid>Opener

nmap <sid>Opener :Opener <cfile><cr>
vmap <sid>Opener :Opener<cr>

command! -range -nargs=? Opener :call <sid>Opener(<q-args>)

function! s:GetVisual() range
    let reg_save = getreg('"')
    let regtype_save = getregtype('"')
    let cb_save = &clipboard
    set clipboard&
    silent normal! ""gvy
    let selection = getreg('"')
    call setreg('"', reg_save, regtype_save)
    let &clipboard = cb_save
    return selection
endfunction

function! s:Strip(value)
    return substitute(a:value, '^\s*\(.*\)\s*$', '\1', '')
endfunction

function! s:GetLocations()
    let locations = []
    for location in split(s:GetVisual(), "\n")
        let location = s:Strip(location)
        if len(location) > 0
            call add(locations, location)
        endif
    endfor
    return locations
endfunction

function! s:Opener(location)
    if len(a:location) == 0
        for location in s:GetLocations()
            call s:Opener(location)
        endfor
    else
        silent call system(g:opener_cmd.' '.shellescape(expand(a:location)))
    endif
endfunction
