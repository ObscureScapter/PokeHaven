-- Here for documentation purposes

local ohTable1 = {
	["DrinkColor"] = Color3.new(0.178833, 0.669767, 0.243887),
	["DrinkLevel"] = -math.huge,
	["DrinkMaterial"] = Enum.Material.Granite,
	["DrinkData"] = {
		[1] = "Orange Juice",
        [2] = "Cranberry Juice"
	},
	["DrinkName"] = "Always Sober",
	["Product"] = 1891641113
}

game:GetService("ReplicatedStorage").Remotes.DrinkMaker.VerifyRecipe:InvokeServer(ohTable1)
