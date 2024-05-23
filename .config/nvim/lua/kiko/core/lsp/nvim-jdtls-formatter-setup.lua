local home = os.getenv("HOME")

local setup = function()
	local url =
		"https://github.com/google/google-java-format/releases/download/v1.22.0/google-java-format-1.22.0-all-deps.jar"
	local jarFile = "google-java-format.jar"
	local jarFilePath = home .. "/.local/share/nvim/" .. jarFile
	local downloadCmd = "curl -sLo " .. jarFilePath .. " " .. url

	local function file_exists(filename)
		local file = io.open(filename, "r")
		if file then
			file:close()
			return true
		else
			return false
		end
	end

	if not file_exists(jarFilePath) then
		assert(io.popen(downloadCmd))
	end

	require("formatter").setup({
		filetype = {
			java = {
				function()
					return {
						exe = "java",
						args = {
							"-jar",
							jarFilePath,
							vim.api.nvim_buf_get_name(0),
						},
						stdin = true,
					}
				end,
			},
		},
	})
end

return setup
