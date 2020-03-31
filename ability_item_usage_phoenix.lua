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

local npcBot = GetBot();

local castIDDesire = 0;
local castIDSDesire = 0;
local castFSDesire = 0;
local castFSLDesire = 0;
local castSRDesire = 0;
local castSRSDesire = 0;
local castTMDesire = 0;
local castSNDesire = 0;

local IcarusDive = "";
local IcarusDiveStop = "";
local FireSpirit = "";
local FireSpiritLaunch = "";
local SunRay = "";
local SunRayStop = "";
local ToggleMovement = "";
local Supernova = "";

local everStuck = false;

local EscLoc = {};
local spiritCT = 0.0;

function AbilityUsageThink()

	--[[if npcBot:GetActiveMode() ~= mode then
		utils.PrintMode(npcBot:GetActiveMode());
		print("Desire = "..tostring(npcBot:GetActiveModeDesire()))
		mode = npcBot:GetActiveMode();
		
	end]]--
	
	if IcarusDive == "" then IcarusDive = npcBot:GetAbilityByName("phoenix_icarus_dive") end
	if IcarusDiveStop == "" then IcarusDiveStop = npcBot:GetAbilityByName("phoenix_icarus_dive_stop") end
	if FireSpirit == "" then FireSpirit = npcBot:GetAbilityByName("phoenix_fire_spirits") end
	if FireSpiritLaunch == "" then FireSpiritLaunch = npcBot:GetAbilityByName("phoenix_launch_fire_spirit") end
	if SunRay == "" then SunRay = npcBot:GetAbilityByName("phoenix_sun_ray") end
	if SunRayStop == "" then SunRayStop = npcBot:GetAbilityByName("phoenix_sun_ray_stop") end
	if ToggleMovement == "" then ToggleMovement = npcBot:GetAbilityByName("phoenix_sun_ray_toggle_move") end
	if Supernova == "" then Supernova = npcBot:GetAbilityByName("phoenix_supernova") end

	if mutil.CanNotUseAbility(npcBot) then return end
	
	castIDDesire, castIDLocation = ConsiderIcarusDive();
	castIDSDesire = ConsiderIcarusDiveStop();
	castFSDesire = ConsiderFireSpirit();
	castFSLDesire, castFSLLocation, FSETA = ConsiderFireSpiritLaunch();
	castSRDesire, castSRLocation = ConsiderSunRay();
	castSRSDesire = ConsiderSunRayStop();
	castTMDesire, state = ConsiderToggleMovement();
	castSNDesire, castSNTarget = ConsiderSupernova();
	
	if castSNDesire > 0 then 
		if castSNTarget == "" then
			npcBot:Action_UseAbility( Supernova );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( Supernova, castSNTarget );
			return;
		end
	end
	
	if castIDDesire > 0 then 
		--print("cast ID")
		EscLoc = castIDLocation;
		npcBot:Action_UseAbilityOnLocation( IcarusDive, castIDLocation );
		return;
	end
	
	if castIDSDesire > 0 then 
		--print("cast IDS")
		npcBot:Action_UseAbility( IcarusDiveStop );
		return;
	end
	
	if castFSDesire > 0 then 
		npcBot:Action_UseAbility( FireSpirit );
		--print("cast FS")
		return;
	end
	
	if castFSLDesire > 0 and DotaTime() >= spiritCT + FSETA + 0.25 then 
		npcBot:Action_UseAbilityOnLocation( FireSpiritLaunch, castFSLLocation );
		--print("cast FSL")
		spiritCT = DotaTime();
		return;
	end
	
	if castSRDesire > 0 then 
		npcBot:Action_UseAbilityOnLocation( SunRay, castSRLocation );
		--print("cast SR")
		return;
	end
	
	if castSRSDesire > 0 then 
		npcBot:Action_UseAbility( SunRayStop );
		--print("cast SRS")
		return;
	end
	
	if castTMDesire > 0 then 
		if state == "on" then
			if not ToggleMovement:GetToggleState() then
				npcBot:Action_UseAbility( ToggleMovement );
				--print("cast TM ON")
			end
		else
			if ToggleMovement:GetToggleState() then
				npcBot:Action_UseAbility( ToggleMovement );
				--print("cast TM OFF")
			end
		end
		return;
	end
	
end

function ConsiderIcarusDive()

	if ( not IcarusDive:IsFullyCastable() or IcarusDive:IsHidden() or npcBot:HasModifier("modifier_phoenix_icarus_dive") or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = IcarusDive:GetSpecialValueInt("dash_length");
	local nRadius = IcarusDive:GetSpecialValueInt( "dash_width" );
	local nCastPoint = IcarusDive:GetCastPoint();
	local nDamage = IcarusDive:GetSpecialValueInt("damage_per_second") * IcarusDive:GetSpecialValueFloat("burn_duration");
	
	if mutil.IsStuck(npcBot)
	then
		everStuck = true;
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
	end
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
		then
			--print("retreat"..tostring(utils.GetTowardsFountainLocation(npcBot:GetLocation(), nCastRange)))
			return BOT_ACTION_DESIRE_MODERATE, utils.GetTowardsFountainLocation(npcBot:GetLocation(), nCastRange);
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, ( nCastRange / 2 ) + 200 ) )
		then
			local eta = ( GetUnitToUnitDistance( npcTarget, npcBot ) / 1000 ) + nCastPoint;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( eta );
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderIcarusDiveStop()
	
	if ( not IcarusDiveStop:IsFullyCastable() or IcarusDiveStop:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT
	then
		if ( GetUnitToLocationDistance(npcBot, EscLoc) <= 100 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if everStuck and GetUnitToLocationDistance(npcBot, EscLoc) <= 100 then
		everStuck = false;
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE
end

function ConsiderFireSpirit()

	if ( not FireSpirit:IsFullyCastable() or FireSpirit:IsHidden() or npcBot:HasModifier("modifier_phoenix_fire_spirit_count") ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = FireSpirit:GetCastRange();
	local nRadius = FireSpirit:GetSpecialValueInt( "radius" );

	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, 2*nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange( npcTarget, npcBot, ( nCastRange / 2 ) + 200 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderFireSpiritLaunch()

	if ( not FireSpiritLaunch:IsFullyCastable() or FireSpiritLaunch:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0;
	end
	
	local nCastRange = FireSpirit:GetCastRange();
	local nRadius = FireSpirit:GetSpecialValueInt( "radius" );
	local nCastPoint = FireSpirit:GetCastPoint();
	local nDamage = FireSpirit:GetSpecialValueInt("damage_per_second") * FireSpirit:GetSpecialValueFloat("duration");
	local nSpeed = FireSpirit:GetSpecialValueInt("spirit_speed");
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );

	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			if mutil.CanCastOnNonMagicImmune(enemy) and  not enemy:HasModifier("modifier_phoenix_fire_spirit_burn") then
				local eta = ( GetUnitToUnitDistance(enemy, npcBot) / nSpeed ) + nCastPoint ;
				return  BOT_ACTION_DESIRE_MODERATE, enemy:GetExtrapolatedLocation(eta), eta;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			if mutil.CanCastOnNonMagicImmune(enemy) and not enemy:HasModifier("modifier_phoenix_fire_spirit_burn") then
				local eta = ( GetUnitToUnitDistance(enemy, npcBot) / nSpeed ) + nCastPoint ;
				return  BOT_ACTION_DESIRE_MODERATE, enemy:GetExtrapolatedLocation(eta), eta;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange( npcTarget, npcBot, nCastRange )
			 and not npcTarget:HasModifier("modifier_phoenix_fire_spirit_burn") ) 
		then
			local eta = ( GetUnitToUnitDistance( npcTarget, npcBot ) / nSpeed ) + nCastPoint;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( eta ), eta;
		end
	end
	
	if tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local eta = ( GetUnitToLocationDistance(npcBot, locationAoE.targetloc) / nSpeed ) + nCastPoint ;
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc, eta;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0, 0;

end

function ConsiderSunRay()

	if ( not SunRay:IsFullyCastable() or SunRay:IsHidden() or npcBot:HasModifier("modifier_phoenix_sun_ray") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = SunRay:GetCastRange()
	local nRadius = SunRay:GetSpecialValueInt( "radius" );
	local nCastPoint = SunRay:GetCastPoint();
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange( npcTarget, npcBot, nCastRange ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderSunRayStop()

	if ( not SunRayStop:IsFullyCastable() or SunRayStop:IsHidden() or not npcBot:HasModifier("modifier_phoenix_sun_ray") ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = SunRay:GetCastRange()
	local nRadius = SunRay:GetSpecialValueInt( "radius" );
	local nCastPoint = SunRay:GetCastPoint();
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	if ( tableNearbyAlliedHeroes ~= nil and tableNearbyEnemyHeroes ~= nil and #tableNearbyAlliedHeroes < #tableNearbyEnemyHeroes ) 
	     or tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 or ( npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.35 ) then
		return BOT_ACTION_DESIRE_MODERATE;
	end	
	
	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderToggleMovement()

	if ( not ToggleMovement:IsFullyCastable() or ToggleMovement:IsHidden() or not npcBot:HasModifier("modifier_phoenix_sun_ray") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, "";
	end
	
	local nCastRange = SunRay:GetCastRange()
	local nRadius = SunRay:GetSpecialValueInt( "radius" );
	local nCastPoint = SunRay:GetCastPoint();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) >= ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, "on";
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, "off";
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, "";

end

function ConsiderSupernova()

	if ( not Supernova:IsFullyCastable() or Supernova:IsHidden() or npcBot:HasModifier("modifier_phoenix_supernova_hiding") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, "";
	end
	
	if castIDSDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, "";
	end
	
	if castFSDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, "";
	end
	
	local nCastRange = Supernova:GetSpecialValueInt('cast_range_tooltip_scepter');
	local nRadius = Supernova:GetSpecialValueInt( "aura_radius" );
	local nCastPoint = Supernova:GetCastPoint();
	local nDamage = Supernova:GetSpecialValueInt("damage_per_sec") * Supernova:GetSpecialValueInt("tooltip_duration");
	
	if npcBot:HasScepter() and mutil.IsInTeamFight(npcBot, 1200) then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
		for _,ally in pairs(tableNearbyAllyHeroes)
		do
			if ( ally:GetActiveMode() == BOT_MODE_RETREAT or ally:GetHealth()/ally:GetMaxHealth() < 0.25 ) and ally:WasRecentlyDamagedByAnyHero(2.0) then
				return BOT_ACTION_DESIRE_HIGH, ally;
			end	
		end
	end
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes =  npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_ATTACK );
		local ASSlowedNum = 0;
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes) 
		do
			if npcEnemy:HasModifier('modifier_phoenix_fire_spirit_burn') then
				ASSlowedNum = ASSlowedNum + 1;
			end
		end
		
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and ( #tableNearbyEnemyHeroes - ASSlowedNum ) <= 1 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end
		
		if npcBot:WasRecentlyDamagedByAnyHero(2.0) and #tableNearbyAllyHeroes >= 2 and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( (nRadius / 2) + 200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_HIGH, "";
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, "";

end