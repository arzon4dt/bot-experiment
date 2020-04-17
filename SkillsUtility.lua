local X = {}
local utility = require(GetScriptDirectory() ..  "/util")
local castEntityTarget = 0;
local castPointTarget = 0;
local castAoeTarget = 0;
local castNoTarget = 0;
local castTreeTarget = 0;
local RB = Vector(-7200,-6666)
local DB = Vector(7137,6548)
local BlinkLikeAbility = {
	'antimage_blink',
	'faceless_void_time_walk',
	'magnataur_skewer',
	'queenofpain_blink',
	'storm_spirit_ball_lightning',
	'techies_suicide',
	'wisp_relocate',
	'sandking_burrowstrike',
	'abyssal_underlord_dark_rift'
}

local ClearPathAbilities = {
	'pudge_meat_hook',
	'rattletrap_hookshot',
	'mirana_arrow'
}

function X.CastStolenSpells(ability)
	
	local bot = GetBot()
	
	if ability ~= nil and ability:IsNull() == false and not string.find(ability:GetName(), "empty") and not X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE)  then
	
		if X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_AUTOCAST) then
			if ability:GetAutoCastState( ) == false then
				ability:ToggleAutoCast();
				return;
			end
		end
		
		if ability:GetName() == "earthshaker_enchant_totem" and ( bot:HasScepter() or bot:HasModifier('modifier_item_ultimate_scepter_consumed') ) then
			castPointTarget, castPoint = X.ConsiderPointTarget(ability);
			if castPointTarget > 0 then
				bot:Action_UseAbilityOnLocation( ability, castPoint );
				return;
			end
		elseif X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
			castEntityTarget, castTarget, UnitType = X.ConsiderEntityTarget(ability);
			if castEntityTarget > 0 then
				if UnitType == "unit" then
					bot:Action_UseAbilityOnEntity( ability, castTarget );
					return;
				elseif 	UnitType == "tree" then
					bot:Action_UseAbilityOnTree( ability, castTarget );
					return;
				end	
			end
		elseif X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) then
			castPointTarget, castPoint = X.ConsiderPointTarget(ability);
			if castPointTarget > 0 then
				bot:Action_UseAbilityOnLocation( ability, castPoint );
				return;
			end
		elseif X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
			castNoTarget = X.ConsiderNoTarget(ability);
			if castNoTarget > 0 then
				bot:Action_UseAbility( ability );
				return;
			end		
		end
	
	end

end

function X.CanCastOnNonMagicImmune( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function X.CanCastOnMagicImmune( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function X.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function X.IsEngagingTarget(npcBot)
	local mode =  npcBot:GetActiveMode();
	return  mode == BOT_MODE_ROAM or
			mode == BOT_MODE_TEAM_ROAM or
			mode == BOT_MODE_GANK or
			mode == BOT_MODE_ATTACK or
			mode == BOT_MODE_DEFEND_ALLY
end

function X.IsRetreating(npcBot)
	return npcBot:GetActiveMode() == BOT_MODE_RETREAT 
		and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH 
		and npcBot:WasRecentlyDamagedByAnyHero(3.0)
		and npcBot:DistanceFromFountain() > 0; 
end

function X.CanBeUseToChaseOrEscape(ability_name)
	for _,a in pairs(BlinkLikeAbility)
	do
		if ability_name == a then
			return true;
		end	
	end
	return false;
end

function X.AbilityNeedPathToBeClear(ability_name)
	for _,a in pairs(ClearPathAbilities)
	do
		if ability_name == a then
			return true
		end
	end
	return false;
end

function X.GetFurthestTarget(npcBot, nCastRange)
	local Enemies = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	local Allies = npcBot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	local AllyCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, false);
	local furthestUnit = nil;
	local closestDistance = 10000;
	for _,ally in pairs(Allies) do
		local dist = GetUnitToUnitDistance(ally, GetAncient(GetTeam()));
		if dist < closestDistance then
			closestDistance = dist;
			furthestUnit = ally;
		end
	end
	for _,creep in pairs(AllyCreeps) do
		local dist = GetUnitToUnitDistance(creep, GetAncient(GetTeam()));
		if dist < closestDistance then
			closestDistance = dist;
			furthestUnit = creep;
		end
	end
	if furthestUnit ~= nil and #Enemies > 0 and closestDistance < GetUnitToUnitDistance(Enemies[1], GetAncient(GetTeam()))  then
		return furthestUnit;
	end
	return nil;
end

function X.ConsiderEntityTarget(ability)
	
	local npcBot = GetBot();
	
	if not ability:IsFullyCastable() or ability:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = ability:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	
	if nCastRange + 200 <= nAttackRange then
		nCastRange = nAttackRange + 200;
	elseif nCastRange + 200 <= 1600 then
		nCastRange = nCastRange + 200;
	elseif nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	if ability:GetName() == "doom_bringer_devour" then
		if X.IsRetreating(npcBot) == false and X.IsEngagingTarget(npcBot) == false 
		then
			local clvl = ability:GetSpecialValueInt('creep_level');
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 500, true );
			for _,npcCreep in pairs( tableNearbyEnemyCreeps )
			do
				if ( X.CanCastOnNonMagicImmune(npcCreep) and npcCreep:GetLevel() <= clvl ) then
					return BOT_ACTION_DESIRE_HIGH, npcCreep, 'unit';
				end
			end
		end
	end
	
	if ability:GetName() == "phantom_assassin_phantom_strike" or ability:GetName() == "riki_blink_strike"  then
		if X.IsEngagingTarget(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget, 'unit';
			end
		end
		if X.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local furthestTarget = X.GetFurthestTarget(npcBot, nCastRange)
			if furthestTarget ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, furthestTarget, 'unit';
			end
		end
	end
	
	if ability:GetName() == "tiny_toss" then
		if X.IsEngagingTarget(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
			then
				local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 275, false, BOT_MODE_NONE );
				local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 275, true, BOT_MODE_NONE );
				local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 275, true );
				local tableNearbyAllyCreeps = npcBot:GetNearbyLaneCreeps( 275, false );
				if tableNearbyAllyHeroes ~= nil or tableNearbyEnemyHeroes ~= nil or tableNearbyAllyCreeps ~= nil or tableNearbyEnemyCreeps ~= nil 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget, 'unit';
				end
			end
		end
	end
	
	if X.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_CREEP) then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		end
	end	
	
	if X.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY) and 
	   X.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO) and 
	   X.CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)  
	then
		if X.IsEngagingTarget(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget, 'unit';
			end
		end
	elseif X.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY) and 
	       X.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO) and 
	       not X.CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)  
	then
		if X.IsRetreating(npcBot)
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy, 'unit';
				end
			end
		end
		
		if X.IsEngagingTarget(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget, 'unit';
			end
		end
	elseif X.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_FRIENDLY) and
	       X.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO) 
	then   
		local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
		then
			local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			for _,h in pairs(tableNearbyAllies)
			do
				if ( h:GetUnitName() ~= npcBot:GetUnitName() and h:GetActiveMode() == BOT_MODE_RETREAT and h:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) or h:GetActiveMode() == BOT_MODE_ATTACK then
					return BOT_ACTION_DESIRE_MODERATE, h, 'unit';
				end
			end
		end	
		
		if X.IsRetreating(npcBot)
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcBot, 'unit';
				end
			end
		end
		
	elseif X.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_TREE) then
		if X.IsEngagingTarget(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
			then
				local tableNearbyTrees = npcBot:GetNearbyTrees( nCastRange );
				if tableNearbyTrees ~= nil and #tableNearbyTrees > 0 then
					return BOT_ACTION_DESIRE_MODERATE, tableNearbyTrees[1], 'tree';
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;

end


function X.ConsiderPointTarget(ability)
	
	local npcBot = GetBot();
	
	if not ability:IsFullyCastable() or ability:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint();
	local nAttackRange = npcBot:GetAttackRange();
	
	if nCastRange + 200 <= nAttackRange then
		nCastRange = nAttackRange + 200;
	elseif nCastRange + 200 <= 1600 then
		nCastRange = nCastRange + 200;
	elseif nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	if  X.AbilityNeedPathToBeClear(ability:GetName()) then
		local an = ability:GetName();
		if an == 'pudge_meat_hook' or an == 'rattletrap_hookshot' then
			
			local nRadius = 0;
	        local speed = 0;
			
			if an == "pudge_meat_hook" then
				nRadius = ability:GetSpecialValueInt("hook_width");
				speed = ability:GetSpecialValueInt("hook_speed");
			elseif an == "rattletrap_hookshot" then
				nRadius = ability:GetSpecialValueInt("latch_radius");
				speed = ability:GetSpecialValueInt("speed");
			end
			
			if X.IsEngagingTarget(npcBot)
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
				then
					local distance = GetUnitToUnitDistance(npcTarget, npcBot)
					local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
					if not utility.AreCreepsBetweenMeAndLoc(pLoc, nRadius)  then
						return BOT_ACTION_DESIRE_MODERATE, pLoc;
					end
				end
			end
		elseif 	an == 'mirana_arrow' then
			
			local nRadius = ability:GetSpecialValueInt( "arrow_width" );
			local speed = ability:GetSpecialValueInt( "arrow_speed" );
			
			if X.IsEngagingTarget(npcBot)
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
				then
					local distance = GetUnitToUnitDistance(npcTarget, npcBot)
					local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
					if not utility.AreEnemyCreepsBetweenMeAndLoc(pLoc, nRadius)  then
						return BOT_ACTION_DESIRE_MODERATE, pLoc;
					end
				end
			end
			
		end
	
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	if X.CanBeUseToChaseOrEscape(ability:GetName()) then
		if X.IsRetreating(npcBot)
		then
			if GetTeam( ) == TEAM_DIRE then
				return BOT_ACTION_DESIRE_MODERATE, DB;
			elseif GetTeam( ) == TEAM_RADIANT then
				return BOT_ACTION_DESIRE_MODERATE, RB;
			end
		end
		if  X.IsEngagingTarget(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and
				GetUnitToUnitDistance( npcTarget, npcBot ) > nAttackRange - 100 and  GetUnitToUnitDistance( npcTarget, npcBot ) < 1200
			) 
			then
				local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
				if tableNearbyEnemyHeroes == nil or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				end
			end
		end
	else
		if ability:GetName() == 'furion_force_of_nature' then
			if X.IsEngagingTarget(npcBot)
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
				then
					local nearbyTrees = npcBot:GetNearbyTrees(nCastRange)
					if nearbyTrees[1] ~= nil then
						return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(nearbyTrees[1])
					end
				end
			end
		else
			if X.IsEngagingTarget(npcBot)
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, {};

end

function X.GetProperRadius(ability)
	local aoe = ability:GetAOERadius();
	if aoe == 0 then
		aoe = ability:GetSpecialValueInt('radius');
	end
	if aoe == 0 then
		aoe = ability:GetSpecialValueInt('pounce_distance');
	end
	if aoe == 0 then
		aoe = ability:GetSpecialValueInt('starfall_radius');
	end
	if aoe == 0 then
		aoe = ability:GetSpecialValueInt('whirling_radius');
	end
	return aoe;
end

function X.ConsiderNoTarget(ability)
	
	local npcBot = GetBot();
	
	if not ability:IsFullyCastable() or ability:IsHidden() then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = X.GetProperRadius(ability);
	local nAttackRange = npcBot:GetAttackRange();
	
	if nRadius == nil or nRadius == 0 then
		nRadius = nAttackRange + 200;
	elseif nRadius > nAttackRange then
		nRadius = nRadius / 2 + 200; 
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	
	if X.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE) then
		if ability:GetName() == "pudge_rot" then
			if X.IsEngagingTarget(npcBot)
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and 
					GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius and not ability:GetToggleState() ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				else
					if ability:GetToggleState() then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end
			else
				if ability:GetToggleState() then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
		elseif ability:GetName() == "witch_doctor_voodoo_restoration" then
			local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
			if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
			then
				local tableNearbyAllies = npcBot:GetNearbyHeroes( 500, false, BOT_MODE_NONE );
				if (tableNearbyAllies ~= nil and #tableNearbyAllies >= 1 and not ability:GetToggleState()) then
					return BOT_ACTION_DESIRE_MODERATE;
				else
					if ability:GetToggleState() then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end
			end
			
			if X.IsRetreating(npcBot)
			then
				local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
				if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and not ability:GetToggleState() ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				else	
					if ability:GetToggleState() then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end
			end
			
		elseif ability:GetName() == "leshrac_pulse_nova" then
			if X.IsEngagingTarget(npcBot) and not npcBot:HasModifier("modifier_leshrac_pulse_nova")
			then
				local npcTarget = npcBot:GetTarget();
				if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and 
					GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius and not ability:GetToggleState() ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				else
					if npcBot:HasModifier("modifier_leshrac_pulse_nova") then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end
			else
				if npcBot:HasModifier("modifier_leshrac_pulse_nova") then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		elseif ability:GetName() == "morphling_morph_agi" then	
			return BOT_ACTION_DESIRE_NONE;
		elseif ability:GetName() == "morphling_morph_str" then	
			if npcBot:GetMana() / npcBot:GetMaxMana() > 0.35 and not ability:GetToggleState() then  
				return BOT_ACTION_DESIRE_MODERATE;	
			elseif npcBot:GetMana() / npcBot:GetMaxMana() < 0.35 and ability:GetToggleState() then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
		
		return BOT_ACTION_DESIRE_NONE;
		
	else
		if X.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
		
		if X.IsEngagingTarget(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and X.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
		
		local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
		then
			local tableNearbyEnemies = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE  );
			if tableNearbyEnemies ~= nil and #tableNearbyEnemies >= 1 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE;

end


return X