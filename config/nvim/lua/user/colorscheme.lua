local status_ok
status_ok = vim.cmd [[
  try
    colorscheme tokyodark
  catch
    colorscheme default
  endtry
]]
if not status_ok then
  status_ok, theme = pcall(require, "onedarker")
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
end

-- onedark.setup {
--     style = 'warmer'
-- }
-- onedark.load()

