local function lualine_dark()
  local colors = {
    black = "#282828",
    white = "#ebdbb2",
    red = "#fb4934",
    green = "#b8bb26",
    blue = "#83a598",
    yellow = "#fe8019",
    gray = "#a89984",
    darkgray = "#3c3836",
    lightgray = "#504945",
    inactivegray = "#7c6f64",
  }

  return {
    normal = {
      a = { bg = colors.gray, fg = colors.black, gui = "bold" },
      b = { bg = colors.lightgray, fg = colors.white },
      c = { bg = colors.darkgray, fg = colors.gray },
    },
    insert = {
      a = { bg = colors.blue, fg = colors.black, gui = "bold" },
      b = { bg = colors.lightgray, fg = colors.white },
      c = { bg = colors.lightgray, fg = colors.white },
    },
    visual = {
      a = { bg = colors.yellow, fg = colors.black, gui = "bold" },
      b = { bg = colors.lightgray, fg = colors.white },
      c = { bg = colors.inactivegray, fg = colors.black },
    },
    replace = {
      a = { bg = colors.red, fg = colors.black, gui = "bold" },
      b = { bg = colors.lightgray, fg = colors.white },
      c = { bg = colors.black, fg = colors.white },
    },
    command = {
      a = { bg = colors.green, fg = colors.black, gui = "bold" },
      b = { bg = colors.lightgray, fg = colors.white },
      c = { bg = colors.inactivegray, fg = colors.black },
    },
    inactive = {
      a = { bg = colors.darkgray, fg = colors.gray, gui = "bold" },
      b = { bg = colors.darkgray, fg = colors.gray },
      c = { bg = colors.darkgray, fg = colors.gray },
    },
  }
end

local function lualine_light()
  local colors = {
    black = "#3c3836",
    white = "#f9f5d7",
    orange = "#af3a03",
    green = "#427b58",
    blue = "#076678",
    gray = "#d5c4a1",
    darkgray = "#7c6f64",
    lightgray = "#ebdbb2",
    inactivegray = "#a89984",
  }

  return {
    normal = {
      a = { bg = colors.darkgray, fg = colors.white, gui = "bold" },
      b = { bg = colors.gray, fg = colors.darkgray },
      c = { bg = colors.lightgray, fg = colors.darkgray },
    },
    insert = {
      a = { bg = colors.blue, fg = colors.white, gui = "bold" },
      b = { bg = colors.gray, fg = colors.darkgray },
      c = { bg = colors.gray, fg = colors.black },
    },
    visual = {
      a = { bg = colors.orange, fg = colors.white, gui = "bold" },
      b = { bg = colors.gray, fg = colors.darkgray },
      c = { bg = colors.darkgray, fg = colors.white },
    },
    replace = {
      a = { bg = colors.green, fg = colors.white, gui = "bold" },
      b = { bg = colors.gray, fg = colors.darkgray },
      c = { bg = colors.gray, fg = colors.black },
    },
    command = {
      a = { bg = colors.darkgray, fg = colors.white, gui = "bold" },
      b = { bg = colors.gray, fg = colors.darkgray },
      c = { bg = colors.lightgray, fg = colors.darkgray },
    },
    inactive = {
      a = { bg = colors.lightgray, fg = colors.inactivegray },
      b = { bg = colors.lightgray, fg = colors.inactivegray },
      c = { bg = colors.lightgray, fg = colors.inactivegray },
    },
  }
end

if vim.opt.background:get() == "light" then
  return require("misc.lualine").transform(lualine_light())
end
return require("misc.lualine").transform(lualine_dark())
