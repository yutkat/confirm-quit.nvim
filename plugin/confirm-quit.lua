if vim.g.loaded_confirm_quit ~= nil then
	return
end
vim.g.loaded_confirm_quit = 1

local function is_last_window()
	local wins = vim.api.nvim_list_wins()
	local count = 0
	for i, v in ipairs(wins) do
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

function _G.confirm_quit()
	if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "q" then
		if is_last_window() and vim.fn.tabpagenr("$") == 1 then
			if vim.fn.confirm("Do you want to quit?", "&Yes\n&No", 2) ~= 1 then
				return "false"
			end
		end
	end
	return "true"
end

vim.cmd([[cnoreabbrev <expr> q (luaeval(v:lua.confirm_quit())) ? 'q' : '']])
vim.cmd([[cnoreabbrev qq  quit]])
vim.api.nvim_create_user_command("Q", "qall<bang>", { force = true, bang = true })

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
