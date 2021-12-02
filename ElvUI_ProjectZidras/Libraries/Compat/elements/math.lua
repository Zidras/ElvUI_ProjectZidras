local parent, ns = ...
local Compat = ns.Compat
local Epsilon = 0.000001

local min, max, abs, floor, ceil = math.min, math.max, math.abs, math.floor, math.ceil

function Compat.Lerp(startValue, endValue, amount)
	return (1 - amount) * startValue + amount * endValue
end

function Compat.Round(value)
	return (value < 0) and ceil(value - 0.5) or floor(value + 0.5)
end

function Compat.Clamp(value, minValue, maxValue)
	return min(maxValue or 1, max(minValue or 0, value))
end

function Compat.Saturate(value)
	return Compat.Clamp(value, 0.0, 1.0)
end

function Compat.WithinRange(value, minValue, maxValue)
	return (value >= minValue and value <= maxValue)
end

function Compat.WithinRangeExclusive(value, minValue, maxValue)
	return (value > minValue and value < maxValue)
end

function Compat.ApproximatelyEqual(v1, v2, epsilon)
	return abs(v1 - v2) < (epsilon or Epsilon)
end

function Compat.PercentageBetween(value, startValue, endValue)
	return (startValue == endValue) and 0.0 or ((value - startValue) / (endValue - startValue))
end

function Compat.ClampedPercentageBetween(value, startValue, endValue)
	return Compat.Saturate(Compat.PercentageBetween(value, startValue, endValue))
end

function Compat.BreakUpLargeNumbers(value, dobreak)
	local retString = ""
	if value < 1000 then
		if (value - floor(value)) == 0 then
			return value
		end
		local decimal = floor(value * 100)
		retString = strsub(decimal, 1, -3)
		retString = retString .. "."
		retString = retString .. strsub(decimal, -2)
		return retString
	end

	value = floor(value)
	local strLen = strlen(value)
	if dobreak then
		if (strLen > 6) then
			retString = strsub(value, 1, -7) .. ","
		end
		if (strLen > 3) then
			retString = retString .. strsub(value, -6, -4) .. ","
		end
		retString = retString .. strsub(value, -3, -1)
	else
		retString = value
	end
	return retString
end

function Compat.AbbreviateLargeNumbers(value)
	local strLen = strlen(value)
	local retString = value
	if strLen > 8 then
		retString = strsub(value, 1, -7) .. SECOND_NUMBER_CAP
	elseif strLen > 5 then
		retString = strsub(value, 1, -4) .. FIRST_NUMBER_CAP
	elseif strLen > 3 then
		retString = Compat.BreakUpLargeNumbers(value)
	end
	return retString
end