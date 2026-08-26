-- LazyGit -- toggles a floating terminal running the external `lazygit` TUI.
local Snacks = require("snacks")

local M = {}

function M.toggle() Snacks.terminal.toggle({ "lazygit" }) end

return M
