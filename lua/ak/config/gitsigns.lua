local opts = {
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
    end

    map("n", "]h", gs.next_hunk, "Next hunk")
    map("n", "[h", gs.prev_hunk, "Prev hunk")
    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
    map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
    map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
    map("n", "<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
    map("n", "<leader>ghd", gs.diffthis, "Diff this")
    map("n", "<leader>ghD", function()
      gs.diffthis("~")
    end, "Diff this ~")
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
  end,
}
require("gitsigns").setup(opts)
