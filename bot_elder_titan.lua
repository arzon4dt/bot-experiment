local castSCDesire = 0;
local ReturnDesire = 0;
local MoveDesire = 0;
local ReturnTime = 0;

function  MinionThink(  hMinionUnit ) 
	--print(hMinionUnit:GetUnitName());
	local npcBot = GetBot();
if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	if hMinionUnit:GetUnitName() == "npc_dota_elder_titan_ancestral_spirit" and npcBot:IsAlive() then
	
		if ( npcBot:IsUsingAbility() or hMinionUnit:IsUsingAbility() or npcBot:IsChanneling() or hMinionUnit:IsChanneling() ) then return end
	
		abilitySC = npcBot:GetAbilityByName( "elder_titan_echo_stomp" );
		abilityRT = npcBot:GetAbilityByName( "elder_titan_return_spirit" );
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		ReturnDesire = Return(hMinionUnit); 
		castSCDesire = ConsiderSlithereenCrush(hMinionUnit);
		
		
		if ( MoveDesire > 0  )
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
		if ( castSCDesire > 0 ) 
		then
			npcBot:Action_UseAbility( abilitySC );
			return;
		end
		
		if ( ReturnDesire > 0 and DotaTime() <= ReturnTime + 0.1  ) 
		then
			npcBot:Action_UseAbility( abilityRT );
			ReturnTime = DotaTime();
			return;
		end
		
	end
end
	
end

function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function Return(hMinionUnit)

	if castSCDesire > 0
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if abilityRT:IsFullyCastable() and not abilityRT:IsHidden() and abilitySC:GetCooldownTimeRemaining() > 4 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderSlithereenCrush(hMinionUnit)

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt( "stomp_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastSlithereenCrushOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local locationAoE = hMinionUnit:FindAoELocation( true, false, hMinionUnit:GetLocation(), 0, nRadius, 0, 1500 );
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( hMinionUnit, locationAoE.targetloc ) < nRadius - 200 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( hMinionUnit, npcTarget ) < nRadius - 200 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderMove(hMinionUnit)
	
	if ( castSCDesire > 0 or ReturnDesire > 0 or abilitySC:GetCooldownTimeRemaining() <= 4 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local radius = 350;
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( radius, true, BOT_MODE_NONE );
	
	if NearbyEnemyHeroes[1] == nil then
		local location = Vector(0, 0)
		if GetTeam( ) == TEAM_DIRE then
			location = RB;
		end
		if GetTeam( ) == TEAM_RADIANT then
			location = DB;
		end
		return BOT_ACTION_DESIRE_MODERATE, location;
	else
		return BOT_ACTION_DESIRE_MODERATE, NearbyEnemyHeroes[1]:GetLocation();
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end