local minionutils = dofile( GetScriptDirectory().."/NewMinionUtil" )

function MinionThink(  hMinionUnit ) 
	minionutils.MinionThink(hMinionUnit);
end	
