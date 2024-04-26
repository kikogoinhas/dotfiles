local home = os.getenv("HOME")

return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"mfussenegger/nvim-dap",
	},
	cmd = { "DapInstall", "DapUninstall" },
	opts = {
		-- Makes a best effort to setup the various debuggers with
		-- reasonable debug configurations
		automatic_installation = true,

		-- You'll need to check that you have the required things installed
		-- online, please don't ask me how to install them :)
		ensure_installed = {
			-- Update this to ensure that you have the debuggers for the langs you want
			"node-debug2-adapter",
			"javadbg",
			"javatest",
		},
		handlers = {
			function(config)
				-- all sources with no handler get passed here

				-- Keep original functionality
				require("mason-nvim-dap").default_setup(config)
			end,
			javadbg = function(config)
				-- This bundles definition is the same as in the previous section (java-debug installation)

				config["init_options"] = {
					bundles = bundles,
				}

				config.adapters = {
					{
						type = "java",
						request = "attach",
						name = "Debug (Attach) - Remote",
						hostName = "127.0.0.1",
						port = 5005,
					},
				}
				require("mason-nvim-dap").default_setup(config) -- don't forget this!
			end,
			javatest = function(config)
				-- This is the new part

				config["init_options"] = {
					bundles = {
						vim.fn.glob("/java-test/extension/server/com.microsoft.java.test.plugin-*.jar", 1),
					},
				}
			end,
		},
	},
}
