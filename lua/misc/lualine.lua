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

-- result: appearance of b and y is the same as c and x
function M.transform(theme)
  for _, mode in ipairs(modes) do
    if theme[mode] and theme[mode].b then
      if theme[mode].c then
        theme[mode].b.bg = theme[mode].c.bg
        theme[mode].b.fg = theme[mode].c.fg
      end
    end
    if theme[mode] and theme[mode].a then
      if theme[mode].c then
        theme[mode].a.bg = theme[mode].c.bg
        theme[mode].a.fg = theme[mode].c.fg
      end
    end
  end

  return theme
end

return M
