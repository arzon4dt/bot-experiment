local utils = require(GetScriptDirectory() .. "/util")
----------------------------------------------------------------------------------------------------
local X = {}

local tableMeepos = {}
local isFarmed = false
----------------------------------------------------------------------------------------------------
--know thy enemy
function X.AddMeepo ( meepo )
	table.insert(tableMeepos, meepo)
	--utils.print_r(tableMeepos)
end

----------------------------------------------------------------------------------------------------
--know thy enemy
function X.GetMeepos ()
	return tableMeepos
end

----------------------------------------------------------------------------------------------------
--know thy enemy
function X.GetIsFarmed()
	return isFarmed
end

----------------------------------------------------------------------------------------------------
--know thy enemy
function X.SetIsFarmed( bFarmed )
	isFarmed = bFarmed
end

----------------------------------------------------------------------------------------------------

return X