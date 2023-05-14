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

local function quit(opts)
	local ok, result = pcall(vim.cmd.quit, opts)
	if not ok then
		if result then
			vim.notify(result)
		else
			vim.notify("ConfirmQuit: Error while quitting")
		end
	end
end

local function quitall(opts)
	local ok, result = pcall(vim.cmd.quit, opts)
	if not ok then
		if result then
			vim.notify(result)
		else
			vim.notify("ConfirmQuit: Error while quitting")
		end
	end
end

function M.confirm_quit(opts)
	if opts.bang == true then
		quit({ bang = true })
	end

	local is_last_tab_page = vim.fn.tabpagenr("$") == 1

	if not is_last_window() then
		quit()
		return
	end
	if not is_last_tab_page then
		quit()
		return
	end

	if user_wants_to_quit() then
		quit()
	end
end

function M.confirm_quit_all(opts)
	if opts.bang == true then
		quitall({ bang = true })
	end
	if user_wants_to_quit() then
		quitall()
	end
end

local function setup_cmdline_quit()
	if config.options.overwrite_q_command then
		vim.cmd([[ cnoreabbrev <expr> q (getcmdtype() == ":" && getcmdline() ==# "q") ? "ConfirmQuit" : "q" ]])
		vim.cmd([[ cnoreabbrev qq quit ]])
	end

	vim.api.nvim_create_user_command("ConfirmQuit", function(opts)
		require("confirm-quit").confirm_quit(opts)
	end, { force = true, bang = true })

	vim.api.nvim_create_user_command("ConfirmQuitAll", function(opts)
		require("confirm-quit").confirm_quit_all(opts)
	end, { force = true, bang = true })
end

function M.setup(user_conf)
	config.set(user_conf)
	setup_cmdline_quit()
end

return M
