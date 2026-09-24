-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local binary = vim.fn.expand("%:p:r")

  -- We add " ; read -n 1 -p 'Press any key to close...'" at the end
  local run_cmd = "g++ '"
    .. file
    .. "' -o '"
    .. binary
    .. "' && '"
    .. binary
    .. "' ; echo '' ; read -n 1 -p '[Process completed] Press any key to close...'"

  Snacks.terminal.open(run_cmd, {
    win = { position = "float", size = { width = 0.8, height = 0.4 } },
  })
end, { desc = "Compile & Run C++ Code" })
