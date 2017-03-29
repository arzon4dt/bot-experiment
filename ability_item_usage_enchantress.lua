--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

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
local castTDDesire = 0;
local castBSDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	abilityFB = npcBot:GetAbilityByName( "enchantress_enchant" );
	abilityTD = npcBot:GetAbilityByName( "enchantress_natures_attendants" );
	abilityBS = npcBot:GetAbilityByName( "enchantress_impetus" );

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTDDesire = ConsiderTimeDilation();
	castBSDesire, castBSTarget = ConsiderBurningSpear();
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end
	if ( castBSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBS, castBSTarget );
		return;
	end

end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastBurningSpearOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastFireblastOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	local maxHP = 0;
	local NCreep = nil;
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 1000 );
	if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP and not neutral:IsAncientCreep()
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	end
	
	if NCreep ~= nil then
		return BOT_ACTION_DESIRE_LOW, NCreep;
	end	
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if  npcTarget ~= nil and 
			npcTarget:IsHero() and 
			CanCastFireblastOnTarget( npcTarget ) and 
			GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderTimeDilation()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and ( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.65 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and ( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.65) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBurningSpear()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastBurningSpearOnTarget( npcTarget ) and GetUnitToUnitDistance(npcTarget,npcBot) > 250 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end