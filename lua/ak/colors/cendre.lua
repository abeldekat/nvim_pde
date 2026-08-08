local info = {
  name = 'cendre',
  variants = { 'hard', 'medium', 'soft' },
  cb = function(variant) vim.cmd('CendreBackground ' .. variant) end,
}
Config.add_theme_info('cendre', info, 'Cendre variants')

require('cendre').setup({
  background = 'soft',
  dim_inactive = true,
})
