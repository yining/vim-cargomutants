let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#outcomes#GetLogFilePath(key) abort
  if !exists('b:cargomutants_outcomes')
    let b:cargomutants_outcomes = cargomutants#outcomes#BuildOutcomesData()
  endif

  if has_key(b:cargomutants_outcomes, a:key)
    " TODO: check key `log_path` exists
    let l:f = b:cargomutants_outcomes[a:key].log_path
    if l:f[0] ==# '/'
      return l:f
    else
      return resolve(join([b:cargomutants_root_dir, l:f], '/'))
    endif
  endif

  return v:null
endfunction


function! cargomutants#outcomes#BuildOutcomesData() abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()
  let l:json_file = join([b:cargomutants_root_dir, 'mutants.out', 'outcomes.json'], '/')
  if !filereadable(l:json_file)
    " No cargo-mutants outcomes.json found
    return
  endif
  let l:json = json_decode(join(readfile(l:json_file), ''))

  let l:mutants = {}
  for l:e in l:json.outcomes
    if type(l:e.scenario) != v:t_dict | continue | endif
    if !has_key(l:e.scenario, 'Mutant') | continue | endif
    " let l:err_type = cargomutants#GetMutantResultType(l:e)
    " if l:err_type ==# v:null | continue | endif
    let l:mut = l:e.scenario.Mutant
    let l:text = cargomutants#outcomes#BuildLocListText(l:e.summary, l:mut.function, l:mut.return_type, l:mut.replacement)
    let l:mut_key = cargomutants#outcomes#BuildOutcomeKey(l:mut.file, l:mut.line, l:text)

    let l:mutants[l:mut_key] = l:e

  endfor
  return l:mutants
endfunction


function! cargomutants#outcomes#BuildOutcomeKey(file, line, text) abort
  let l:key = join([a:file, a:line, a:text], '-')
  return l:key
endfunction


" not only for text in list item, but also part of lookup key
function! cargomutants#outcomes#BuildLocListText(
      \ summary, function, return_type, replacement) abort
  let l:s = printf('[%s] %s%s replaced with %s',
        \   a:summary, a:function,
        \   a:return_type !=# '' ? ' ' . a:return_type : '',
        \   a:replacement)
  return l:s
endfunction

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
