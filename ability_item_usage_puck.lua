local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")

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

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,3});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castDDesire = 0;
local castRDesire = 0;

local function ShouldDodge(bot, range, mode)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if ( mode == 'attack' and p.is_dodgeable and p.is_attack == false and GetUnitToLocationDistance(bot, p.location) <= range )
		or ( mode == 'retreat' and bot:GetHealth() > 0.20*bot:GetMaxHealth() and p.is_attack == false and GetUnitToLocationDistance(bot, p.location) <= range )	
		or ( mode == 'retreat' and bot:GetHealth() < 0.20*bot:GetMaxHealth() and mutils.IsValidTarget(p.caster) and p.is_attack == true and GetUnitToLocationDistance(bot, p.location) <= range )	
		then
			return true;
		end
	end
	return false;
end


local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if mutils.IsStuck(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange - 250 );
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) == true
			and mutils.CanCastOnNonMagicImmune(target) == true
			and mutils.IsInRange(bot, target, nCastRange) == true	
		then
			return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt('radius');
	local nCastRange    = abilities[2]:GetSpecialValueInt('max_distance');
	
	if mutils.IsStuck(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange+0.5*nRadius) == true	
		then
			return BOT_ACTION_DESIRE_MODERATE, bot:GetXUnitsTowardsLocation(target:GetLocation(), nCastRange);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local duration = abilities[3]:GetSpecialValueInt('duration');
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local blink = bot:GetItemInSlot(bot:FindItemSlot('item_blink'));
		if blink ~= nil and  blink:GetCooldownTimeRemaining() < duration then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		if ShouldDodge(bot, 200, 'retreat') then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
		do
			if pr.ability:GetName() == "puck_illusory_orb" then
				local ProjDist = GetUnitToLocationDistance(bot, pr.location);
				if ProjDist < 200 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target,  1300)
		then
			if ShouldDodge(bot, 200, 'attack') then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderD()
	if  mutils.CanBeCast(abilities[5]) == false or bot:IsRooted() == true then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius    = abilities[2]:GetSpecialValueInt('radius');
	local nRange = bot:GetAttackRange();
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(5.0) or bot:WasRecentlyDamagedByTower(5.0) ) )
	then
		local loc = mutils.GetEscapeLoc();
		local bot_dist = GetUnitToLocationDistance(bot, loc);
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
			do
				if pr.ability:GetName() == "puck_illusory_orb" then
					local ProjDist = GetUnitToLocationDistance(bot, pr.location);
					if utils.GetDistance(pr.location, loc) < bot_dist and ProjDist > 625 then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end	
			end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
		then
			local pro = GetLinearProjectiles();
			if mutils.CanBeCast(abilities[2]) == true then
				local allies = target:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
				local enemies = target:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
				if ( enemies ~= nil and allies ~= nil and #allies >= #enemies )  
				then
					for _,pr in pairs(pro)
					do
						if pr.ability:GetName() == "puck_illusory_orb" then
							local ProjTgt = GetUnitToLocationDistance(target, pr.location);
							local ProjBot = GetUnitToLocationDistance(bot, pr.location);
							local TgtBot = GetUnitToUnitDistance(bot, TgtBot);
							if ProjBot > TgtBot and ProjTgt < nRadius - 50 then
								return BOT_ACTION_DESIRE_MODERATE;
							end
						end	
					end
				end
			else
				if mutils.IsInRange(bot, target,  nRange) == false then
					local allies = target:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
					local enemies = target:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
					if ( enemies ~= nil and allies ~= nil and #allies >= #enemies ) 
					then
						for _,pr in pairs(pro)
						do
							if pr.ability:GetName() == "puck_illusory_orb" then
								local ProjTgt = GetUnitToLocationDistance(target, pr.location);
								local ProjBot = GetUnitToLocationDistance(bot, pr.location);
								local TgtBot = GetUnitToUnitDistance(bot, TgtBot);
								if ProjBot > TgtBot and ProjTgt < 0.5*nRange then
									return BOT_ACTION_DESIRE_MODERATE;
								end
							end	
						end
					end
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost   = abilities[4]:GetManaCost();
	local nRadius    = abilities[4]:GetSpecialValueInt('coil_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) == true	
		then
			local enemies = target:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if enemies ~= nil and #enemies >= 2 then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castEDesire			 = ConsiderE();
	castDDesire			 = ConsiderD();
	castRDesire, rTarget = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], wTarget);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_UseAbility(abilities[5]);		
		return
	end
	
end

-- local pro = GetLinearProjectiles();
			-- for _,pr in pairs(pro)
			-- do
				-- if pr.ability:GetName() == "puck_illusory_orb" then
					-- local ProjDist = GetUnitToLocationDistance(npcTarget, pr.location);
					-- if ProjDist < pr.radius then
						-- return BOT_ACTION_DESIRE_MODERATE;
					-- end
				-- end	
			-- end
