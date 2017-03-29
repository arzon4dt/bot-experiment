local X = {}


function X.CastNeutralSpellDesire(hUnit, sAbility)

	local Desire = 0;
	if sAbility == "harpy_storm_chain_lightning" then
		local Desire = ConsiderHarpyChainLightning(hUnit); 
		return Desire;
	end

end

function ConsiderHarpyChainLightning(hUnit)
	local npcBot = GetBot();
	
	local ability = hUnit:GetAbilityByName( "harpy_storm_chain_lightning" );	
	if not ability:IsFullyCastable()  then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local nCastRange = ability:GetCastRange();
	
	local enemies = hUnit:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	if enemies[1] ~= nil then
		return BOT_ACTION_DESIRE_HIGH, enemies[1];
	end
		
	
	return BOT_ACTION_DESIRE_NONE, {};
end



return X