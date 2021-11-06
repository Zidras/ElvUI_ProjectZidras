local PZ, T, E, L, V, P, G = unpack(select(2, ...))

local strconcat, format = strconcat, string.format

do
	local color = strconcat(PZ.BrandHex, "%s|r")
	function PZ:Color(name)
		return format(color, name)
	end

	local title = PZ:Color(strconcat(PZ.Title, ":"))
	function PZ:Print(...)
		print(title, ...)
	end
end