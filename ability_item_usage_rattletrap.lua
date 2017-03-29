--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local inspect = require(GetScriptDirectory() ..  "/inspect")
local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )
local teamStatus = require(GetScriptDirectory() .."/team_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local courierTime = 0

----------------------------------------------------------------------------------------------------
--rattletrap_battery_assault
--rattletrap_hookshot
--rattletrap_power_cogs
--rattletrap_rocket_flare

--[[
	local us = GetTeamPlayers( GetTeam() )
	local them
	if math.abs(GetTeam() - 3) then
		them = GetTeamPlayers( 3 )
	else
		them = GetTeamPlayers( 2 )
	end
	local test = {}
	for _,v in pairs(them) do
		table.insert(test, GetSelectedHeroName( v ))
	end
	print(assert(inspect.inspect(test)))

	local test = GetBot():GetNearbyHeroes( 35000, true, BOT_MODE_NONE )
	print(assert(inspect.inspect(test)))
	]]

local castbaDesire = 0;
local castcogsDesire = 0;
local casthookDesire = 0;
local castflareDesire = 0;
local castBlinkInitDesire = 0; 
local castForceEnemyDesire = 0;
function AbilityUsageThink()
	local npcBot = GetBot();
	
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
--[[
	local unit = GetUnitList(UNIT_LIST_ALLIES )
	local tableCogs = {};
	
	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_rattletrap_cog"
		then
			table.insert(tableCogs, u);
		end
	end
	
	if tableCogs ~= nil and #tableCogs == 8 
	then
		local mindist = 1000;
		local cogsTarget = nil;
		local i = 0;
		
		for _,c in pairs (tableCogs)
		do
			local locate = GetUnitToUnitDistance(c, npcBot)
			print(i.."="..locate)
			if locate < mindist 
			then
				mindist = locate;
				cogsTarget = c;
			end
			i = i + 1
		end
		print("-------------------------")
		if cogsTarget ~= nil 
		then
            npcBot:SetActionQueueing( true )
			npcBot:Action_AttackUnit( cogsTarget, false );
			return;
		else
			npcBot:Action_ClearActions( true );
			return
		end
	end
	]]--
	abilityBA = npcBot:GetAbilityByName( "rattletrap_battery_assault" );
	abilityCogs = npcBot:GetAbilityByName( "rattletrap_power_cogs" );
	abilityHook = npcBot:GetAbilityByName( "rattletrap_hookshot" );
	abilityFlare = npcBot:GetAbilityByName( "rattletrap_rocket_flare" );
	itemForce = "item_force_staff";
	itemBlink = "item_blink";
	for i=0, 5 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if(_item == itemBlink) then
				itemBlink = npcBot:GetItemInSlot(i);
			end
			if(_item == itemForce) then
				itemForce = npcBot:GetItemInSlot(i);
			end
		end
	end

	-- Consider using each ability

	castCogsDesire = ConsiderCogs();
	castHookDesire, castHookTarget = ConsiderHook();
	castBADesire = ConsiderAssault();
	castFlareDesire, castFlareTarget = ConsiderFlare();
	castBlinkInitDesire, castBlinkInitTarget = ConsiderBlinkInit();
	castForceEnemyDesire, castForceEnemyTarget = ConsiderForceEnemy();

	local highestDesire = castCogsDesire;
	local desiredSkill = 1;

	if ( castHookDesire > highestDesire) 
		then
			highestDesire = castHookDesire;
			desiredSkill = 2;
	end

	if ( castBADesire > highestDesire) 
		then
			highestDesire = castBADesire;
			desiredSkill = 3;
	end

	if ( castFlareDesire > highestDesire) 
		then
			highestDesire = castFlareDesire;
			desiredSkill = 4;
	end

	if ( castBlinkInitDesire > highestDesire) 
		then
			highestDesire = castBlinkInitDesire;
			desiredSkill = 6;
	end

	if ( castForceEnemyDesire > highestDesire) 
		then
			highestDesire = castForceEnemyDesire;
			desiredSkill = 7;
	end

	--print("desires".. castOrbDesire .. castSilenceDesire .. castPhaseDesire .. castJauntDesire .. castCoilDesire);
	if highestDesire == 0 then return;
    elseif desiredSkill == 1 then 
		npcBot:Action_UseAbility( abilityCogs );
    elseif desiredSkill == 2 then 
		npcBot:Action_UseAbilityOnLocation( abilityHook, castHookTarget );
    elseif desiredSkill == 3 then 
		npcBot:Action_UseAbility( abilityBA );
    elseif desiredSkill == 4 then 
		npcBot:Action_UseAbilityOnLocation( abilityFlare, castFlareTarget );
    elseif desiredSkill == 6 then 
		performBlinkInit( castBlinkInitTarget );
    elseif desiredSkill == 7 then 
		performForceEnemy( castForceEnemyTarget );
	end	

end

----------------------------------------------------------------------------------------------------

function CanCastHookOnTarget( npcTarget )
	return not npcTarget:IsInvulnerable();
end


function CanCastFlareOnTarget( npcTarget )
	return not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastBAOnTarget( npcTarget )
	return npcTarget:CanBeSeen()  and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderAssault()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityBA:GetSpecialValueInt( "radius" );
	local nDamage = 10 * abilityBA:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcTarget in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcTarget, 2.0 ) ) 
			then
				if ( CanCastBAOnTarget( npcTarget ) ) 
				then
				--print("retreat Net")
					return BOT_ACTION_DESIRE_MODERATE
				end
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	-- If enemy is channeling cancel it
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcTarget in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius ) 
		then
			if ( CanCastBAOnTarget( npcTarget ) ) 
			then
			--print("retreat Net")
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	-- If a mode has set a target, and we can kill them, do it
	if ( npcTarget ~= nil  and npcTarget:IsHero() and CanCastBAOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, 2 ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function ConsiderHook()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityHook:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityHook:GetSpecialValueInt( "latch_radius" );
	local speed = abilityHook:GetSpecialValueInt( "speed" );
	local nDamage = abilityHook:GetAbilityDamage();
	local nCastRange = abilityHook:GetCastRange();
	local nCastPoint = abilityHook:GetCastPoint();

	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot)
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if not utils.AreCreepsBetweenMeAndLoc(pLoc, nRadius)  then
				print("Path Clear")
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


----------------------------------------------------------------------------------------------------

function ConsiderFlare()
	local npcBot = GetBot();

	if ( not abilityFlare:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityFlare:GetSpecialValueInt( "radius" );
	local speed = abilityFlare:GetSpecialValueInt( "speed" );
	local nDamage = abilityFlare:GetAbilityDamage();
	local nCastPoint = abilityFlare:GetCastPoint();

	-- farming
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and npcBot:GetMana() > (npcBot:GetMaxMana() * .5)) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local npcTarget = tableNearbyEnemyHeroes[1];

		if ( npcTarget ~= nil ) 
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcTarget:GetLocation(), nRadius * .8, nRadius, 0.0, 20000 );
			--print(locationAoE.count)
			if ( locationAoE.count >= 4 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
		end

		
	end

	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil  )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() )
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	-- harassing

	-- sniping

	-- scouting

	-- check rosh


	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderCogs()	
	
	-- Make sure it's castable
	if ( not abilityCogs:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local npcBot = GetBot();

	local nRadius = abilityCogs:GetSpecialValueInt( "cogs_radius" );
	local nActivationRadius = abilityCogs:GetSpecialValueInt( "trigger_distance" )
	local nDamage = abilityCogs:GetAbilityDamage();

	
	--[[if npcBot:DistanceFromFountain() > 3000 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end]]--

	--if we are laning and enemy is going for a last hit and we're very bored

	--if we are retreating and enemy will be outside cogs
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		for _,npcTarget in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcTarget, 2.0 ) ) 
			then
				if ( CanCastBAOnTarget( npcTarget ) and GetUnitToUnitDistance(npcBot,npcTarget) > nRadius and tableNearbyAllyHeroes == nil ) 
				then
				--print("retreat Net")
					return BOT_ACTION_DESIRE_MODERATE
				end
			end

		end
	end

	--if in a team fight
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius) 
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	--if enemy is under our tower
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1300, false );
	for _,v in pairs(tableNearbyEnemyHeroes) do
		local tower = tableNearbyFriendlyTowers[1];	
		if tower ~= nil then
			if ( GetUnitToUnitDistance( v, tower ) < 700 and GetUnitToUnitDistance( v, npcBot ) < nRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderBlinkInit()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCogs:IsFullyCastable() or
		not abilityBA:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 1200;
	local nRadius = abilityCogs:GetSpecialValueInt( "radius" );

	-- Find a big group to nuke

	local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1300, nRadius, 0, 0 );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local npcTarget = tableNearbyEnemyHeroes[1];	
	if npcTarget ~= nil then
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcTarget, locationAoE.targetloc ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;

end
----------------------------------------------------------------------------------------------------

function ConsiderForceEnemy()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( itemForce == "item_force_staff" or not itemForce:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 800;
	local nPushRange = 600;

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1000, false );
	local npcTarget = tableNearbyEnemyHeroes[1];
	local tower = tableNearbyFriendlyTowers[1];	
	if npcTarget ~= nil and tower ~= nil then
		if ( GetUnitToUnitDistance( npcTarget, tower ) < 1000 ) 
		then
			if(npcTarget:IsFacingUnit( tower, 15 )) then

				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;

end

----------------------------------------------------------------------------------------------------

function performBlinkInit( castBlinkInitTarget )
	local npcBot = GetBot();
	local orbTarget = npcBot:GetLocation();

	if( itemBlink ~= "item_blink" and itemBlink:IsFullyCastable()) then
		npcBot:Action_UseAbilityOnLocation( itemBlink, castBlinkInitTarget);
	end
end

----------------------------------------------------------------------------------------------------

function performForceEnemy( castForceEnemyTarget )
	local npcBot = GetBot();
	npcBot:Action_UseAbilityOnEntity( itemForce, castForceEnemyTarget );
end

----------------------------------------------------------------------------------------------------
