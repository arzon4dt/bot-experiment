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

local castDCDesire = 0;
local castSRDesire = 0;
local castFGDesire = 0;
local castTSDesire = 0;

local abilityDC = nil;
local abilitySR = nil;
local abilityTS = nil;
local abilityFG = nil;

local npcBot = nil;
local tombStone = "";

function AbilityUsageThink()

	if tombStone ~= "" and ( tombStone == nil or tombStone:IsNull() == true or tombStone:IsAlive() == false ) then
		tombStone = "";
	end

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "undying_decay" ) end
	if abilitySR == nil then abilitySR = npcBot:GetAbilityByName( "undying_soul_rip" ) end
	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "undying_tombstone" ) end
	if abilityFG == nil then abilityFG = npcBot:GetAbilityByName( "undying_flesh_golem" ) end
	

	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castSRDesire, castSRTarget = ConsiderSoulRip();
	castTSDesire, castTSLocation = ConsiderTombStone();
	castFGDesire, castFGTarget = ConsiderFleshGolem();
	
	if ( castTSDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTS, castTSLocation );
		return;
	end

	if ( castFGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFG );
		return;
	end

	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	
	if ( castSRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySR, castSRTarget );
		return;
	end
	

end

function ConsiderDecay()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("decay_damage");

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
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)  and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );

		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

local function IsTombStone(unit_name)
	return unit_name == "npc_dota_unit_tombstone1" 
	    or unit_name == "npc_dota_unit_tombstone2"
	    or unit_name == "npc_dota_unit_tombstone3"
	    or unit_name == "npc_dota_unit_tombstone4"
end

local lastTSQuery = -90;
function ConsiderSoulRip()
	
	-- Make sure it's castable
	if ( not abilitySR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilitySR:GetCastRange();
	local maxUnit = abilitySR:GetSpecialValueInt('max_units');
	local nRadius = abilitySR:GetSpecialValueInt('radius');
	local TSHeal = abilitySR:GetSpecialValueInt('tombstone_heal');

	--[[if tombStone == "" and DotaTime() > lastTSQuery + 1.0 then
		local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
		for _,unit in pairs(units) do
			if IsTombStone(unit:GetUnitName()) == true then
				tombStone = unit;
				break;
			end
		end
		lastTSQuery = DotaTime();
	end

	if tombStone ~= "" and tombStone ~= nil and tombStone:IsNull() == false then
		if tombStone:GetHealth() < tombStone:GetMaxHealth() - TSHeal and GetUnitToUnitDistance(tombStone, npcBot) <= nCastRange+200 then
			return BOT_ACTION_DESIRE_MODERATE, tombStone;
		end
	end]]--
	
	local eCreep = npcBot:GetNearbyLaneCreeps(nRadius, true);
	local aCreep = npcBot:GetNearbyLaneCreeps(nRadius, false);
	
	local unitAround = #eCreep + #aCreep;
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200) and unitAround >= 0.5*maxUnit
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcAlly) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and unitAround >= 0.5*maxUnit
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and unitAround >= 0.5*maxUnit
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderFleshGolem()

	-- Make sure it's castable
	if ( not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityFG:GetSpecialValueInt( "radius" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 200)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE  );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderTombStone()

	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nCastPoint = abilityTS:GetCastPoint();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	

	return BOT_ACTION_DESIRE_NONE, 0;
end