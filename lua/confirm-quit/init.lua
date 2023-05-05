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

function M.confirm_quit_cmdline()
	if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() ~= "q" then
		vim.cmd.quit()
	end
	M.confirm_quit()
end

local function setup_cmdline_quit()
	if config.options.overwrite_q_command == true then
		vim.cmd([[cnoreabbrev q lua require('confirm-quit').confirm_quit_cmdline()]])
		vim.cmd([[cnoreabbrev qq  quit]])

		vim.g.confirm_quit_isk_save = ""
		local group_name = "confirm-quit"
		vim.api.nvim_create_augroup(group_name, { clear = true })
		vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
			group = group_name,
			pattern = ":",
			callback = function()
				vim.g.confirm_quit_isk_save = vim.bo.iskeyword
				vim.opt_local.iskeyword:append("!")
			end,
			once = false,
		})
		vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
			group = group_name,
			pattern = ":",
			callback = function()
				vim.bo.iskeyword = vim.g.confirm_quit_isk_save
			end,
			once = false,
		})
	end
end

function M.setup(user_conf)
	config.set(user_conf)
	setup_cmdline_quit()
end

return M
