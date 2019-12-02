let g:fileJSEnd = "_structure_data"
function! GetItemPath()
  return substitute(expand("%:p:r"),"\\([A-Za-z]\\+\\d\\{3\\}\\)\.\\+\$", "\\1", "")
:endfunction
function! PathJS()
  return GetItemPath().g:fileJSEnd.".js"
:endfunction
function! PathIsl()
  return GetItemPath().".Isl"
:endfunction

function! OpenJS()
  execute "vsplit ".PathJS()
:endfunction
function! OpenIsl()
  execute "vsplit ".PathIsl()
:endfunction

function! CreateJS()
  call system("touch ".PathJS())
:endfunction

function! FindTagsJS()
  " Find the first set of js tags
  execute "normal! gg/<js>\<Enter>"
:endfunction

function! ExportJS()
  " Open the Isl file if we are not currently on it
  let inIslFile = 1
  if PathIsl() != expand("%:p")
    call OpenIsl()
    let inIslFile = 0
  endif
  " Go to the first set of JS tags
  call FindTagsJS()
  " Make sure the js tags are folded in order to delete them easily 
  let currlinenum = line(".")
  if foldclosed(currlinenum) < 0
    execute "normal! zfat"
  endif
  " Add all the text between the JS Tag to the current buffer
  execute "normal! Y"
  " Quit the Isl file if we weren't previously in it
  if inIslFile == 0
    execute "q"
  endif

  " Open the JS file in a new split view
  call OpenJS()
  " Go to the top of the file and then delete all lines of the file
  " and don't add the deleted lines to the register
  execute "normal! gg\"_dG"
  " Paste and remove extra space up top, extra tag up top and extra
  " tag at the bottom
  execute "normal! pggd2dGdd"
  " Indent entire file down one
  execute "%<"
  " Write and quit the open split
  execute "wq"

:endfunction

function! ImportJS(...)
  " Open the Isl file if we are not currently on it
  let inIslFile = 1
  if PathIsl() != expand("%:p")
    call OpenIsl()
    let inIslFile = 0
  endif

  " Find the function @userfOrgaChem.loadDataFile and add a line below it
  execute "normal! gg/@userfOrgaChem.loadDataFile\<Enter>"
  let functionLine = line(".")
  " Append the lines of js to line 2 in the file
  let jslines = ["<js>"] + readfile(PathJS()) + ["</js>"]
  call append(functionLine, jslines)
  " Fix indenting in JS
  call FindTagsJS()
  execute "normal! vit><<"
  " Fold the JS lines
  execute "normal! zfat"
  " Save the file to view changes in ZAP"
  execute "w"

  " If we weren't in the Isl file to start with then close it
  if inIslFile == 0 
    execute "q"
  endif
:endfunction

command! ImportJS :call ImportJS()
command! ExportJS :call ExportJS()
command! CreateJS :call CreateJS()

" Search for CSS colors with a few rules for Isl:
"   Make sure hex colors aren't preceded with an '&' because those are most
"   likely html entities
"   Make sure color names don't start with '@userf.' nor '@' because those are color
"   variables
"   Make sure color names don't start with 'name=' because that is a variable
"   declaration
command! SearchColor :%s/\c\v%(\&)@<!#([A-Fa-f0-9]{3}){1,2}|<((\@(userf.)?|name\=)@<!(AliceBlue|AntiqueWhite|Aqua(marine)?|Azure|Beige|Bisque|BlanchedAlmond|Blue|BlueViolet|Brown|BurlyWood|CadetBlue|Chartreuse|Chocolate|Coral|CornflowerBlue|Cornsilk|Crimson|Cyan|DarkBlue|DarkCyan|DarkGoldenRod|DarkGray|DarkGrey|DarkGreen|DarkKhaki|DarkMagenta|DarkOliveGreen|DarkOrange|DarkOrchid|DarkRed|DarkSalmon|DarkSeaGreen|DarkSlateBlue|DarkSlateGray|DarkSlateGrey|DarkTurquoise|DarkViolet|DeepPink|DeepSkyBlue|DimGray|DimGrey|DodgerBlue|FireBrick|FloralWhite|ForestGreen|Fuchsia|Gainsboro|GhostWhite|Gold(enRod)?|Gray|Grey|Green|GreenYellow|HoneyDew|HotPink|IndianRed|Indigo|Ivory|Khaki|Lavender(Blush)?|LawnGreen|LemonChiffon|LightBlue|LightCoral|LightCyan|LightGoldenRodYellow|LightGray|LightGrey|LightGreen|LightPink|LightSalmon|LightSeaGreen|LightSkyBlue|LightSlateGray|LightSlateGrey|LightSteelBlue|LightYellow|Lime|LimeGreen|Linen|Magenta|Maroon|MediumAquaMarine|MediumBlue|MediumOrchid|MediumPurple|MediumSeaGreen|MediumSlateBlue|MediumSpringGreen|MediumTurquoise|MediumVioletRed|MidnightBlue|MintCream|MistyRose|Moccasin|NavajoWhite|Navy|OldLace|Olive(Drab)?|Orange|OrangeRed|Orchid|PaleGoldenRod|PaleGreen|PaleTurquoise|PaleVioletRed|PapayaWhip|PeachPuff|Peru|Pink|Plum|PowderBlue|Purple|RebeccaPurple|Red|RosyBrown|RoyalBlue|SaddleBrown|Salmon|SandyBrown|SeaGreen|SeaShell|Sienna|Silver|SkyBlue|SlateBlue|SlateGray|SlateGrey|Snow|SpringGreen|SteelBlue|Tan|Teal|Thistle|Tomato|Turquoise|Violet|Wheat|WhiteSmoke|YellowGreen|Yellow))>//gn

function! ReplaceColor(searchColor,replaceColor)
  if a:searchColor =~ "\#"
    execute "%s/\\c\\v(\\&)@<!".a:searchColor."/".a:replaceColor."/g"
    echom "Hex"
  else
    execute "%s/\\c\\v(\\@(userf.)?|name\\=)@<!<".a:searchColor.">/".a:replaceColor."/g"
    echom "Color"
  endif
:endfunction
command! -nargs=+ ReplaceColor :call ReplaceColor(<f-args>)
