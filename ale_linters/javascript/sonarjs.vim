" Author: Guilherme R Fiuza <@fiuzagr>
" Description: sonarjs for JavaScript files

call ale#Set('javascript_sonarjs_executable', 'sonarjs')
call ale#Set('javascript_sonarjs_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_sonarjs_exclusions', [])

function! ale_linters#javascript#sonarjs#Handle(buffer, lines) abort
    let l:pattern = '\v^([^:]+): (.+) \[(\d+), (\d+)\]: (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[1] =~? '^MINOR'
            let l:type = 'W'
        else
            let l:type = 'E'
        endif

        call add(l:output, {
        \   'filename': l:match[2],
        \   'lnum': l:match[3] + 0,
        \   'col': l:match[4] + 0,
        \   'text': l:match[1] . ': ' . l:match[5],
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#javascript#sonarjs#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_sonarjs', [
    \   'node_modules/sonarjs/bin/sonarjs',
    \   'node_modules/.bin/sonarjs',
    \])
endfunction

function! ale_linters#javascript#sonarjs#GetCommand(buffer) abort
    let l:executable = ale_linters#javascript#sonarjs#GetExecutable(a:buffer)
    let l:exclusions = ale#Var(a:buffer, 'javascript_sonarjs_exclusions')
    let l:command = ale#path#BufferCdString(a:buffer)
    \ . ale#node#Executable(a:buffer, l:executable)

    if len(l:exclusions) > 0
        let l:command .= ' -e "' . join(l:exclusions, ', ') . '"'
    endif

    return l:command
endfunction

call ale#linter#Define('javascript', {
\   'name': 'sonarjs',
\   'executable_callback': 'ale_linters#javascript#sonarjs#GetExecutable',
\   'command_callback': 'ale_linters#javascript#sonarjs#GetCommand',
\   'callback': 'ale_linters#javascript#sonarjs#Handle',
\})

