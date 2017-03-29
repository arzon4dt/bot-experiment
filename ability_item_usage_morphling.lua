local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castFBDesire = 0;
local castTWDesire = 0;
local castTDDesire = 0;
local castRCDesire = 0;
local castMRADesire = 0;
local castMRSDesire = 0;
local castGhostDesire = 0;
local castEBDesire = 0;
local itemGhost = nil;
local itemEB = nil;
local alreadyCastEB = false;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	abilityFB = npcBot:GetAbilityByName( "morphling_adaptive_strike" );
	abilityTW = npcBot:GetAbilityByName( "morphling_waveform" );
	abilityMRA = npcBot:GetAbilityByName( "morphling_morph_agi" );
	abilityMRS = npcBot:GetAbilityByName( "morphling_morph_str" );
	abilityRC = npcBot:GetAbilityByName( "morphling_replicate" );
	itemGhost = IsItemAvailable("item_ghost");
	itemEB = IsItemAvailable("item_ethereal_blade");
	
	-- Consider using each ability
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castMRADesire = ConsiderMorphAgility();
	castMRSDesire = ConsiderMorphStrength();
	castRCDesire, castRCTarget = ConsiderReplicate();
	castGhostDesire = ConsiderGhostScepter();
	castEBDesire, castEBTarget = ConsiderEtherealBlade();
	
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	
	if ( castEBDesire > 0 ) 
	then
		print("CastEB")
		npcBot:Action_UseAbilityOnEntity( itemEB, castEBTarget );
		alreadyCastEB = true;
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		alreadyCastEB = false;
		return;
	end

	if ( castRCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
		return;
	end
	
	if castMRSDesire > 0 then
		npcBot:Action_UseAbility( abilityMRS );
		return;
	end
	
	if castMRADesire > 0 then
		npcBot:Action_UseAbility( abilityMRA );
		return;
	end
	
	if castGhostDesire > 0 then
		npcBot:Action_UseAbility( itemGhost );
		return;
	end
	
	


end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function IsItemAvailable(item_name)
	local npcBot = GetBot();
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
	
function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castEBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nMinAGIX = abilityFB:GetSpecialValueFloat("damage_min");
	local nMaxAGIX =  abilityFB:GetSpecialValueFloat("damage_max");
	local nMinStun = abilityFB:GetSpecialValueFloat("stun_min");
	local nMaxStun = abilityFB:GetSpecialValueFloat("stun_max");
	local nAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nDamage = 0; 
	local nStun = 0; 
	
	if nAGI > nSTR and ( nAGI - nSTR ) / nSTR >= 0.5 then
		nDamage = nMaxAGIX * nAGI;
	else
		nDamage = nMinAGIX * nAGI;
	end
	
	if nSTR > nAGI and ( nSTR - nAGI ) / nAGI >= 0.5 then
		nStun = nMaxStun;
	else
		nStun = nMinStun;
	end
	
	if alreadyCastEB then
		-- If we're going after someone
		if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  and npcTarget:IsHero() and 
				CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and 
				CanCastFireblastOnTarget( npcEnemy ) and nStun > nMinStun 
				) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and 
				 GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and
				( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth() or nStun > nMinStun )
				)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end	

function ConsiderTimeWalk()

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetCastRange()
	local nCastPoint = abilityTW:GetCastPoint();
	local nSpeed = abilityTW:GetSpecialValueInt("speed");
	local nDamage = abilityTW:GetAbilityDamage();
	local nAttackRange = npcBot:GetAttackRange();

	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < nAttackRange + 200 )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTargetToKill, npcBot )/ nSpeed ) + nCastPoint );
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) > nAttackRange+100 and  GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, npcBot )/ nSpeed ) + nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderMorphAgility()
	
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityMRA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	local nBonusAgi = abilityMRA:GetSpecialValueInt("bonus_attributes");
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);

	if currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) < 2.0 and not abilityMRA:GetToggleState() then
		--print("start")
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) >= 2.0 and abilityMRA:GetToggleState() then
		--print('stop')
		return BOT_ACTION_DESIRE_LOW;
	elseif npcBot:DistanceFromFountain() == 0 and currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then	
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMorphStrength()
	
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityMRS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and not abilityMRS:GetToggleState() then
			--print("Retreat Active")
			return BOT_ACTION_DESIRE_MODERATE;
		elseif tableNearbyEnemyHeroes == nil and #tableNearbyEnemyHeroes < 1 and abilityMRS:GetToggleState() then 	
			--print("Retreat Non Active")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) <= 2.5 and abilityMRS:GetToggleState() then
		--print("Agi Higher Active")
		return BOT_ACTION_DESIRE_LOW;	
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) > 2.5 and not abilityMRS:GetToggleState() then
		--print("Agi Higher Non Active")
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReplicate()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityRC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityRC:GetCastRange();
	local nCastPoint = abilityRC:GetCastPoint();
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 ) then 
			local nMaxAD = 0;
			local target = nil;
			for _,enemy in pairs(tableNearbyEnemyHeroes)
			do
				local enemyAD = enemy:GetAttackDamage();
				if enemyAD > nMaxAD then
					target = enemy;
				end
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and npcTarget:GetHealth()/npcTarget:GetMaxHealth() > 0.5 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end	

function ConsiderGhostScepter()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( itemGhost == nil or not itemGhost:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEtherealBlade()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( itemEB == nil or not itemEB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastFireblastOnTarget(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end