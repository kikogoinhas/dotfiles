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
			"codelldb",
			"python",
		},
		handlers = {
			function(config)
				-- all sources with no handler get passed here

				-- Keep original functionality
				require("mason-nvim-dap").default_setup(config)
			end,
			python = function(config)
				local venv = os.getenv("VIRTUAL_ENV")
				local command = "python"

				local handle = io.popen("whereis -q python")

				if handle ~= nil then
					command = handle:read("*a")
					handle:close()
				end

				if venv ~= nil then
					local venvPython = venv .. "/bin/python"
					command = venvPython
				end

				config.adapters = {
					type = "executable",
					command = command,
					args = {
						"-m",
						"debugpy.adapter",
					},
				}
				require("mason-nvim-dap").default_setup(config) -- don't forget this!
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
				require("mason-nvim-dap").default_setup(config) -- don't forget this!
			end,
			codelldb = function(config)
				config.configurations = {
					{
						name = "LLDB: Launch",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
						args = function()
							args = vim.fn.input("Args: ")
							return vim.split(args, " ")
						end,
						console = "integratedTerminal",
					},
				}
				require("mason-nvim-dap").default_setup(config) -- don't forget this!
			end,
		},
	},
}
