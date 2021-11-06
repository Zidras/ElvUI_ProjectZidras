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