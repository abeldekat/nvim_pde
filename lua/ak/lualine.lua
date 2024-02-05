local M = {}

local modes = {
  "normal",
  "insert",
  "terminal",
  "command",
  "visual",
  "replace",
  "inactive",
}

-- result: appearance of secionts a and b is the same as section c
function M.transform(theme)
  for _, mode in ipairs(modes) do
    if theme[mode] and theme[mode].c then
      if theme[mode].a then
        theme[mode].a.bg = theme[mode].c.bg
        theme[mode].a.fg = theme[mode].c.fg
      end
      if theme[mode].b then
        theme[mode].b.bg = theme[mode].c.bg
        theme[mode].b.fg = theme[mode].c.fg
      end
    end
  end

  return theme
end

return M
