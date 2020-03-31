if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castISDesire = 0;
local castSGDesire = 0;
local castVCDesire = 0;
local castWRDesire = 0;
local abilityIS = "";
local abilitySG = "";
local abilityVC = "";
local abilityWR = "";
local AOESurge = "";
local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityVC == "" then abilityVC = npcBot:GetAbilityByName( "dark_seer_vacuum" ); end
	if abilityIS == "" then abilityIS = npcBot:GetAbilityByName( "dark_seer_ion_shell" ); end
	if abilitySG == "" then abilitySG = npcBot:GetAbilityByName( "dark_seer_surge" ); end
	if abilityWR == "" then abilityWR = npcBot:GetAbilityByName( "dark_seer_wall_of_replica" ); end
	if AOESurge == "" then AOESurge = npcBot:GetAbilityByName( "special_bonus_unique_dark_seer_3" ); end

	-- Consider using each ability
	castVCDesire, castVCLocation = ConsiderVacuum();
	castISDesire, castISTarget = ConsiderIonShell();
	castSGDesire, castSGTarget = ConsiderSurge();
	castWRDesire, castWRLocation = ConsiderWallOfReplica();
	
	if ( castWRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWR, castWRLocation );
		return;
	end
	
	if ( castVCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityVC, castVCLocation );
		return;
	end
	
	if ( castISDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIS, castISTarget );
		return;
	end
	
	if ( castSGDesire > 0 ) 
	then
		if AOESurge:IsTrained() then
			npcBot:Action_UseAbilityOnLocation( abilitySG, castSGTarget:GetLocation() );
			return;
		else	
			npcBot:Action_UseAbilityOnEntity( abilitySG, castSGTarget );
			return;
		end
	end

end

function ConsiderVacuum()

	-- Make sure it's castable
	if ( not abilityVC:IsFullyCastable() or abilityVC:GetLevel() < 2 ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castWRDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityVC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityVC:GetCastRange();
	local nCastPoint = abilityVC:GetCastPoint( );
	local nDamage = abilityVC:GetSpecialValueInt( "damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderIonShell()

	-- Make sure it's castable
	if ( not abilityIS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityIS:GetCastRange();

	-- If we're pushing or defending a lane
	if  mutil.IsDefending(npcBot)
	then
			if npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 then
				local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
				for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
					if ( not myFriend:HasModifier("modifier_dark_seer_ion_shell") and
						 myFriend:GetAttackRange() < 320
						) 
					then
						return BOT_ACTION_DESIRE_MODERATE, myFriend;
					end
				end	
				if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
					return BOT_ACTION_DESIRE_MODERATE, npcBot;
				end
			end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
		end
	end
	
	-- If we're pushing or defending a lane
	if mutil.IsPushing(npcBot) 
	then
		if npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( not myFriend:HasModifier("modifier_dark_seer_ion_shell") and
					 myFriend:GetAttackRange() < 320
					) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			local tableNearbyFriendlyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, false );
			for _,myCreeps in pairs(tableNearbyFriendlyCreeps) do
				if  myCreeps:GetHealth() / myCreeps:GetMaxHealth() >= 0.85 and 
					myCreeps:GetAttackRange() < 320 and 
					not myCreeps:HasModifier("modifier_dark_seer_ion_shell") 
				then
					return BOT_ACTION_DESIRE_MODERATE, myCreeps;
				end
			end
			if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( not myFriend:HasModifier("modifier_dark_seer_ion_shell")   and 
					 myFriend:GetAttackRange() < 320 )
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSurge()

	-- Make sure it's castable
	if ( not abilitySG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilitySG:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
		if mutil.IsRetreating(myFriend) and myFriend:WasRecentlyDamagedByAnyHero(2.0)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			local ClosestDist = GetUnitToUnitDistance(npcTarget, npcBot);
			local ClosestBot = npcBot; 
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				local dist = GetUnitToUnitDistance(npcTarget, myFriend);
				if dist < ClosestDist and dist < nCastRange then
					ClosestDist = dist;
					ClosestBot = myFriend;
				end
			end	
			return BOT_ACTION_DESIRE_MODERATE, ClosestBot;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWallOfReplica()

	-- Make sure it's castable
	if ( not abilityWR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	

	-- Get some of its values
	local nRadius = abilityVC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWR:GetCastRange();
	local nCastPoint = abilityWR:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local targetAllies = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if targetAllies ~= nil and #targetAllies >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end