local M = {}

local options = {
	overwrite_q_command = true,
 	quit_message = "Do you want to quit?",
}

local GENERIC_ERROR_MESSAGE = "ConfirmQuit: Error while quitting"

local function is_any_buffer_modified()
	local buffers = vim.api.nvim_list_bufs()

	for _, buf in ipairs(buffers) do
		local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf })

		if is_modified then
			return true
		end
	end

	return false
end

local function is_last_window()
	local wins = vim.api.nvim_list_wins()
	local count = 0

	for _, v in ipairs(wins) do
		local is_normal_window = vim.api.nvim_win_get_config(v).relative == ""
		if is_normal_window then
			count = count + 1
		end
	end

	return count == 1
end

local function prompt_user_to_quit()
	return vim.fn.confirm(options.quit_message, "&Yes\n&No", 2, "Question") == 1
end

--- A wrapper for pcall that just prints an error in case of failure
local function pcall_panic(func, ...)
	local ok, error = pcall(func, ...)
	if not ok then
		vim.notify(error or GENERIC_ERROR_MESSAGE, vim.log.levels.ERROR)
	end
end

local function quit(opts)
	pcall_panic(vim.cmd.quit, { bang = opts.bang, mods = { silent = true } })
end

local function quitall(opts)
	pcall_panic(vim.cmd.quitall, { bang = opts.bang, mods = { silent = true } })
end

local confirm_quit_default_opts = { bang = false }

function M.confirm_quit(opts)
	opts = opts or confirm_quit_default_opts

	local is_last_tab_page = vim.fn.tabpagenr("$") == 1
	local is_last_viewable = is_last_window() and is_last_tab_page
	local should_quit = opts.bang                                  -- Force-quit without prompting
	                    or (vim.bo.modified and not vim.o.confirm) -- or: Unsaved changes. Try quit to print error
	                    or not is_last_viewable                    -- or: Isn't last viewable. Simply quit
	                    or prompt_user_to_quit()                   -- or: Last viewable. Prompt to quit

	if should_quit then
		quit(opts)
	end
end

function M.confirm_quit_all(opts)
	opts = opts or confirm_quit_default_opts

	local should_quit = opts.bang                                           -- Force-quit without prompting
	                    or (is_any_buffer_modified() and not vim.o.confirm) -- or: Unsaved changes. Try quit to print error
	                    or prompt_user_to_quit()                            -- or: Prompt to quit

	if should_quit then
		quitall(opts)
	end
end

local function setup_autocmds()
	local command_opts = { force = true, bang = true }

	vim.api.nvim_create_user_command("ConfirmQuit", function(opts)
		M.confirm_quit { bang = opts.bang }
	end, command_opts)
	vim.api.nvim_create_user_command("ConfirmQuitAll", function(opts)
		M.confirm_quit_all { bang = opts.bang }
	end, command_opts)
end

local function setup_abbreviations()
	vim.cmd [[
		" FIX(alexmozaidze): Better function name (I am too bad at naming things)
		function! s:solely_in_cmd(command)
			return (getcmdtype() == ':' && getcmdline() ==# a:command)
		endfunction

		cnoreabbrev <expr> q <SID>solely_in_cmd('q') ? 'ConfirmQuit' : 'q'
		cnoreabbrev <expr> qa <SID>solely_in_cmd('qa') ? 'ConfirmQuitAll' : 'qa'
		cnoreabbrev <expr> qq <SID>solely_in_cmd('qq') ? 'quit' : 'qq'
	]]
end

function M.setup(config)
	assert(
		type(config) == "table" or type(config) == "nil",
		"confirm-quit setup error: expected table or nil, passed " .. type(config)
	)

	options = vim.tbl_deep_extend("force", options, config or {})

	if options.overwrite_q_command then
		setup_abbreviations()
	end

	setup_autocmds()
end

return M
