local U = {}

local maxGetRange = 1600;
local maxAddedRange = 200;
local maxLevel = 25;

function U.InitiateAbilities(hUnit, tSlots)
	local abilities = {};
	for _,i in pairs(tSlots) do
		table.insert(abilities, hUnit:GetAbilityInSlot(i));
	end
	return abilities;
end

function U.CantUseAbility(bot)
	return bot:NumQueuedActions() > 0 
		   or not bot:IsAlive() or bot:IsInvulnerable() or bot:IsCastingAbility() or bot:IsUsingAbility() or bot:IsChanneling()  
	       or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsHexed()   
		   or bot:HasModifier("modifier_doom_bringer_doom")
end

function U.CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and not ability:IsHidden();
end

function U.GetProperCastRange(bIgnore, hUnit, ability)
	local abilityCR = ability:GetCastRange();
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxAddedRange;
	end
end

function U.GetNumEnemyAroundMe(bot)
	local heroes = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);	
	return #heroes;
end

function U.IsRetreating(bot)
	return ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE and 
	( bot:DistanceFromFountain() > 0 or ( bot:DistanceFromFountain() < 300 and U.GetNumEnemyAroundMe(bot) > 0 ))) or
	( bot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS and bot:WasRecentlyDamagedByAnyHero(3.0) ) or
	( bot:HasModifier('modifier_bloodseeker_rupture') and bot:WasRecentlyDamagedByAnyHero(3.0) )
end

function U.GetLowestHPUnit(tUnits, bIgnoreImmune)
	local lowestHP   = 100000;
	local lowestUnit = nil; 
	for _,unit in pairs(tUnits)
	do
		local hp = unit:GetHealth()
		if hp < lowestHP and ( bIgnoreImmune or ( not bNotMagicImmune and not unit:IsMagicImmune() ) ) then
			lowestHP   = hp;
			lowestUnit = unit;
		end
	end
	return lowestUnit;
end

function U.GetProperLocation(hUnit, nDelay)
	if hUnit:GetMovementDirectionStability() >= 0 then
		return hUnit:GetExtrapolatedLocation(nDelay);
	end
	return hUnit:GetLocation();
end

function U.IsDefending(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end

function U.IsPushing(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end

function U.IsInTeamFight(bot, range)
	local attackingAllies = bot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return attackingAllies ~= nil and #attackingAllies >= 2;
end

function U.IsGoingOnSomeone(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_GANK or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end


function U.IsValidTarget(target)
	return target ~= nil and target:IsAlive() and target:IsHero(); 
end

function U.IsInRange(target, bot, nCastRange)
	return GetUnitToUnitDistance( target, bot ) <= nCastRange;
end

function U.IsSuspiciousIllusion(target)
	--TO DO Need to detect enemy hero's illusions better
	local bot = GetBot();
	--Detect allies's illusions
	if target:IsIllusion() or target:HasModifier('modifier_illusion') 
	   or target:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') or target:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
       or target:HasModifier('modifier_darkseer_wallofreplica_illusion') or target:HasModifier('modifier_terrorblade_conjureimage')	   
	then
		return true;
	else
	--Detect replicate and wall of replica illusions
		if target:GetTeam() ~= bot:GetTeam() then
			local TeamMember = GetTeamPlayers(GetTeam());
			for i = 1, #TeamMember
			do
				local ally = GetTeamMember(i);
				if ally ~= nil and ally:GetUnitName() == target:GetUnitName() then
					return true;
				end
			end
		end
		return false;
	end
end

function U.IsDisabled(enemy, target)
	if enemy then
		return target:IsRooted( ) or target:IsStunned( ) or target:IsHexed( ) or target:IsNightmared() or U.IsTaunted(target); 
	else
		return target:IsRooted( ) or target:IsStunned( ) or target:IsHexed( ) or target:IsNightmared() or target:IsSilenced( ) or U.IsTaunted(target);
	end
end

function U.IsTaunted(target)
	return target:HasModifier("modifier_axe_berserkers_call") or target:HasModifier("modifier_legion_commander_duel") 
	    or target:HasModifier("modifier_winter_wyvern_winters_curse");
end

function U.CanCastOnMagicImmune(target)
	return target:CanBeSeen() and not target:IsInvulnerable() and not U.IsSuspiciousIllusion(target);
end

function U.CanCastOnNonMagicImmune(target)
	return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable() and not U.IsSuspiciousIllusion(target);
end

function U.CountVulnerableUnit(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() then
				count = count + 1;
			end
		end
	end
	return count;
end

function U.CountNotStunnedUnits(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() and not U.IsDisabled(true, unit) then
				count = count + 1;
			end
		end
	end
	return count;
end

function U.AllowedToSpam(bot, manaCost)
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( 1.0 - bot:GetLevel()/(2*maxLevel) );
end

return U;