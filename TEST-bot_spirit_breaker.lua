--ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )


--[[function Think(   ) 
	--ability_item_usage_generic.AbilityLevelUpThink(); 
	AbilityUsageThink();
	AbilityLevelUpThink();
end]]--

function AbilityLevelUpThink()
print( GetBot():GetAbilityPoints() )
end

castDRDesire = 0;
castSCDesire = 0;
castSPDesire = 0;
castDPDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	--if ( npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") ) then print("Idle") npcBot:Action_ClearActions( true )  end;
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() and npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") ) then return end;

	abilityDR = npcBot:GetAbilityByName( "spirit_breaker_charge_of_darkness" );
	abilitySC = npcBot:GetAbilityByName( "spirit_breaker_empowering_haste" );
	--abilitySP = npcBot:GetAbilityByName( "spirit_breaker_greater_bash" );
	abilityDP = npcBot:GetAbilityByName( "spirit_breaker_nether_strike" );

	-- Consider using each ability
	castDRDesire, castDRTarget = ConsiderDisruption();
	--castSCDesire, castSCLocation = ConsiderSoulCatcher();
	--castSPDesire, castSPLocation = ConsiderShadowPoison();
	castDPDesire, castDPTarget = ConsiderDemonicPurge();

	if ( castDRDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityDR, castDRTarget );
		--npcBot:Action_ClearActions( false )
		return;
	end

	--[[if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySC, castSCLocation );
		return;
	end]]--
	
	--[[if ( castSPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySP, castSPLocation );
		return;
	end]]--
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDP, castDPTarget );
		return;
	end

end

function CanCastDisruptionOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastSoulCatcherOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune();
end

function CanCastShadowPoisonOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastDemonicPurgeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderDisruption()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = 1000;
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	--print("charge")
			for i = 1, #numPlayer
			do
				local enemies = GetTeamMember(i):GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
				for _,enemy in pairs(enemies)
				do
					if enemy:CanBeSeen() then
						return BOT_ACTION_DESIRE_MODERATE, enemy;
					end
				end
			end
	

	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastDisruptionOnTarget ( npcEnemy ) and not enemyDisabled( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDisruptionOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil and CanCastDisruptionOnTarget( npcMostDangerousEnemy ) and not enemyDisabled( npcMostDangerousEnemy )  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastDisruptionOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange and not enemyDisabled( npcTarget ))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderSoulCatcher()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySC:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and CanCastSoulCatcherOnTarget( npcTarget ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShadowPoison()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySP:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilitySP:GetSpecialValueInt("radius");
	local nCastRange = abilitySP:GetCastRange();
	local nCastPoint = abilitySP:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If mana is full and we're laning just hit hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana()/npcBot:GetMaxMana() >= 0.6  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation() + tableNearbyEnemyHeroes[1]:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() >= 0.6 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 and  npcBot:GetMana()/npcBot:GetMaxMana() >= 0.6 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			if ( CanCastShadowPoisonOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation() + npcTarget:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderDemonicPurge()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityDP:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastDemonicPurgeOnTarget ( npcEnemy ) and not enemyDisabled( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDemonicPurgeOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil and CanCastDemonicPurgeOnTarget( npcMostDangerousEnemy ) and not enemyDisabled( npcMostDangerousEnemy )  )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcMostDangerousEnemy;
		end
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastDemonicPurgeOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange and not enemyDisabled( npcTarget ))
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
