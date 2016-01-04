let s:vim_arduino_version = '0.1.0'

" Load Once: {{{1
if exists("loaded_vim_platform_io")
    finish
endif
let loaded_vim_platform_io = 1

if !exists('g:vim_platform_io_auto_open_serial')
  let g:vim_platform_io_auto_open_serial = 0
endif

let s:helper_dir = expand("<sfile>:h")

function! s:PrintStatus(result)
  if a:result == 0
    echohl Statement | echomsg "Succeeded." | echohl None
  else
    echohl WarningMsg | echomsg "Failed." | echohl None
  endif
endfunction

" Private: Compile or deploy code
"
" Returns nothing.
function! s:PlatformIoCli(command)
  let l:f_name = expand('%:p')
  execute "w"

  echomsg "Compiling and deploying..." l:f_name
  let l:result = system(a:command)

  echo l:result

"  let l:result2 = system("find .build -name '*.hex' -printf '%p %s bytes'")
"  echo l:result2

  call s:PrintStatus(v:shell_error)

  return !v:shell_error
endfunction

" Public: Clean current project.
"
function! PlatformIoClean()
  call s:PlatformIoCli("platformio run --target clean")
endfunction

" Public: Compile current project.
"
function! PlatformIoBuild()
  call s:PlatformIoCli("platformio run")
endfunction

" Public: Compile and Deploy the current pde file.
"
function! PlatformIoDeploy()
  call s:PlatformIoCli("platformio run --target upload")

  " optionally auto open a serial port
  if g:vim_platform_io_auto_open_serial
    call PlatformIoSerialMonitor()
  endif
endfunction

" Public: Monitor a serial port
"
" Returns nothing.
function! PlatformIoSerialMonitor()
  if ArduinoDeploy()
    echo system(s:helper_dir."/vim-arduino-serial")
  endif
endfunction

if !exists('g:vim_platform_io_map_keys')
  let g:vim_platform_io_map_keys = 1
endif

if g:vim_platform_io_map_keys
  nnoremap <leader>pc :call PlatformIoClean()<CR>
  nnoremap <leader>pb :call PlatformIoBuild()<CR>
  nnoremap <leader>pd :call PlatformIoDeploy()<CR>
  nnoremap <leader>ps :call PlatformIoSerialMonitor()<CR>
endif
