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

local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local castPWDesire = 0;

local abilityDP = nil;
local abilityPC = nil;
local abilitySD = nil;
local abilityPW = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) or npcBot:HasModifier('modifier_templar_assassin_meld') then return end

	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "templar_assassin_refraction" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "templar_assassin_meld" ) end
	if abilitySD == nil then abilitySD = npcBot:GetAbilityByName( "templar_assassin_trap" ) end
	if abilityPW == nil then abilityPW = npcBot:GetAbilityByName( "templar_assassin_psionic_trap" ) end

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castPCDesire = ConsiderPounce();
	castPWDesire, castPWLocation = ConsiderPlagueWard();
	
	if ( castPWDesire > 0 )
	then
		npcBot:Action_UseAbilityOnLocation( abilityPW, castPWLocation );
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	

end


function ConsiderDarkPact()

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityDP:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRange)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if mutil.IsPushing(npcBot) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nRange, 400, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPounce()

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityPC:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;
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
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPlagueWard()

	-- Make sure it's castable
	if ( not abilityPW:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local mandateTrapLoc = {
		Vector(-982, 688),
		Vector(-230, 15),
		Vector(-1750, 1250),
		Vector(2600, -2032),
		Vector(-260, 1788),
		Vector(3180, 250),
		Vector(-2350, 177),
		Vector(980, 2514)
	}
	
	-- Get some of its values
	--local nRadius abilityPW:GetSpecialValueInt( "radius" );

	--^Special Value

	local nCastRange = abilityPW:GetCastRange();
	local nCastPoint = abilityPW:GetCastPoint();

	local creeps = npcBot:GetNearbyCreeps(1000, true)
	local enemyHeroes = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	--[[
	for _,loc in pairs(mandateTrapLoc)
	do
		if GetUnitToLocationDistance(npcBot, loc) < nCastRange then
			local exsit = false;
			local listTrap = GetUnitList(UNIT_LIST_ALLIES);
			for _,unit in pairs(listTrap)
			do
				if unit:GetUnitName() ==  "npc_dota_templar_assassin_psionic_trap" then
					local x = unit:GetLocation().x;
					local y = unit:GetLocation().y;
					if Vector(x, y) == loc then
						exist = true;
						break;
					end
				end
			end
			if not exist then
				return BOT_ACTION_DESIRE_LOW, loc;
			end	
		end
	end
	]]--

	return BOT_ACTION_DESIRE_NONE, 0;
end
