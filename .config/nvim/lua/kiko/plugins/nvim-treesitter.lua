return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			-- import nvim-treesitter plugin
			local treesitter = require("nvim-treesitter.configs")

			-- Go Template filetype detection
			vim.api.nvim_create_autocmd({
				"BufNewFile",
				"BufRead",
			}, {
				pattern = "*.tpl,*.tmpl",
				callback = function()
					if vim.fn.search("{{.\\+}}", "nw") ~= 0 then
						local buf = vim.api.nvim_get_current_buf()
						vim.api.nvim_buf_set_option(buf, "filetype", "gotmpl")
					end
				end,
			})

			vim.api.nvim_create_autocmd({
				"BufNewFile",
				"BufRead",
			}, {
				pattern = "Tiltfile*",
				callback = function()
					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_set_option(buf, "filetype", "starlark")
				end,
			})

			vim.api.nvim_create_autocmd({
				"BufNewFile",
				"BufRead",
			}, {
				pattern = "*.tf,*.hcl",
				callback = function()
					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_set_option(buf, "filetype", "terraform")
				end,
			})

			-- configure treesitter
			treesitter.setup({ -- enable syntax highlighting
				highlight = {
					enable = true,
				},
				-- enable indentation
				indent = { enable = true },
				-- enable autotagging (w/ nvim-ts-autotag plugin)
				autotag = {
					enable = true,
				},
				-- ensure these language parsers are installed
				ensure_installed = {
					"json",
					"javascript",
					"typescript",
					"tsx",
					"yaml",
					"html",
					"css",
					"prisma",
					"markdown",
					"markdown_inline",
					"svelte",
					"graphql",
					"bash",
					"lua",
					"vim",
					"python",
					"dockerfile",
					"gitignore",
					"query",
					"hcl",
					"terraform",
					"kotlin",
					"scala",
					"groovy",
					"java",
					"gotmpl",
					"starlark",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-s>",
						node_incremental = "<C-s>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
				context_commentstring = {
					enable = false,
					enable_autocmd = false,
				},
			})
		end,
	},
}
