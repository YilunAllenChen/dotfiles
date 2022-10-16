local status_ok, onedark = pcall(require, "onedark")
if not status_ok then
  vim.cmd [[
  try
    colorscheme onedark
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
  ]]
end

onedark.setup {
    style = 'warmer'
}
onedark.load()

