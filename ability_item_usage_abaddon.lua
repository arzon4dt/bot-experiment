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


local castDCDesire = 0;
local castACDesire = 0;
local npcBot = nil;
local abilityDC = nil;
local abilityAC = nil;

function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "abaddon_death_coil" ) end
	if abilityAC == nil then abilityAC = npcBot:GetAbilityByName( "abaddon_aphotic_shield" ) end

	castACDesire, castACTarget = ConsiderAphoticShield();
	castDCDesire, castDCTarget = ConsiderDeathCoil();

	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end

	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDC, castDCTarget );
		return;
	end
end


function ConsiderDeathCoil()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDC:GetCastRange();
	local nDamage = abilityDC:GetSpecialValueInt("target_damage");
	local nSelfDamage = abilityDC:GetSpecialValueInt("self_damage");
	
	-- If we're seriously retreating, see if we can suicide
	if mutil.IsRetreating(npcBot) and npcBot:GetHealth() <= nSelfDamage
	then
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	if npcBot:HasModifier("modifier_abaddon_borrowed_time") then
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	
	-- If we're in a teamfight, use it on the protect ally
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;
		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAlly) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or mutil.IsDisabled(false, npcAlly) )
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

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			local enemies = npcTarget:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
			if #enemies <= 1 then 
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderAphoticShield()

	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityAC:GetCastRange();

	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 3.0 ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1300)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 10000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnMagicImmune(npcAlly) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or mutil.IsDisabled(false, npcAlly) )
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

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1300) ) 
		then
			local closestAlly = nil;
			local nDist = 10000;

			local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
			for _,npcAlly in pairs( tableNearbyAllies )
			do
				if ( mutil.CanCastOnMagicImmune(npcAlly) )
				then
					local nAllyDist = GetUnitToUnitDistance(npcTarget, npcAlly);
					if nAllyDist < nDist  
					then
						nDist = nAllyDist;
						closestAlly = npcAlly;
					end
				end
			end

			if ( closestAlly ~= nil )
			then
				return BOT_ACTION_DESIRE_MODERATE, closestAlly;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

