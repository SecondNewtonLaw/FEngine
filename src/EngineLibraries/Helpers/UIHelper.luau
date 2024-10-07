local UIHelper = {}

function UIHelper.GetPercentageSize(xPercentage: number, yPercentage: number): UDim2
	assert(
		typeof(xPercentage) == "number" and typeof(yPercentage) == "number",
		"xPercentage and yPercentage must be of type number"
	)

	-- Whilst xPercentage and yPercentage should be normalized, it is understood that it may be required in some cases to go further than 1.0 (100%), thus
	-- we cannot really guarantee that it is normalized (between 0 or 1).

	return UDim2.fromScale(xPercentage, yPercentage)
end

return UIHelper
