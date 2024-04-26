local M = {}

function M.setup()
	local home = os.getenv("HOME")
	local jdtls = require("jdtls")
	local jdtls_dap = require("jdtls.dap")
	local jdtls_setup = require("jdtls.setup")

	local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local root_dir = jdtls_setup.find_root(root_markers)

	local mason_packages_path = home .. "/.local/share/nvim/mason/packages"
	local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
	local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name

	local bundles = {
		vim.fn.glob(
			mason_packages_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			1
		),
	}
	vim.list_extend(
		bundles,
		vim.split(vim.fn.glob(mason_packages_path .. "/java-test/extension/server/*.jar", 1), "\n")
	)

	local on_attach = function(_, bufnr)
		jdtls_dap.setup_dap_main_class_configs()
		jdtls.setup_dap({ hotcodereplace = "auto" })
		jdtls_setup.add_commands()

		local dap = require("dap")
		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Debug (Attach) - Remote",
				hostName = "127.0.0.1",
				port = 5005,
			},
		}
		local opts = { noremap = true, silent = true }
		local keymap = vim.keymap

		-- set keybinds
		opts.desc = "Show LSP references"
		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

		opts.desc = "Show LSP definitions"
		keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>gD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>gd", vim.diagnostic.open_float, opts) -- show diagnostics for line

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

		opts.desc = "Run test class"
		keymap.set("n", "<leader>dM", jdtls.test_class)

		opts.desc = "Run nearest class"
		keymap.set("n", "<leader>dm", jdtls.test_nearest_method)
	end

	local capabilities = {
		workspace = {
			configuration = true,
		},
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	}

	local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	local config = {
		capabilities = capabilities,
		on_attach = on_attach,
		flags = {
			allow_incremental_sync = true,
		},
		eclipse = {
			downloadSources = true,
		},
		maven = {
			downloadSources = true,
		},
		init_options = {
			bundles = bundles,
			extendedClientCapabilities = extendedClientCapabilities,
		},
		root_dir = root_dir,
		-- Here you can configure eclipse.jdt.ls specific settings
		-- These are defined by the eclipse.jdt.ls project and will be passed to eclipse when starting.
		-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
		-- for a list of options
		settings = {
			java = {
				references = {
					includeDecompiledSources = true,
				},
				format = {
					settings = {
						-- Use Google Java style guidelines for formatting
						-- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
						-- and place it in the ~/.local/share/eclipse directory
						url = "/.local/share/eclipse/eclipse-java-google-style.xml",
						profile = "GoogleStyle",
					},
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" }, -- Use fernflower to decompile library code
				-- Specify any completion options
				completion = {
					favoriteStaticMembers = {
						"org.hamcrest.MatcherAssert.assertThat",
						"org.hamcrest.Matchers.*",
						"org.hamcrest.CoreMatchers.*",
						"org.junit.jupiter.api.Assertions.*",
						"java.util.Objects.requireNonNull",
						"java.util.Objects.requireNonNullElse",
						"org.mockito.Mockito.*",
					},
					filteredTypes = {
						"com.sun.*",
						"io.micrometer.shaded.*",
						"java.awt.*",
						"jdk.*",
						"sun.*",
					},
				},
				-- Specify any options for organizing imports
				sources = {
					organizeImports = {
						starThreshold = 9999,
						staticStarThreshold = 9999,
					},
				},
				-- How code generation should act
				codeGeneration = {
					toString = {
						template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
					},
					hashCodeEquals = {
						useJava7Objects = true,
					},
					useBlocks = true,
				},

				-- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
				-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
				-- And search for `interface RuntimeOption`
				-- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
				configuration = {},
			},
		},
		-- cmd is the command that starts the language server. Whatever is placed
		-- here is what is passed to the command line to execute jdtls.
		-- Note that eclipse.jdt.ls must be started with a Java version of 17 or higher
		-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
		-- for the full list of options
		cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx4g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			-- If you use lombok, download the lombok jar and place it in ~/.local/share/eclipse
			"-javaagent:"
				.. home
				.. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",

			-- The jar file is located where jdtls was installed. This will need to be updated
			-- to the location where you installed jdtls
			"-jar",
			vim.fn.glob(mason_packages_path .. "/jdtls/plugins/org.eclipse.equinox.launcher_*.jar", 1),

			-- The configuration for jdtls is also placed where jdtls was installed. This will
			-- need to be updated depending on your environment
			"-configuration",
			home .. "/.local/share/nvim/mason/packages/jdtls/config_mac",

			-- Use the workspace_folder defined above to store data for this project
			"-data",
			workspace_dir,
		},
	}

	-- Start Server
	require("jdtls").start_or_attach(config)

	-- Set Java Specific Keymaps
	-- require("jdtls.keymaps")
end

return M
