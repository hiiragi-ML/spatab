" 何行まで判定に利用するか
let s:max_line_num = get(g:, 'spatab_max_line_num', 300)
" スペース判定の場合に返す文字列
let s:space_name = get(g:, 'spatab_space_name', 'space')
" タブ判定の場合に返す文字列
let s:tab_name = get(g:, 'spatab_tab_name', 'tab')
" スペース判定の場合に実行される関数名
let s:space_func_name = get(g:, 'spatab_spafre_func_name', '')
" タブ判定の場合に実行される関数名
let s:tab_func_name = get(g:, 'spatab_tab_func_name', '')
" 判定時に、自動的にexpandtabを切り替えるかのフラグ
let s:auto_expandtab = get(g:, 'spatab_auto_expandtab', 1)

" 実装 {{{
function! spatab#GetDetectName() abort
  let detect_name = get(b:, 'spatab_detect_name', '')
  " 既にチェック済みか確認。済みなら飛ばす。
  if detect_name ==# ''
    " 現在ファイルの指定行数分の文字列を配列として取得
    let buflines = getbufline(bufname('%'), 1, s:max_line_num)
    " 各行の先頭型部かどうか調べ、個数を調べる
    let len_tab = len(filter(copy(buflines), "v:val =~# '^\\t'"))
    " 各業の先頭がスペースかどうか調べ、個数を調べる
    let len_space = len(filter(copy(buflines), "v:val =~# '^ '"))

    " スペース数とタブ数を比較して、適切な文字列代入
    if len_space > len_tab
      " space
      let detect_name = s:space_name
    elseif len_space < len_tab
      " tab
      let detect_name = s:tab_name
    endif

    " 結果をバッファ変数に保持し、チェック済みとする
    let b:spatab_detect_name = detect_name
  endif
  " 結果を返す
  return detect_name
endfunction

function! spatab#Execute() abort
  let res = spatab#GetDetectName()
  if res ==# s:space_name
    " スペース判定の場合
    if s:auto_expandtab | setlocal expandtab | endif
    if s:space_func_name !=# '' | call {s:space_func_name}() | endif

  elseif res ==# s:tab_name
    " タブ判定の場合
    if s:auto_expandtab | setlocal noexpandtab | endif
    if s:tab_func_name !=# '' | call {s:tab_func_name()} | endif
  endif
endfunction
" }}}
