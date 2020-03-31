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
local castFB2Desire = 0;
local castTWDesire = 0;
local castTDDesire = 0;
local castRCDesire = 0;
local castMRADesire = 0;
local castMRSDesire = 0;
local castGhostDesire = 0;
local castEBDesire = 0;
local itemGhost = nil;
local itemEB = nil;
local alreadyCastEB = false;

local abilityFB = nil;
local abilityFB2 = nil;
local abilityTW = nil;
local abilityMRA = nil;
local abilityMRS = nil;
local abilityRC = nil;
local justMorph = true;
local npcBot = nil;

local skill1 = nil;
local skill2 = nil;
local skill3 = nil;
local asMorphling = true;
local plusFactor = 0;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	plusFactor = npcBot:GetLevel() / 30 * 1.0;	
		
	if abilityRC == nil then abilityRC = npcBot:GetAbilityByName( "morphling_replicate" ) end
	
	local ab1 = npcBot:GetAbilityInSlot(0);
	
	if ab1 ~= nil and ab1:GetName() == 'morphling_waveform' then
		asMorphling = true;
	else
		asMorphling = false;
	end	

	if asMorphling == false then
		if justMorph == false then
			skill1 = npcBot:GetAbilityInSlot(0);
			skill2 = npcBot:GetAbilityInSlot(1);
			skill3 = npcBot:GetAbilityInSlot(2);	
			justMorph = true; 
		end
		if mutil.CanNotUseAbility(npcBot) then return end
		skills.CastStolenSpells(skill1);
		skills.CastStolenSpells(skill2);
		skills.CastStolenSpells(skill3);
		if ( (skill1 ~= nil and skill1:IsNull() == false and skill1:IsFullyCastable() == false) and
		     (skill2 ~= nil and skill2:IsNull() == false and skill2:IsFullyCastable() == false) and
		     (skill3 ~= nil and skill3:IsNull() == false and skill3:IsFullyCastable() == false) ) or npcBot:GetHealth() <= 0.35*npcBot:GetMaxHealth()
		then
			npcBot:Action_UseAbility(npcBot:GetAbilityByName( "morphling_morph_replicate" ));
			return
		end 
	else
		--[[if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "morphling_adaptive_strike_agi" ) end
		if abilityFB2 == nil then abilityFB2 = npcBot:GetAbilityByName( "morphling_adaptive_strike_str" ) end
		if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "morphling_waveform" ) end
		if abilityMRA == nil then abilityMRA = npcBot:GetAbilityByName( "morphling_morph_agi" ) end
		if abilityMRS == nil then abilityMRS = npcBot:GetAbilityByName( "morphling_morph_str" ) end]]--
		
		if justMorph then
			abilityFB = npcBot:GetAbilityByName( "morphling_adaptive_strike_agi" );
			abilityFB2 = npcBot:GetAbilityByName( "morphling_adaptive_strike_str" );
			abilityTW = npcBot:GetAbilityByName( "morphling_waveform" );
			abilityMRA = npcBot:GetAbilityByName( "morphling_morph_agi" );
			abilityMRS = npcBot:GetAbilityByName( "morphling_morph_str" ); 
			justMorph = false;
		end
		
		if npcBot:IsSilenced() == false and npcBot:IsHexed() == false 
		   and npcBot:IsInvulnerable() == false and npcBot:HasModifier("modifier_doom_bringer_doom") == false
		then
			castMRADesire = ConsiderMorphAgility();
			castMRSDesire = ConsiderMorphStrength();
			if castMRSDesire > 0 then
				npcBot:Action_UseAbility( abilityMRS );
				return;
			end
			if castMRADesire > 0 then
				npcBot:Action_UseAbility( abilityMRA );
				return;
			end
		end
		
		-- Check if we're already using an ability
		if mutil.CanNotUseAbility(npcBot) then return end
		
		itemGhost = IsItemAvailable("item_ghost");
		itemEB = IsItemAvailable("item_ethereal_blade");
		
		-- Consider using each ability
		castTWDesire, castTWLocation = ConsiderTimeWalk();
		castFBDesire, castFBTarget = ConsiderFireblast();
		castFB2Desire, castFB2Target = ConsiderFireblast2();
		castRCDesire, castRCTarget = ConsiderReplicate();
		castGhostDesire = ConsiderGhostScepter();
		castEBDesire, castEBTarget = ConsiderEtherealBlade();
		
		
		if ( castTWDesire > 0 ) 
		then
			npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
			return;
		end	
		
		if ( castEBDesire > 0 ) 
		then
			npcBot:Action_UseAbilityOnEntity( itemEB, castEBTarget );
			alreadyCastEB = true;
			return;
		end
		
		if ( castFBDesire > 0 ) 
		then
			npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			alreadyCastEB = false;
			return;
		end
		
		if ( castFB2Desire > 0 ) 
		then
			npcBot:Action_UseAbilityOnEntity( abilityFB2, castFB2Target );
			return;
		end

		if ( castRCDesire > 0 ) 
		then
			npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
			return;
		end
		
		
		if castGhostDesire > 0 then
			npcBot:Action_UseAbility( itemGhost );
			return;
		end
	end
end

function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
	
function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castEBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nMinAGIX = abilityFB:GetSpecialValueFloat("damage_min");
	local nMaxAGIX =  abilityFB:GetSpecialValueFloat("damage_max");
	local nAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nDamage = 0; 
	
	if nAGI > nSTR and ( nAGI - nSTR ) / nSTR >= 0.5 then
		nDamage = nMaxAGIX * nAGI;
	else
		nDamage = nMinAGIX * nAGI;
	end
	
	if alreadyCastEB then
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL ) and mutil.CanCastOnMagicImmune(npcTarget) 
	   and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
			   and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end	

function ConsiderFireblast2()

	-- Make sure it's castable
	if ( not abilityFB2:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityFB2:GetCastRange();
	local nMinStun = abilityFB2:GetSpecialValueFloat("stun_min");
	local nMaxStun = abilityFB2:GetSpecialValueFloat("stun_max");
	local nAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nStun = 0; 
	
	if nSTR > nAGI and ( nSTR - nAGI ) / nAGI >= 0.5 then
		nStun = nMaxStun;
	else
		nStun = nMinStun;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) 
			    and nStun > nMinStun and mutil.IsDisabled(true, npcEnemy) == false ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
			   and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and nStun > nMinStun and mutil.IsDisabled(true, npcTarget) == false 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end	


function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetCastRange()
	local nCastPoint = abilityTW:GetCastPoint();
	local nSpeed = abilityTW:GetSpecialValueInt("speed");
	local nDamage = abilityTW:GetAbilityDamage();
	local nAttackRange = npcBot:GetAttackRange();

	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local loc = mutil.GetEscapeLoc();
		    	return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, npcBot )/ nSpeed ) + nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderMorphAgility()
	
	-- Make sure it's castable
	if ( not abilityMRA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
			or npcBot:WasRecentlyDamagedByAnyHero(2.0) == true or npcBot:WasRecentlyDamagedByTower(2.0) == true 
		then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget)  and mutil.IsInRange(npcTarget, npcBot, 1300)  and npcBot:GetHealth() < 0.35 * npcBot:GetMaxHealth() then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	local nBonusAgi = abilityMRA:GetSpecialValueInt("bonus_attributes");
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);

	if npcBot:GetMana() < 1 and abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif npcBot:GetMana() < 1 and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_NONE;
	end

	if currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) < 2.0 + plusFactor  and not abilityMRA:GetToggleState() then
		--print("start")
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) >= 2.0 + plusFactor and abilityMRA:GetToggleState() then
		--print('stop')
		return BOT_ACTION_DESIRE_LOW;
	elseif npcBot:DistanceFromFountain() == 0 and currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then	
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMorphStrength()

	-- Make sure it's castable
	if ( not abilityMRS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1300)   then
			if npcBot:GetHealth() < 0.3 * npcBot:GetMaxHealth() and  abilityMRS:GetToggleState() == false then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif npcBot:GetHealth() > 0.3 * npcBot:GetMaxHealth() and  npcBot:GetHealth() < 0.35 * npcBot:GetMaxHealth() and abilityMRS:GetToggleState() == true then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end	
	
	if npcBot:GetMana() < 1 and abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif npcBot:GetMana() < 1 and not abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and not abilityMRS:GetToggleState() then
			--print("Retreat Active")
			return BOT_ACTION_DESIRE_MODERATE;
		elseif tableNearbyEnemyHeroes == nil and #tableNearbyEnemyHeroes < 1 and abilityMRS:GetToggleState() then 	
			--print("Retreat Non Active")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) <= 2.2 + plusFactor and abilityMRS:GetToggleState() then
		--print("Agi Higher Active")
		return BOT_ACTION_DESIRE_LOW;	
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) > 2.2 + plusFactor and not abilityMRS:GetToggleState() then
		--print("Agi Higher Non Active")
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReplicate()

	-- Make sure it's castable
	if ( not abilityRC:IsFullyCastable() or npcBot:GetHealth() < 0.4*npcBot:GetMaxHealth() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityRC:GetCastRange();
	local nCastPoint = abilityRC:GetCastPoint();
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 ) 
		then 
			local nMaxAD = 0;
			local target = nil;
			for _,enemy in pairs(tableNearbyEnemyHeroes)
			do
				local enemyAD = enemy:GetAttackDamage();
				if enemyAD > nMaxAD then
					target = enemy;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		   and npcTarget:GetHealth()/npcTarget:GetMaxHealth() > 0.75  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end	

function ConsiderGhostScepter()

	-- Make sure it's castable
	if ( itemGhost == nil or not itemGhost:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEtherealBlade()

	-- Make sure it's castable
	if ( itemEB == nil or not itemEB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end