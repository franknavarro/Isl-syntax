if exists("b:current_syntax")
  finish
endif


" Inheret from xml
runtime! syntax/xml.vim


" Enable js and css syntax highlighting
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ keepend
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction
call TextEnableCodeSnip('javascript', '<js>', '<\/js>', 'Identifier')
call TextEnableCodeSnip('css', '<style>', '<\/style>', 'Identifier')


" Isl Vars
syntax match islVar "\v[\@\%][A-Za-z0-9\._]+>;?" containedin=xmlString,textSnipCSS,islExpression,islExpressionForced,islFunction,xmlTag
highlight link islVar Constant


" Isl Operators
syntax match islOperator "\v\*" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v/" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\+" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v-" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\?" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v:" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\=\=" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v!\=?" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\>\=?" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\<\=?" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\|\|" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islOperator "\v\&\&" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
highlight link islOperator jsOperator

syntax match islComma "\v," containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
highlight link islComma Noise

syntax match islAssumedString "\v[A-Za-z0-9_.]+" containedin=islExpression,islExpressionForced,islFunction contained
highlight link islAssumedString Noise

"Isl Numbers
syntax match islNumber "\v([A-Za-z_.])@<!\d([A-Za-z_.])@!" containedin=islExpression,islExpressionForced,islFunction contained
highlight link islNumber Number


" Isl Regex 
syntax match islRegex "\v\=\~\s*m\/([^/]|\\.)+\/[ig]{,2}" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islRegex "\v\=\~\s*s\/([^/]|\\.)+\/([^/]|\\.)*\/[ig]{,2}" containedin=islExpression,islExpressionForced,islFunction,islDynamic contained
syntax match islRegexStart "\v\=\~\s*[ms]\/" containedin=islRegex contained
syntax match islRegexEnd "\v(\\)@<!\/" containedin=islRegex contained
highlight link islRegex String
highlight link islRegexStart jsOperator
highlight link islRegexEnd jsOperator


" Strings
syntax region xmlString contained start=+"+ skip=/\v\\./ end=+"+ contains=xmlEntity,@Spell,islExpressionForced,islFunction,islDynamic display
syntax region xmlString contained start=+'+ skip=/\v\\./ end=+'+ contains=xmlEntity,@Spell,islExpressionForced,islFunction,islDynamic display


" Isl Parenthesis, Lists, and Hash Tables
syntax region islExpression matchgroup=islParens start=+(+ end=+)+ containedin=xmlTag contains=xmlString,islVar,islOperator,islExpression,islFunction,islDynamic contained
highlight link islParens Noise

syntax region islExpression matchgroup=islList start=+#\?{+ end=+}+ containedin=xmlTag,islExpression contained contains=xmlString,islOperator,islExpression,islFunction,islDynamic
highlight link islList Noise

"Isl Expressions when in strings
syntax region islExpressionForced matchgroup=islExpStart start=+&(+ end=+);\?+ contains=xmlString,islOperator,islExpression,islFunction,islDynamic 
highlight link islExpStart jsOperator

" Isl Dynamic variables
syntax region islDynamic matchgroup=islDynamicStart start=+@(+ end=+);\?+ contains=xmlString,islOperator,islExpression,islFunction,islDynamic containedin=xmlTag
highlight link islDynamicStart jsOperator


" Isl Functions
syntax region islFunction matchgroup=islFunctionStart start=+[\@\%][A-Za-z0-9._]\+[([]+ end=+[)\]];\?+ contains=xmlString,islOperator,islExpression,islFunction,islDynamic containedin=xmlTag
highlight link islFunctionStart Function 

" Primitive function
syntax region islFunction matchgroup=islFunctionStart start=+\(value=\)\?\zs[A-Za-z0-9._]\+(+ end=+);\?+ contains=xmlString,islOperator,islExpression,islFunction,islDynamic containedin=xmlAttrib


let b:current_syntax = "Isl"

