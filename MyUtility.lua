local U = {};

local RB = Vector(-7174.000000, -6671.00000,  0.000000)
local DB = Vector(7023.000000, 6450.000000, 0.000000)
local maxGetRange = 1600;
local maxAddedRange = 200;

local fSpamThreshold = 0.55;

U.towers = { TOWER_TOP_1, TOWER_TOP_2, TOWER_TOP_3,
                   TOWER_MID_1, TOWER_MID_2, TOWER_MID_3,
                   TOWER_BOT_1, TOWER_BOT_2, TOWER_BOT_3,
                   TOWER_BASE_1, TOWER_BASE_2
				   }
U.barracks = { BARRACKS_TOP_MELEE, BARRACKS_TOP_RANGED, 
					 BARRACKS_MID_MELEE, BARRACKS_MID_RANGED, 
					 BARRACKS_BOT_MELEE, BARRACKS_BOT_RANGED
					}				   

local listBoots = {
	['item_boots'] = 45, 
	['item_tranquil_boots'] = 90, 
	['item_power_treads'] = 45, 
	['item_phase_boots'] = 45, 
	['item_arcane_boots'] = 50, 
	['item_guardian_greaves'] = 55,
	['item_travel_boots'] = 100,
	['item_travel_boots_2'] = 100
}

local modifier = {
	"modifier_winter_wyvern_winters_curse",
	"modifier_winter_wyvern_winters_curse_aura"
	--"modifier_modifier_dazzle_shallow_grave",
	--"modifier_modifier_oracle_false_promise",
	--"modifier_oracle_fates_edict"
}

function U.InitiateAbilities(hUnit, tSlots)
	local abilities = {};
	for i = 1, #tSlots do
		abilities[i] = hUnit:GetAbilityInSlot(tSlots[i]);
	end
	return abilities;
end

function U.CantUseAbility(bot)
	return bot:NumQueuedActions() > 0 
		   or bot:IsAlive() == false or bot:IsInvulnerable() or bot:IsCastingAbility() or bot:IsUsingAbility() or bot:IsChanneling()  
	       or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed()  
		   or bot:HasModifier("modifier_doom_bringer_doom")
		   or bot:HasModifier('modifier_item_forcestaff_active')
end

function U.CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end

function U.GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxGetRange;
	else
		return abilityCR;
	end
end

function U.GetVulnerableWeakestUnit(bHero, bEnemy, nRadius, bot)
	local units = {};
	local weakest = nil;
	local weakestHP = 10000;
	if bHero then
		units = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nRadius, bEnemy);
	end
	for _,u in pairs(units) do
		if u:GetHealth() < weakestHP and U.CanCastOnNonMagicImmune(u) then
			weakest = u;
			weakestHP = u:GetHealth();
		end
	end
	return weakest;
end

function U.GetUnitCountAroundEnemyTarget(target, nRadius)
	local heroes = target:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);	
	local creeps = target:GetNearbyLaneCreeps(nRadius, false);	
	return #heroes + #creeps;
end

function U.GetNumEnemyAroundMe(npcBot)
	local heroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);	
	return #heroes;
end

function U.GetVulnerableUnitNearLoc(bHero, bEnemy, nCastRange, nRadius, vLoc, bot)
	local units = {};
	local weakest = nil;
	if bHero then
		units = bot:GetNearbyHeroes(nCastRange, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nCastRange, bEnemy);
	end
	for _,u in pairs(units) do
		if GetUnitToLocationDistance(u, vLoc) < nRadius and U.CanCastOnNonMagicImmune(u) then
			weakest = u;
			break;
		end
	end
	return weakest;
end

function U.CanSpamSpell(bot, manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(3*30) );
end


function U.GetAllyWithNoBuff(nCastRange, sModifier, bot)
	local target = nil;
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	for _,u in pairs(allies) do
		if not u:HasModifier(sModifier) and U.CanCastOnNonMagicImmune(u) then
			target = u;
			break;
		end
	end
	return target;
end

function U.GetBuildingWithNoBuff(nCastRange, sModifier, bot)
	local ancient = GetAncient(GetTeam());
	if not ancient:IsInvulnerable() and GetUnitToUnitDistance(ancient, bot) < nCastRange then
		return ancient;
	end
	local barracks = bot:GetNearbyBarracks(nCastRange, false);
	for _,u in pairs(barracks) do
		if not u:HasModifier(sModifier) and not u:IsInvulnerable() then
			return u;
		end
	end
	local towers = bot:GetNearbyTowers(nCastRange, false);
	for _,u in pairs(towers) do
		if not u:HasModifier(sModifier) and not u:IsInvulnerable() then
			return u;
		end
	end
	return nil;
end

function U.GetSpellKillTarget(bot, bHero, nRadius, nDamage, nDamageType)
	local units = {};
	if bHero then
		units = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nRadius, true);
	end
	for _,unit in pairs(units) do
		if unit ~= nil and unit:GetHealth() <= unit:GetActualIncomingDamage(nDamage, nDamageType) then
			return unit;
		end
	end
	return nil;
end

function U.IsEnemyTargetMyTarget(bot, hTarget)
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		local eaTarget = enemy:GetAttackTarget(); 
		if eaTarget ~= nil and eaTarget == hTarget then
			return true;
		end	
	end
	return false;
end

function U.GetProperTarget(bot)
	local target = bot:GetTarget();
	if target == nil then
		target = bot:GetAttackTarget();
	end
	return target;
end

function U.GetHumanPlayers()
	local listHumanPlayer = {};
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if not IsPlayerBot(id) then
			local humanPlayer = GetTeamMember(i);
			if humanPlayer ~=  nil then
				table.insert(listHumanPlayer, humanPlayer);
			end
		end
	end
	return listHumanPlayer;
end

function U.IsHumanPlayerCanKill(target)
	local bot = GetBot();
	if target:GetTeam() ~= bot:GetTeam() and target:IsHero() then
		local humanPlayers = U.GetHumanPlayers();
		if U.IsHumanPingNotToKill(target, humanPlayers) then
			print("Human Pinging! You're not Allowed to Kill The Target!");
			return true;
		elseif U.IsHumanCanKillTheTarget(target, humanPlayers) then
			print("Human Can Kill The Target! You're not Allowed to Kill The Target!");	
			return true;
		end
	end
	return false;
end

function U.IsHumanPingNotToKill(target, listHumanPlayer)
	for _,human in pairs(listHumanPlayer) do
		if human ~= nil and not human:IsNull() and human:GetAttackTarget() == target then
			local ping = human:GetMostRecentPing();
			if ping ~= nil and not ping.normal_ping and GetUnitToLocationDistance(target, ping.location) <= 1200 and GameTime() - ping.time < 3.0 then
				return true;
			end	
		end	
	end
	return false;
end

function U.IsHumanCanKillTheTarget(target, listHumanPlayer)
	local total_damage = 0;
	for _,human in pairs(listHumanPlayer) do
		if human ~= nil and not human:IsNull() and human:GetAttackTarget() == target then
			local damage = human:GetEstimatedDamageToTarget(true, target, 2.0, DAMAGE_TYPE_ALL);
			total_damage = total_damage + damage;
		end	
	end
	if total_damage > target:GetHealth() then
		print("Total Damage:"..tostring(total_damage))
		return true;
	end
	return false;
end

function U.GetAlliesNearLoc(vLoc, nRadius)
	local allies = {};
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		local member = GetTeamMember(i);
		if member ~= nil and member:IsAlive() and GetUnitToLocationDistance(member, vLoc) <= nRadius then
			table.insert(allies, member);
		end
	end
	return allies;
end

function U.GetShackleCreepTarget(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = hTarget:GetLocation();
	local creeps = hTarget:GetNearbyCreeps(nRadius, false);
	for i=1, #creeps do
		local dist1 = GetUnitToUnitDistance(creeps[i], hTarget);
		local dist2 = GetUnitToUnitDistance(creeps[i], hSource);
		local dist3 = GetUnitToUnitDistance(hTarget, hSource);
		if  dist2 < dist3 and dist1 > 125  then
			local tResult = PointToLineDistance(vStart, vEnd, creeps[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true 
				and tResult.distance < 75
			then
				-- print('to creep in front')
				return creeps[i];
			end
		end
	end
	return nil;
end

function U.GetShackleHeroTarget(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = hTarget:GetLocation();
	local heroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #heroes do
		if heroes[i] ~= hTarget and U.CanCastOnNonMagicImmune(heroes[i]) then
			local dist1 = GetUnitToUnitDistance(heroes[i], hTarget);
			local dist2 = GetUnitToUnitDistance(heroes[i], hSource);
			local dist3 = GetUnitToUnitDistance(hTarget, hSource);
			if  dist2 < dist3 and dist1 > 125  then
				local tResult = PointToLineDistance(vStart, vEnd, heroes[i]:GetLocation());
				if tResult ~= nil 
					and tResult.within == true 
					and tResult.distance < 75	
				then
					-- print('to hero in front')
					return heroes[i];
				end
			end
		end
	end
	return nil;
end

function U.CanShackleToCreep(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local creeps = hTarget:GetNearbyCreeps(nRadius, false);
	for i=1, #creeps do
		local vEnd = creeps[i]:GetLocation()
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if GetUnitToUnitDistance(creeps[i], hTarget) > 125 and tResult ~= nil 
			and tResult.within == true  			
			and tResult.distance < 75  			
		then
			-- print('to creep behind')
			return true;
		end
	end
	return false;
end

function U.CanShackleToHero(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local heroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #heroes do
		local vEnd = heroes[i]:GetLocation()
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if heroes[i] ~= hTarget and GetUnitToUnitDistance(heroes[i], hTarget) > 125 and tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < 75 			
		then
			-- print('to hero behind')
			return true;
		end
	end
	return false;
end

function U.CanShackleToTree(hSource, hTarget, nRadius)
	local vStart = hSource:GetLocation();
	local trees = hTarget:GetNearbyTrees(nRadius);
	for i=1, #trees do
		local vEnd = GetTreeLocation(trees[i]);
		local tResult = PointToLineDistance(vStart, vEnd, hTarget:GetLocation());
		if tResult ~= nil 
			and tResult.within == true 
			and tResult.distance < 75 			
		then
			-- print('to tree behind')
			return true;
		end
	end
	return false;
end

function U.GetShackleTarget(hero, target, nRadius, nRange)
	local sTarget = nil;
	local dist = GetUnitToUnitDistance(hero, target);
	if dist < nRange and U.CanShackleToCreep(hero, target, nRadius) 
		or U.CanShackleToHero(hero, target, nRadius)
		or U.CanShackleToTree(hero, target, nRadius)
	then
		sTarget = target;
	elseif dist < nRange or dist < nRange+nRadius then
		sTarget = U.GetShackleCreepTarget(hero, target, nRadius);
		if sTarget == nil then
			sTarget = U.GetShackleHeroTarget(hero, target, nRadius);
		end
	end
	return sTarget;
end

function U.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local creeps = hSource:GetNearbyLaneCreeps(1600, true);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	creeps = hTarget:GetNearbyLaneCreeps(1600, false);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	return false;
end

function U.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local creeps = hSource:GetNearbyLaneCreeps(1600, false);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	creeps = hTarget:GetNearbyLaneCreeps(1600, true);
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
			return true;
		end
	end
	return false;
end

function U.IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	if not U.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) then
		return U.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius);
	end
	return true;
end

function U.IsEnemyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local heroes = hSource:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hTarget  then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	heroes = hTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hTarget  then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	return false;
end

function U.IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local heroes = hSource:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hSource then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	heroes = hTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hSource then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	return false;
end

function U.IsHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	if not U.IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) then
		return U.IsEnemyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius);
	end
	return true;
end

function U.IsSandKingThere(bot, nCastRange, fTime)
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		if enemy:GetUnitName() == "npc_dota_hero_sand_king" and enemy:HasModifier('modifier_sandking_sand_storm_invis') then
			return true,  enemy:GetLocation();
		end
	end
	return false, nil;
end

function U.GetUltimateAbility(bot)
	--print(tostring(bot:GetAbilityInSlot(5):GetName()))
	return bot:GetAbilityInSlot(5);
end

function U.CanUseRefresherShard(bot)
	local ult = U.GetUltimateAbility(bot);
	if ult ~= nil and ult:IsPassive() == false then
		local ultCD = ult:GetCooldown();
		local manaCost = ult:GetManaCost();
		if bot:GetMana() >= manaCost and ult:GetCooldownTimeRemaining() >= ultCD/2 then
			return true;
		end
	end
	return false;
end

function U.GetMostUltimateCDUnit()
	local unit = nil;
	local maxCD = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if IsHeroAlive(id) then
			local member = GetTeamMember(i);
			if member ~= nil then
				local ult = U.GetUltimateAbility(member);
				--print(member:GetUnitName()..tostring(ult:GetName())..tostring(ult:GetCooldown()))
				if ult ~= nil and ult:IsPassive() == false and ult:GetCooldown() >= maxCD then
					unit = member;
					maxCD = ult:GetCooldown();
				end
			end
		end
	end
	return unit;
end

function U.CanUseRefresherOrb(bot)
	local ult = U.GetUltimateAbility(bot);
	if ult ~= nil and ult:IsPassive() == false then
		local ultCD = ult:GetCooldown();
		local manaCost = ult:GetManaCost();
		if bot:GetMana() >= manaCost+375 and ult:GetCooldownTimeRemaining() >= ultCD/2 then
			return true;
		end
	end
	return false;
end
--============== ^^^^^^^^^^ NEW FUNCTION ABOVE ^^^^^^^^^ ================--

function U.IsRetreating(npcBot)
	return ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE and 
	      ( npcBot:DistanceFromFountain() > 0 or ( npcBot:DistanceFromFountain() < 300 and U.GetNumEnemyAroundMe(npcBot) > 0 ))) or
		  ( npcBot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS and npcBot:WasRecentlyDamagedByAnyHero(3.0) ) or
		  ( npcBot:HasModifier('modifier_bloodseeker_rupture') and npcBot:WasRecentlyDamagedByAnyHero(3.0) )
end

function U.IsValidTarget(npcTarget)
	return npcTarget ~= nil and npcTarget:IsAlive() and npcTarget:IsHero(); 
end

function U.IsSuspiciousIllusion(npcTarget)
	--TO DO Need to detect enemy hero's illusions better
	local bot = GetBot();
	--Detect allies's illusions
	if npcTarget:IsIllusion() or npcTarget:HasModifier('modifier_illusion') 
	   or npcTarget:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') or npcTarget:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
       or npcTarget:HasModifier('modifier_darkseer_wallofreplica_illusion') or npcTarget:HasModifier('modifier_terrorblade_conjureimage')	   
	then
		return true;
	else
	   --Detect replicate and wall of replica illusions
	    if GetGameMode() ~= GAMEMODE_MO then
			if npcTarget:GetTeam() ~= bot:GetTeam() then
				local TeamMember = GetTeamPlayers(GetTeam());
				for i = 1, #TeamMember
				do
					local ally = GetTeamMember(i);
					if ally ~= nil and ally:GetUnitName() == npcTarget:GetUnitName() then
						return true;
					end
				end
			end
		end
		return false;
	end
end

function U.CanCastOnMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable() and not U.IsSuspiciousIllusion(npcTarget) and not U.HasForbiddenModifier(npcTarget) and not U.IsHumanPlayerCanKill(npcTarget);
end

function U.CanCastOnNonMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable() and not U.IsSuspiciousIllusion(npcTarget) and not U.HasForbiddenModifier(npcTarget) and not U.IsHumanPlayerCanKill(npcTarget);
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
	if enemy then
		return npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared() or U.IsTaunted(npcTarget); 
	else
		return npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared() or npcTarget:IsSilenced( ) or U.IsTaunted(npcTarget);
	end
end

function U.IsSlowed(bot)
	local speedPlusBoots =  U.GetUpgradedSpeed(bot);
	return bot:GetCurrentMovementSpeed() < speedPlusBoots;
end

function U.GetUpgradedSpeed(bot)
	for i=0,5 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil and listBoots[item:GetName()] ~= nil then
			return bot:GetBaseMovementSpeed()+listBoots[item:GetName()];
		end
	end
	return bot:GetBaseMovementSpeed();
end

function U.IsTaunted(npcTarget)
	return npcTarget:HasModifier("modifier_axe_berserkers_call") 
	    or npcTarget:HasModifier("modifier_legion_commander_duel") 
	    or npcTarget:HasModifier("modifier_winter_wyvern_winters_curse") 
		or npcTarget:HasModifier(" modifier_winter_wyvern_winters_curse_aura");
end

function U.IsInRange(npcTarget, npcBot, nCastRange)
	return GetUnitToUnitDistance( npcTarget, npcBot ) <= nCastRange;
end

function U.IsInTeamFight(npcBot, range)
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return tableNearbyAttackingAlliedHeroes ~= nil and #tableNearbyAttackingAlliedHeroes >= 2;
end

function U.CanNotUseAbility(npcBot)
	return npcBot:IsCastingAbility() or npcBot:IsUsingAbility() or npcBot:IsInvulnerable() 
	or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:HasModifier("modifier_doom_bringer_doom");
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

function U.GetMostHPPercent(listUnits, magicImmune)
	local mostPHP = 0;
	local mostPHPUnit = nil;
	for _,unit in pairs(listUnits)
	do
		local uPHP = unit:GetHealth() / unit:GetMaxHealth()
		if ( ( magicImmune and U.CanCastOnMagicImmune(unit) ) or ( not magicImmune and U.CanCastOnNonMagicImmune(unit) ) ) 
			and uPHP > mostPHP  
		then
			mostPHPUnit = unit;
			mostPHP = uPHP;
		end
	end
	return mostPHPUnit;
end

function U.GetCanBeKilledUnit(units, nDamage, nDmgType, magicImmune)
	local target = nil;
	for _,unit in pairs(units)
	do
		if ( ( magicImmune and U.CanCastOnMagicImmune(unit) ) or ( not magicImmune and U.CanCastOnNonMagicImmune(unit) ) ) 
			   and U.CanKillTarget(unit, nDamage, nDmgType) 
		then
			unitKO = target;	
		end
	end
	return target;
end

function U.GetCorrectLoc(target, delay)
	if target:GetMovementDirectionStability() < 1.0 then
		return target:GetLocation();
	else
		return target:GetExtrapolatedLocation(delay);	
	end
end

function U.GetClosestUnit(units)
	local target = nil;
	if units ~= nil and #units >= 1 then
		return units[1];
	end
	return target;
end

function U.GetEnemyFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return RB;
	else
		return DB;
	end
end

function U.GetEscapeLoc()
	local bot = GetBot();
	local team = GetTeam();
	if bot:DistanceFromFountain() > 2500 then
		return GetAncient(team):GetLocation();
	else
		if team == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end

function U.GetEscapeLoc2(unit)
	local team = unit:GetTeam();
	if unit:DistanceFromFountain() > 2500 then
		return GetAncient(team):GetLocation();
	else
		if team == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end

function U.IsStuck2(npcBot)
	if npcBot.stuckLoc ~= nil and npcBot.stuckTime ~= nil then 
		local EAd = GetUnitToUnitDistance(npcBot, GetAncient(GetOpposingTeam()));
		if DotaTime() > npcBot.stuckTime + 5.0 and GetUnitToLocationDistance(npcBot, npcBot.stuckLoc) < 25  
           and npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200		
		then
			--print(npcBot:GetUnitName().." is stuck")
			--DebugPause();
			return true;
		end
	end
	return false
end

function U.IsStuck(npcBot)
	if npcBot.stuckLoc ~= nil and npcBot.stuckTime ~= nil then 
		local attackTarget = npcBot:GetAttackTarget();
		local EAd = GetUnitToUnitDistance(npcBot, GetAncient(GetOpposingTeam()));
		local TAd = GetUnitToUnitDistance(npcBot, GetAncient(GetTeam()));
		local Et = npcBot:GetNearbyTowers(450, true);
		local At = npcBot:GetNearbyTowers(450, false);
		if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0  
		   and DotaTime() > npcBot.stuckTime + 5.0 and GetUnitToLocationDistance(npcBot, npcBot.stuckLoc) < 25    
		then
			--print(npcBot:GetUnitName().." is stuck")
			return true;
		end
	end
	return false
end

function U.IsExistInTable(u, tUnit)
	for _,t in pairs(tUnit) do
		if u:GetUnitName() == t:GetUnitName() then
			return true;
		end
	end
	return false;
end 

function U.FindNumInvUnitInLoc(pierceImmune, bot, nRange, nRadius, loc)
	local nUnits = 0;
	if nRange > 1600 then nRange = 1600 end
	local units = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	for _,u in pairs(units) do
		if ( ( pierceImmune and U.CanCastOnMagicImmune(u) ) or ( not pierceImmune and U.CanCastOnNonMagicImmune(u) ) ) and GetUnitToLocationDistance(u, loc) <= nRadius then
			nUnits = nUnits + 1;
		end
	end
	return nUnits;
end

function U.CountInvUnits(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and U.CanCastOnMagicImmune(u) ) or ( not pierceImmune and U.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

function U.CountUnitsNearLocation(pierceImmune, hUnits, vLoc, nRadius)
	local nUnits = 0;
	if hUnits ~= nil then
		for i=1, #hUnits do
			if	GetUnitToLocationDistance(hUnits[i], vLoc) <= nRadius 
				and ( ( pierceImmune and U.CanCastOnMagicImmune(hUnits[i]) ) or ( not pierceImmune and U.CanCastOnNonMagicImmune(hUnits[i]) ) ) 
			then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

function U.CanBeDominatedCreeps(name)
	return name == "npc_dota_neutral_centaur_khan"
		 or name == "npc_dota_neutral_polar_furbolg_ursa_warrior"	
		 or name == "npc_dota_neutral_satyr_hellcaller"	
		 or name == "npc_dota_neutral_dark_troll_warlord"	
		 or name == "npc_dota_neutral_mud_golem"	
		 or name == "npc_dota_neutral_harpy_storm"	
		 or name == "npc_dota_neutral_ogre_magi"	
		 or name == "npc_dota_neutral_alpha_wolf"	
		 or name == "npc_dota_neutral_enraged_wildkin"	
		 or name == "npc_dota_neutral_satyr_trickster"	
end

function U.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1;
end

function U.GetStrongestUnit(nRange, hUnit, bEnemy, bMagicImune, fTime)
	local units = hUnit:GetNearbyHeroes(nRange, bEnemy, BOT_MODE_NONE)
	local strongest_unit = nil;
	local maxPower = 0;
	for i=1, #units do
		if U.IsValidTarget(units[i]) and
		   ( ( bMagicImune == true and U.CanCastOnMagicImmune(units[i]) == true ) or ( bMagicImune == false and U.CanCastOnNonMagicImmune(units[i]) == true ) )
		then
			local power = units[i]:GetEstimatedDamageToTarget( true, hUnit, fTime, DAMAGE_TYPE_ALL );
			if power > maxPower then
				maxPower = power;
				strongest_unit = units[i];
			end
		end
	end
	return strongest_unit;
end

function U.GetUnitWithMinDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local minUnit = cUnits;
	local minVal = fMinDist;
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and U.CanCastOnNonMagicImmune(hUnits[i]) 
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc);
			if dist < minVal then
				minVal = dist;
				minUnit = hUnits[i];	
			end
		end	
	end
	
	return minVal, minUnit;
end

function U.GetUnitWithMaxDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local maxUnit = cUnits;
	local maxVal = fMinDist;
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and U.CanCastOnNonMagicImmune(hUnits[i]) 
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc);
			if dist > maxVal then
				maxVal = dist;
				maxUnit = hUnits[i];	
			end
		end	
	end
	
	return maxVal, maxUnit;
end

function U.GetFurthestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local furthestUnit = hUnit;
	botDist, furthestUnit = U.GetUnitWithMaxDistanceToLoc(hUnit, aHeroes, furthestUnit, botDist, vLoc);
	botDist, furthestUnit = U.GetUnitWithMaxDistanceToLoc(hUnit, eHeroes, furthestUnit, botDist, vLoc);
	botDist, furthestUnit = U.GetUnitWithMaxDistanceToLoc(hUnit, aCreeps, furthestUnit, botDist, vLoc);
	botDist, furthestUnit = U.GetUnitWithMaxDistanceToLoc(hUnit, eCreeps, furthestUnit, botDist, vLoc);
	
	if furthestUnit ~= bot then
		return furthestUnit;
	end
	
	return nil;
	
end

function U.GetClosestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= bot then
		return closestUnit;
	end
	
	return nil;
	
end

function U.GetClosestUnitToLocationFrommAll2(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = 10000;
	local closestUnit = nil;
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= nil then
		return closestUnit;
	end
	
	return nil;
	
end

function U.GetClosestEnemyUnitToLocation(hUnit, nRange, vLoc)
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= bot then
		return closestUnit;
	end
	
	return nil;
	
end


return U;