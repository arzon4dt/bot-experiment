local U = {};

local RB = Vector(-7200,-6666)
local DB = Vector(7137,6548)

local fSpamThreshold = 0.55;

local modifier = {
	"modifier_winter_wyvern_winters_curse",
	"modifier_modifier_dazzle_shallow_grave",
	"modifier_modifier_oracle_false_promise",
	"modifier_oracle_fates_edict"
}

function U.IsRetreating(npcBot)
	return npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH;
end

function U.IsValidTarget(npcTarget)
	return npcTarget ~= nil and npcTarget:IsAlive() and not npcTarget:IsIllusion() and npcTarget:IsHero(); 
end

function U.CanCastOnMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function U.CanCastOnNonMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function U.CanCastOnTargetAdvanced( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable() and not U.HasForbiddenModifier(npcTarget)
end

function U.CanKillTarget(npcTarget, dmg, dmgType)
	return npcTarget:GetActualIncomingDamage( dmg, dmgType ) >= npcTarget:GetHealth(); 
end

function U.HasForbiddenModifier(npcTarget)
	for _,mod in pairs(modifier)
	do
		if npcTarget:HasModifier(mod) then
			return true
		end	
	end
	return false;
end

function U.ShouldEscape(npcBot)
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
	then
		return true;
	end
end

function U.IsRoshan(npcTarget)
	return npcTarget ~= nil and npcTarget:IsAlive() and string.find(npcTarget:GetUnitName(), "roshan");
end

function U.IsDisabled(enemy, npcTarget)
	if enemy 
	then
		return npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared(); 
	else
		return npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared() or npcTarget:IsSilenced( );
	end
end

function U.IsInRange(npcTarget, npcBot, nCastRange)
	return GetUnitToUnitDistance( npcTarget, npcBot ) <= nCastRange;
end

function U.IsInTeamFight(npcBot, range)
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return tableNearbyAttackingAlliedHeroes ~= nil and #tableNearbyAttackingAlliedHeroes >= 2;
end

function U.CanNotUseAbility(npcBot)
	return npcBot:IsUsingAbility() or npcBot:IsInvulnerable() or npcBot:IsChanneling() or npcBot:IsSilenced();
end

function U.IsGoingOnSomeone(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_GANK or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end

function U.IsDefending(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end

function U.IsPushing(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end

function U.GetTeamFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return DB;
	else
		return RB;
	end
end

function U.GetComboItem(npcBot, item_name)
	local Slot = npcBot:FindItemSlot(item_name);
	if Slot >= 0 and Slot <= 5 then
		return npcBot:GetItemInSlot(Slot);
	else
		return nil;
	end
end

function U.GetMostHpUnit(ListUnit)
	local mostHpUnit = nil;
	local maxHP = 0;
	for _,unit in pairs(ListUnit)
	do
		local uHp = unit:GetHealth();
		if  uHp > maxHP then
			mostHpUnit = unit;
			maxHP = uHp;
		end
	end
	return mostHpUnit
end

function U.StillHasModifier(npcTarget, modifier)
	return npcTarget:HasModifier(modifier);
end

function U.AllowedToSpam(npcBot, nManaCost)
	return ( npcBot:GetMana() - nManaCost ) / npcBot:GetMaxMana() >= fSpamThreshold;
end

function U.IsProjectileIncoming(npcBot, range)
	local incProj = npcBot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if GetUnitToLocationDistance(npcBot, p.location) < range and not p.is_attack and p.is_dodgeable then
			return true;
		end
	end
	return false;
end

function U.GetEnemyFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return RB;
	else
		return DB;
	end
end

return U;