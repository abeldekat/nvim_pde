-- https://www.reddit.com/r/neovim/comments/1kbz9jf/minipairs_mapping_for_angle_brackets_that_doesnt/

local has_pairs, pairs = pcall(require, "mini.pairs")
if has_pairs then
  -- The opening angle bracket is engaged if the character to the left of the < is a letter or a colon :.
  -- %a represents all letters.
  -- pairs.map_buf(0, "i", "<", { action = "open", pair = "<>", neigh_pattern = "[%a:]." })
  -- pairs.map_buf(0, "i", ">", { action = "close", pair = "<>", neigh_pattern = "[^\\]." })
end
