if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local skills = require(GetScriptDirectory() ..  "/SkillsUtility")
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

local castFBDesire = 0;
local castUFBDesire = 0;
local castIGDesire = 0;
local castTLDesire = 0;

local abilityUFB = nil;
local abilityFB = nil;
local abilityTL = nil;
local abilityIG = nil;
local ability4 = nil;
local ability5 = nil;

local setTarget = false;
local npcBot = nil;
local castUltDelay = 0;
local castUltTime = -90;
local castTeleLandTime = DotaTime();
local lastStolenSpellTarget = "";
local lastSSScepterTime = DotaTime();

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability	
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "rubick_spell_steal" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "rubick_telekinesis" ) end
	if abilityTL == nil then abilityTL = npcBot:GetAbilityByName( "rubick_telekinesis_land" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "rubick_fade_bolt" ) end
	ability4 = npcBot:GetAbilityInSlot(3) 
	ability5 = npcBot:GetAbilityInSlot(4)
	
	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTLDesire, castTLLocation = ConsiderTeleLand();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		castUltTime = DotaTime();
		lastStolenSpellTarget = castUFBTarget:GetUnitName();
		lastSSScepterTime = DotaTime();
		return;
	end

	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		setTarget = false;
		return;
	end
	
	if ( castTLDesire > 0 and not setTarget ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTL, castTLLocation );
		castTeleLandTime = DotaTime();
		setTarget = true;
		return;
	end

	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	skills.CastStolenSpells(ability4);
	skills.CastStolenSpells(ability5);

end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and
           not mutil.IsDisabled(true, npcTarget)		
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTeleLand()
	
	-- Make sure it's castable
	if ( DotaTime() < castTeleLandTime + 0.5 or abilityTL == nil or not abilityTL:IsFullyCastable() or abilityTL:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityTL:GetSpecialValueInt("radius");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront( nCastRange + nRadius );
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderIgnite()

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetSpecialValueInt( "damage" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.75 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and tableNearbyEnemyCreeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderUnrefinedFireblast()

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() or DotaTime() - castUltTime <= castUltDelay ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if not string.find(ability4:GetName(), 'empty') and ability4:GetName() ~= "life_stealer_infest"  and not ability4:IsToggle() and ability4:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();
	local projSpeed = abilityUFB:GetSpecialValueInt('projectile_speed')
	
	if nCastRange + 200 > 1600 then nCastRange = 1600 end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if npcBot:HasScepter() == true then
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local enemies = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			for i=0, #enemies do
				if mutil.IsValidTarget(enemies[i]) and mutil.CanCastOnNonMagicImmune(enemies[i]) 
					and ( ( enemies[i]:GetUnitName() ~= lastStolenSpellTarget ) or ( enemies[i]:GetUnitName() == lastStolenSpellTarget and DotaTime() > lastSSScepterTime + 5.0 ) )
				then
					return BOT_ACTION_DESIRE_HIGH, enemies[i];
				end
			end
		end	
	else
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
			then
				castUltDelay = GetUnitToUnitDistance(npcBot, npcTarget) / projSpeed + ( 2*0.1 ); 
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



