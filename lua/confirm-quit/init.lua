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

	return count == 1
end

local function user_wants_to_quit()
	return vim.fn.confirm("Do you want to quit?", "&Yes\n&No", 2, "Question") == 1
end

function M.confirm_quit(quit_all)
	local is_last_tab_page = vim.fn.tabpagenr("$") == 1

	-- Lua doesn't short circuit with conditional logic
	-- so the following code can't be refactored further
	if quit_all then
		if user_wants_to_quit() then
			vim.cmd.quitall()
		end

		return
	end

	if not is_last_window() then
		vim.cmd.quit()
		return
	end
	if not is_last_tab_page then
		vim.cmd.quit()
		return
	end

	if user_wants_to_quit() then
		vim.cmd.quit()
	end
end

local function setup_cmdline_quit()
	if config.options.overwrite_q_command then
		vim.cmd([[ cnoreabbrev <expr> q (getcmdtype() == ":" && getcmdline() ==# "q") ? "ConfirmQuit" : "q" ]])
		vim.cmd([[ cnoreabbrev qq quit ]])
	end

	vim.api.nvim_create_user_command("ConfirmQuit", function()
		require("confirm-quit").confirm_quit()
	end, { force = true })

	vim.api.nvim_create_user_command("ConfirmQuitAll", function()
		require("confirm-quit").confirm_quit(true)
	end, { force = true })
end

function M.setup(user_conf)
	config.set(user_conf)
	setup_cmdline_quit()
end

return M
