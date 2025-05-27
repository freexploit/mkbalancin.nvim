local ts_utils = require("nvim-treesitter.ts_utils")
local parsers = require('nvim-treesitter.parsers')
local ts = vim.treesitter


local M = {}

function M.toggle_checkbox()

    local bufnum = vim.fn.getpos(".")[1]
    local lnum = vim.fn.getpos(".")[2]

    local parser = parsers.get_parser(bufnum)
    local tree = parser:parse({lnum,lnum})[1]
    local lang = parser:lang()
    local root = tree:root()


    local qs = [[ (list (list_item) @item) ]]
    local query = ts.query.parse(lang, qs)
    for _, match,_ in query:iter_matches(root,0,0,-1) do

        local start_row, _, _, _ = match[1][1]:range()

        if start_row +1 == lnum then
            for node, _ in match[1][1]:iter_children() do
                if node:type() == "task_list_marker_unchecked" then
                    local start_row, start_col, end_row, end_col = node:range()
                    vim.api.nvim_buf_set_text(
                        vim.api.nvim_get_current_buf(),
                        start_row,
                        start_col,
                        end_row,
                        end_col,
                        { "[x]" }
                    )
                end
                if node:type() == "task_list_marker_checked" then
                    local start_row, start_col, end_row, end_col = node:range()
                    vim.api.nvim_buf_set_text(
                        vim.api.nvim_get_current_buf(),
                        start_row,
                        start_col,
                        end_row,
                        end_col,
                        { "[ ]" }
                    )
                end
            end
        end

    end
end

function M.setup(opts)
	opts = opts or {}
	vim.keymap.set("n", "<Leader>h", function()
			M.toggle_checkbox()
	end)
end

return M
