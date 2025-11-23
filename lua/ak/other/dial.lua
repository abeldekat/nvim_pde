-- Only using the bool augend for now..
-- Dial can do a lot more though...

vim.keymap.set('n', '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end)
vim.keymap.set('n', '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end)

local augend = require('dial.augend')
require('dial.config').augends:register_group({
  default = {
    augend.constant.alias.bool, -- boolean value (true <-> false)
  },
})
