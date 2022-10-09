local MAJOR_VERSION = "LibGetEnchant-1.0-WrathArmory"
local MINOR_VERSION = 3
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

function lib.GetEnchant(enchantID)
	local enchant = tonumber(enchantID)
	if LibGetEnchantDB[enchant] ~= nil then
		return LibGetEnchantDB[enchant]
	end
end
