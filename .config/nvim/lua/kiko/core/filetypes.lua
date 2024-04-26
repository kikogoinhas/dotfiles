-- Detects avro schema files as json files
vim.filetype.add({
	extension = {
		avsc = "json",
	},
})

vim.filetype.add({
	extension = {
		gradle = "groovy",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function(args)
		require("kiko.core.lsp.nvim-jdtls-setup").setup()
	end,
})
