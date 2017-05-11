local npcBot = nil;

function  MinionThink(  hMinionUnit ) 
	
	if npcBot == nil then npcBot = GetBot(); end
	
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 	
		if hMinionUnit:GetUnitName() == "npc_dota_techies_remote_mine" then
		
			local abilityOO = hMinionUnit:GetAbilityByName( "techies_remote_mines_self_detonate" ); 
			
			local nRadius = abilityOO:GetSpecialValueInt( "radius" );
			local numHeroes = 0;
			local nearbyHeroes = hMinionUnit:GetNearbyHeroes(nRadius - 100, true, BOT_MODE_NONE) 
			
			for _,h in pairs (nearbyHeroes)
			do
				if h:IsHero() then
					numHeroes = numHeroes + 1;
				end
			end
			
			if numHeroes >= 1 then
				hMinionUnit:Action_UseAbility(abilityOO)
				return
			end
			
			local nearbyCreeps = hMinionUnit:GetNearbyLaneCreeps(nRadius - 50, true) 
			if nearbyCreeps ~= nil and #nearbyCreeps >= 5 then
				hMinionUnit:Action_UseAbility(abilityOO)
				return
			end
			
		end
	end
end
