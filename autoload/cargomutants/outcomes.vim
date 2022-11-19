let s:saved_cpo = &cpoptions
set cpoptions&vim


" get the path to `outcomes.json` file with the given project root dir
" if options string is given, it will be checked for `output` dir, and
" if specified it will use that to construct the path to `outcomes.json`
function! s:locate_outcomes_file(root_dir, ...) abort
  let l:opts = get(g:, 'cargomutants_cmd_opts', '')
  if a:0 > 0
    let l:opts = a:1
  endif
  let l:output_dir = cargomutants#utils#output_dir_from_opts(l:opts)
  if empty(l:output_dir)
    return join([
          \ a:root_dir,
          \ 'mutants.out',
          \ 'outcomes.json'], '/')
  else
    return join([
          \ a:root_dir,
          \ trim(l:output_dir, '"'),
          \ 'mutants.out',
          \ 'outcomes.json'], '/')
  endif
endfunction


function! cargomutants#outcomes#read_outcomes_json() abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()
  if empty(b:cargomutants_root_dir)
    echoe 'Cargo project root not found'
    return v:null
  endif
  let l:json_file = s:locate_outcomes_file(
        \ b:cargomutants_root_dir, get(g:, 'cargomutants_cmd_opts', ''))
  let l:json_file = expand(l:json_file)
  if !filereadable(l:json_file)
    " outcomes.json not found
    echom printf('outcomes.json (%s) file not found.', l:json_file)
    return v:null
  endif
  let l:json = json_decode(join(readfile(l:json_file), ''))
  return l:json
endfunction


function! cargomutants#outcomes#get_logfile_path(key) abort
  let b:cargomutants_outcomes = get(b:, 'cargomutants_outcomes',
        \   s:build_outcomes_data())

  if !has_key(b:cargomutants_outcomes, a:key) | return v:null | endif

  " TODO: check key `log_path` exists
  let l:f = b:cargomutants_outcomes[a:key].log_path
  " if log_path is not relative path
  if l:f[0] ==# '/'
    return l:f
  else
    return resolve(join([b:cargomutants_root_dir, l:f], '/'))
  endif
endfunction


function! s:build_outcomes_data() abort
  let l:json = cargomutants#outcomes#read_outcomes_json()

  let l:mutants = {}
  for l:e in l:json.outcomes
    if type(l:e.scenario) != v:t_dict | continue | endif
    if !has_key(l:e.scenario, 'Mutant') | continue | endif
    let l:mut = l:e.scenario.Mutant
    let l:text = cargomutants#outcomes#build_loc_list_text(
          \ l:e.summary, l:mut.function, l:mut.return_type, l:mut.replacement)
    let l:mut_key = cargomutants#outcomes#build_outcome_key(
          \ l:mut.file, l:mut.line, l:text)

    let l:mutants[l:mut_key] = l:e
  endfor

  return l:mutants
endfunction


function! cargomutants#outcomes#build_uncaught_mutants_list(outcomes_json) abort
  if type(a:outcomes_json) != v:t_dict || !has_key(a:outcomes_json, 'outcomes')
    return []
  endif
  let l:mutants = []
  for l:e in a:outcomes_json.outcomes
    if type(l:e.scenario) != v:t_dict || !has_key(l:e.scenario, 'Mutant')
      continue
    endif
    let l:err_type = s:get_mutant_result_type(l:e)
    if l:err_type ==# v:null | continue | endif
    let l:mut = l:e.scenario.Mutant
    let l:mutants += [{
          \ 'filename': b:cargomutants_root_dir . '/'. l:mut.file,
          \ 'lnum': l:mut.line,
          \ 'type': l:err_type,
          \ 'text': cargomutants#outcomes#build_loc_list_text(
          \           l:e.summary,
          \           l:mut.function, l:mut.return_type,
          \           l:mut.replacement),
          \ }]
  endfor
  return s:sort_mutants_list(l:mutants)
endfunction


" this function is refactored out for ease of testing
" sorting the mutant list
function! s:sort_mutants_list(mutants) abort
  let l:sorted_mutants = sort(copy(a:mutants),
        \ {m1, m2 ->
        \   m1.filename ==# m2.filename
        \     ? m1.lnum - m2.lnum
        \     : m1.filename > m2.filename ? 1 : -1
        \ })
  return l:sorted_mutants
endfunction


" returns the error type('E', 'W', ect.) for the loclist entry
function! s:get_mutant_result_type(outcome_entry) abort
  let l:outcome = v:null
  for l:result in a:outcome_entry.phase_results
    if l:result.phase ==? 'build' && l:result.cargo_result ==? 'failure'
      let l:outcome = 'unviable'
    elseif l:result.phase ==? 'test' && l:result.cargo_result ==? 'success'
      let l:outcome = 'missed'
    elseif l:result.phase ==? 'test' && l:result.cargo_result ==? 'timeout'
      let l:outcome = 'timeout'
    endif
    if !empty(l:outcome) | break | endif
  endfor

  let l:error_map = get(g:, 'cargomutants_error_type_map', {
        \ 'missed': 'E',
        \ 'unviable': 'W',
        \ 'timeout': 'W',
        \ })

  return l:outcome == v:null ? v:null : l:error_map[l:outcome]
endfunction


let s:loclist_text_format   = '[%s] %s%s replaced with %s'
let s:loclist_text_pattern  = '\v\[.+\]\s*(.{-})\s*$'

function! cargomutants#outcomes#build_outcome_key(file, line, text) abort
  let l:text = a:text
  " The text field in loclist is:
  " [Summary] <func><return type> replaced with <replacement>
  let l:m = matchlist(l:text, s:loclist_text_pattern)
  if len(l:m) > 0
    let l:text = l:m[1]
  endif
  let l:key = join([a:file, a:line, l:text], '-')
  return l:key
endfunction


" not only for text in list item, but also part of lookup key
function! cargomutants#outcomes#build_loc_list_text(
      \ summary, function, return_type, replacement) abort
  " let l:s = printf('[%s] %s%s replaced with %s',
  let l:s = printf(s:loclist_text_format,
        \   a:summary, a:function,
        \   a:return_type !=# '' ? ' ' . a:return_type : '',
        \   a:replacement)
  return l:s
endfunction


function! cargomutants#outcomes#get_stats()abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()
  let l:json_file = s:locate_outcomes_file(
        \ b:cargomutants_root_dir, g:cargomutants_cmd_opts )
  if !filereadable(l:json_file)
    " No cargo-mutants outcomes.json found
    return v:null
  endif
  let l:json = json_decode(join(readfile(l:json_file), ''))
  let l:stats = {
        \ 'total': l:json.total_mutants,
        \ 'missed': l:json.missed,
        \ 'caught': l:json.caught,
        \ 'timeout': l:json.timeout,
        \ 'unviable': l:json.unviable,
        \ 'success': l:json.success,
        \ 'failure': l:json.failure,
        \}
  return l:stats
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
