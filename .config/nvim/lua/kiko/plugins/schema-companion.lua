return {
	"cenk1cenk2/schema-companion.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("schema-companion").setup({
			enable_telescope = true,
			matchers = {},
			schemas = {
				{
					name = "Ubuntu autoinstall",
					uri = "https://raw.githubusercontent.com/canonical/subiquity/refs/heads/main/autoinstall-schema.json",
				},
			},
		})
	end,
}
