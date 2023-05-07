local M = {}
local config = require("confirm-quit.config")

local function is_last_window()
	local wins = vim.api.nvim_list_wins()
	local count = 0
	for _, v in ipairs(wins) do
		local win = vim.api.nvim_win_get_config(v).relative
		if win == "" then
			count = count + 1
		end
	end
	if count == 1 then
		return true
	end
	return false
end

function M.confirm_quit()
	if is_last_window() and vim.fn.tabpagenr("$") == 1 then
		if vim.fn.confirm("Do you want to quit?", "&Yes\n&No", 2) ~= 1 then
			return
		end
	end
	vim.cmd.quit()
end

local function setup_cmdline_quit()
	if config.options.overwrite_q_command == true then
		vim.cmd([[cnoreabbrev <expr> q (getcmdtype() ==# ":" && getcmdline() ==# "q") ? "ConfirmQuit" : "q" ]])
		vim.api.nvim_create_user_command("ConfirmQuit", function()
			require("confirm-quit").confirm_quit()
		end, { force = true })
		vim.cmd([[cnoreabbrev qq  quit]])
	end
end

function M.setup(user_conf)
	config.set(user_conf)
	setup_cmdline_quit()
end

return M
