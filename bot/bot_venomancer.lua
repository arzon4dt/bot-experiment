local minionutils = dofile( GetScriptDirectory().."/NewMinionUtil" )

local bot = GetBot();

function MinionThink(  hMinionUnit ) 
	minionutils.MinionThink(bot, hMinionUnit);
end	