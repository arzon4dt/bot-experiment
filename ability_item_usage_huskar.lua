if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local role = require(GetScriptDirectory() .. "/RoleUtility");

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castIVDesire = 0;
local castBSDesire = 0;
local castLBDesire = 0;

local abilityIV = nil;
local abilityBS = nil;
local abilityLB = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityIV == nil then abilityIV = npcBot:GetAbilityByName( "huskar_inner_fire" ) end
	if abilityBS == nil then abilityBS = npcBot:GetAbilityByName( "huskar_burning_spear" ) end
	if abilityLB == nil then abilityLB = npcBot:GetAbilityByName( "huskar_life_break" ) end

	-- Consider using each ability
	castIVDesire, castIVTarget = ConsiderInnerVitality();
	castBSDesire, castBSTarget = ConsiderBurningSpear();
	castLBDesire, castLBTarget = ConsiderLifeBreak();
	

	if ( castLBDesire > castIVDesire and castLBDesire > castBSDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLB, castLBTarget );
		return;
	end

	if ( castIVDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIV );
		return;
	end
	
	if ( castBSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBS, castBSTarget );
		return;
	end

end


function ConsiderInnerVitality()

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityIV:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	local nRadius = abilityIV:GetSpecialValueInt("radius");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-100, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget)  and mutil.CanCastOnNonMagicImmune(npcTarget)  and mutil.IsInRange(npcTarget, npcBot, nRadius-150)
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

local rangeExtension = 250;

function ConsiderBurningSpear()
  
	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	local nDamage = abilityBS:GetAbilityDamage();
	local nRadius = 0;
	local nAttackRange = npcBot:GetAttackRange();
	
	local mode = npcBot:GetActiveMode();	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) or mode == BOT_MODE_LANING or mode == BOT_MODE_DEFEND_TOWER_MID or  mode == BOT_MODE_PUSH_TOWER_MID
	then
		local npcTarget = npcBot:GetTarget();
		
		if npcTarget == nil then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
      
      for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
          if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
          then
            npcTarget = npcEnemy;
            break;
          end
        end
    
      if npcTarget == nil then
        npcTarget = tableNearbyEnemyHeroes[1];
      end
		end
    
    if mode == BOT_MODE_LANING and DotaTime() > 13 and DotaTime() < 100 and npcTarget ~= nil and not role.IsMelee(npcTarget:GetAttackRange()) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end
		
    if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) then
      
      -- sacrefise in teamfight - we have no escape mechanism anyway, but we are good at killing
      if mutil.IsInTeamFight(npcBot, 1200) and npcBot:GetHealth() < npcBot:GetMaxHealth() * 0.34 and mutil.IsInRange(npcTarget, npcBot, nAttackRange) then
          return BOT_ACTION_DESIRE_ABSOLUTE, npcTarget;
      end
      
      -- someone wants to kill us alone
      if npcBot:GetHealth() < npcBot:GetMaxHealth() * 0.30 and mutil.IsInRange(npcTarget, npcBot, nAttackRange * 0.66) and npcTarget:GetHealth() < npcTarget:GetMaxHealth() * 0.7 then
          return BOT_ACTION_DESIRE_ABSOLUTE, npcTarget;
      end
      
      -- be more agressive on meele heroes during laning phase or we can go on ranged heroes from leve 5
      if mutil.IsInRange(npcTarget, npcBot, nAttackRange+rangeExtension+300) and mode == BOT_MODE_LANING 
        and utils.GetDistFromEnemyMidTower() > 1100+rangeExtension and (role.IsMelee(npcTarget:GetAttackRange()) or npcBot:GetLevel() > 4) then
        return BOT_ACTION_DESIRE_HIGH, npcTarget;
      end
      
      
      if mutil.IsInRange(npcTarget, npcBot, nAttackRange+rangeExtension) and (mode ~= BOT_MODE_LANING or utils.GetDistFromEnemyMidTower() > 1050+rangeExtension)  then
        return BOT_ACTION_DESIRE_MODERATE, npcTarget;
      end
      
    end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderLifeBreak()

	-- Make sure it's castable
	if ( not abilityLB:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityLB:GetCastRange();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+rangeExtension)
		then
			return BOT_ACTION_DESIRE_VERYHIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
