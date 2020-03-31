local U = {};

local maxGetRange   = 1600;
local maxAddedRange = 200;
local baseSpamPct   = 0.55;
local RB = Vector(-7174.000000, -6671.00000,  0.000000)
local DB = Vector( 7023.000000,  6450.000000, 0.000000)

local team    = GetTeam();
local teamIds = GetTeamPlayers(team); 

local opposing_team = GetOpposingTeam();
local enemyIds      = GetTeamPlayers(opposing_team); 

print(tostring(team)..tostring(#teamIds))
print(tostring(opposing_team)..tostring(#enemyIds))

------------------hUnit UTILITY

function U.CantUseAbility(hUnit)
	return hUnit:NumQueuedActions() > 0 
	    or hUnit:IsAlive() == false 
	    or hUnit:IsInvulnerable() 
	    or hUnit:IsCastingAbility() or hUnit:IsUsingAbility() or hUnit:IsChanneling()  
	    or hUnit:IsSilenced() or hUnit:IsStunned() or hUnit:IsHexed() or hUnit:IsNightmared() or U.IsTaunted(hUnit) 
	    or hUnit:HasModifier("modifier_doom_bringer_doom") or hUnit:HasModifier('modifier_item_forcestaff_active')
end

function U.IsTaunted(hUnit)
	return hUnit:HasModifier("modifier_axe_berserkers_call") 
	    or hUnit:HasModifier("modifier_legion_commander_duel") 
	    or hUnit:HasModifier("modifier_winter_wyvern_winters_curse") 
		or hUnit:HasModifier(" modifier_winter_wyvern_winters_curse_aura");
end

function U.IsRetreating(hUnit)
	return hUnit:GetActiveMode() == BOT_MODE_RETREAT 
	   and hUnit:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH 
	   and U.IsEnemyNearLoc(hUnit:GetLocation(), 1000, 1.0) == true
end

function U.IsInTeamFight(hUnit, nRadius)
	return U.GetAttackingAllies(hUnit, nRadius) >= 2;
end

function U.IsDefending(hUnit)
	local mode = hUnit:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end

function U.IsPushing(hUnit)
	local mode = hUnit:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end

function U.IsGoingAfterSomeone(unit)
	local mode = unit:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_GANK or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end

function U.HaveData(hUnit, sType)
	if sType == 'enemy' then
		return #hUnit.data.enemies > 0;
	elseif sType == 'ally' then
		return #hUnit.data.allies > 0;
	elseif sType == 'ecreep' then
		return #hUnit.data.e_creeps > 0;	
	elseif sType == 'acreep' then
		return #hUnit.data.a_creeps > 0;	
	end
end

function U.GetDataCount(hUnit, sType)
	if sType == 'enemy' then
		return #hUnit.data.enemies;
	elseif sType == 'ally' then
		return #hUnit.data.allies;
	elseif sType == 'ecreep' then
		return #hUnit.data.e_creeps;	
	elseif sType == 'acreep' then
		return #hUnit.data.a_creeps;	
	end
end

function U.IsSuspiciousIllusion(hUnit)
	return hUnit:IsIllusion();
end

function U.IsValidEntity(hUnit)
	return hUnit ~= nil 
	   and hUnit:IsNull() == false 	
	   and hUnit:CanBeSeen() 
	   and hUnit:IsAlive() 
	   and hUnit:IsInvulnerable() == false; 
end

function U.IsValidHero(hUnit)
	return U.IsValidEntity(hUnit) 
	   and hUnit:IsHero();
end

function U.HasForbiddenModifier(hUnit)
	return hUnit:HasModifier('modifier_winter_wyvern_winters_curse')
		or hUnit:HasModifier('modifier_winter_wyvern_winters_curse_aura')
end

function U.IsUnitAttackingHero(unit)
	local attackTarget = unit:GetAttackTarget();
	return attackTarget ~= nil and attackTarget:IsHero();
end

function U.GetDistanceSquare(vSource, vTarget)
	return ((vTarget.x - vSource.x)*(vTarget.x - vSource.x)) + ((vTarget.y - vSource.y)*(vTarget.y - vSource.y));
end

function U.IsInCastRange(hUnit, hTarget, nCastRange)
	return GetUnitToUnitDistanceSqr(hUnit, hTarget) <= nCastRange*nCastRange;
end

function U.IsWithinRadius(hUnit, vLoc, nRadius)
	return GetUnitToLocationDistance(hUnit, vLoc) <= nRadius;
end

function U.IsTaunted(hUnit)
	return hUnit:HasModifier("modifier_axe_berserkers_call") 
	    or hUnit:HasModifier("modifier_legion_commander_duel") 
	    or hUnit:HasModifier("modifier_winter_wyvern_winters_curse") 
		or hUnit:HasModifier("modifier_winter_wyvern_winters_curse_aura");
end

function U.IsAllyDisabled(hUnit)
	return hUnit:IsRooted( ) 
		or hUnit:IsStunned( ) 
		or hUnit:IsHexed( ) 
		or hUnit:IsNightmared() 
		or hUnit:IsSilenced( ) 
		or U.IsTaunted(hUnit);
end

function U.IsEnemyDisabled(hUnit)
	return hUnit:IsRooted( ) 
		or hUnit:IsStunned( ) 
		or hUnit:IsHexed( ) 
		or hUnit:IsNightmared()  
		or U.IsTaunted(hUnit);
end

function U.IsStuck(hUnit)
	if hUnit.stuckLoc ~= nil and hUnit.stuckTime ~= nil then 
		local attackTarget = hUnit:GetAttackTarget();
		local EAd = GetUnitToUnitDistance(hUnit, GetAncient(opposing_team));
		local TAd = GetUnitToUnitDistance(hUnit, GetAncient(team));
		local Et  = hUnit:GetNearbyTowers(450, true);
		local At  = hUnit:GetNearbyTowers(450, false);
		if  hUnit:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO 
			and attackTarget == nil 	
			and EAd > 2200 and TAd > 2200 
			and #Et == 0 and #At == 0  
		    and DotaTime() > hUnit.stuckTime + 5.0 and GetUnitToLocationDistance(hUnit, hUnit.stuckLoc) < 25    
		then
			--print(hUnit:GetUnitName().." is stuck")
			return true;
		end
	end
	return false
end

------------------ENEMY UTILITIES

function U.IsEnemyNearLoc(vLoc, nRadius, fTime)
	for i=1,#enemyIds do
		if IsHeroAlive(enemyIds[i]) then
			local info = GetHeroLastSeenInfo(enemyIds[i]);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and U.GetDistanceSquare(vLoc, dInfo.location) <= (nRadius*nRadius) and dInfo.time_since_seen <= fTime then
					return true;
				end
			end
		end
	end
	return false;
end

function U.GetEnemyNearLocByInfo(vLoc, nRadius, fTime)
	for i=1,#enemyIds do
		if IsHeroAlive(enemyIds[i]) then
			local info = GetHeroLastSeenInfo(enemyIds[i]);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and U.GetDistanceSquare(vLoc, dInfo.location) <= (nRadius*nRadius) and dInfo.time_since_seen <= fTime then
					return dInfo.location;
				end
			end
		end
	end
	return nil;
end

function U.GetEnemyNearLoc(hUnit, vLoc, nRadius)
	if U.HaveData(hUnit, 'enemy') then
		for i=1, #hUnit.data.enemies do
			local unit = hUnit.data.enemies[i];
			if U.IsValidEntity(unit) and U.IsWithinRadius(unit, vLoc, nRadius) 
			   and U.CanCastOnNonMagicImmune(unit)
			then
				return unit;
			end
		end
	end
	return nil;
end

function U.GetWeakestEnemy(hUnit, nRadius)
	local weakest = nil;
	local minHP = 10000;
	if U.HaveData(hUnit, 'enemy') then
		for i=1, #hUnit.data.enemies do
			local unit = hUnit.data.enemies[i];
			if U.IsValidEntity(unit) and U.IsInCastRange(hUnit, unit, nRadius) 
			   and U.CanCastOnNonMagicImmune(unit) and unit:GetHealth() <= minHP 
			then
				weakest = unit;
				minHP = unit:GetHealth();
			end
		end
	end
	return weakest;
end

------------------ALLY UTILITIES


function U.GetAttackingAllies(hUnit, nRadius)
	local count = 0;
	if U.HaveData(hUnit, 'ally') then
		for i=1, #hUnit.data.allies do
			local unit = hUnit.data.allies[i];
			if U.IsValidEntity(unit) and ( unit:GetActiveMode() == BOT_MODE_ATTACK or U.IsUnitAttackingHero(unit) ) then
				count = count + 1;
			end
		end
	end
	return count;
end

function U.GetWeakestAlly(hUnit, nRadius)
	local weakest = nil;
	local minHP = 10000;
	if U.HaveData(hUnit, 'ally') then
		for i=1, #hUnit.data.allies do
			local unit = hUnit.data.allies[i];
			if U.IsValidEntity(unit) 
			   and unit ~= hUnit	
			   and U.IsInCastRange(hUnit, unit, nRadius) 
			   and U.CanCastOnNonMagicImmune(unit) and unit:GetHealth() <= minHP 
			then
				weakest = unit;
				minHP = unit:GetHealth();
			end
		end
	end
	return weakest;
end

function U.GetClosestAlly(hUnit, hTarget, nRadius)
	local closest = nil;
	local minDist = 10000;
	if U.HaveData(hUnit, 'ally') then
		for i=1, #hUnit.data.allies do
			local unit = hUnit.data.allies[i];
			if U.IsValidEntity(unit) 
			   and unit ~= hUnit	
			   and U.IsInCastRange(hUnit, unit, nRadius) 
			   and U.CanCastOnNonMagicImmune(unit) and U.IsInCastRange(unit, hTarget, minDist)
			then
				closest = unit;
				minDist = GetUnitToUnitDistance(unit, hTarget);
			end
		end
	end
	return weakest;
end

function U.GetDisabledAlly(hUnit, nRadius)
	if U.HaveData(hUnit, 'ally') then
		for i=1, #hUnit.data.allies do
			local unit = hUnit.data.allies[i];
			if U.IsValidEntity(unit) 
			   and unit ~= hUnit	
			   and U.IsInCastRange(hUnit, unit, nRadius) 
			   and U.CanCastOnNonMagicImmune(unit) and U.IsAllyDisabled(hUnit)
			then
				return unit;
			end
		end
	end
	return nil;
end

------------------SKILLS UTILITY

function U.CanBeCast(hAbility)
	return hAbility:IsTrained() and hAbility:IsFullyCastable() and hAbility:IsHidden() == false;
end

function U.GetSkills(hUnit, tSlot)
	local skills = {};
	for i = 1, #tSlot do
		skills[i] = hUnit:GetAbilityInSlot(tSlot[i]);
	end
	return skills;
end

function U.GetProperCastRange(hUnit, nCastRange)
	local attackRange = hUnit:GetAttackRange();
	if nCastRange <= attackRange then
		return attackRange + maxAddedRange;
	elseif nCastRange + maxAddedRange <= maxGetRange then
		return nCastRange + maxAddedRange;
	elseif nCastRange >= maxGetRange then
		return maxGetRange;
	else
		return nCastRange;
	end
end

function U.CanSpamSkill(hUnit, nManaCost)
	return hUnit:GetMana() - nManaCost >= baseSpamPct*hUnit:GetMaxMana();
end

function U.CanCastOnNonMagicImmune(hUnit)
	return hUnit:IsMagicImmune() == false 
	   and U.IsSuspiciousIllusion(hUnit) == false 
	   and U.HasForbiddenModifier(hUnit) == false 
end

function U.CanCastOnMagicImmune(hUnit)
	return U.IsSuspiciousIllusion(hUnit) == false 
	   and U.HasForbiddenModifier(hUnit) == false 
end

----------------TEAM UTILITIES
function U.GetTeamBase()
	return GetShopLocation(team, SHOP_HOME)
end

function U.GetEnemyBase()
	return GetShopLocation(opposing_team, SHOP_HOME)
end

return U;