if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
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

function AbilityUsageThink()

	if npcBot:GetActiveMode() ~= mode then
		utils.PrintMode(npcBot:GetActiveMode());
		print("Desire = "..tostring(npcBot:GetActiveModeDesire()))
		mode = npcBot:GetActiveMode();
		
	end

	local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) then
			--print("Target:"..npcTarget:GetUnitName());
		end
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	
	if IcarusDive == "" then IcarusDive = npcBot:GetAbilityByName("phoenix_icarus_dive") end
	if IcarusDiveStop == "" then IcarusDiveStop = npcBot:GetAbilityByName("phoenix_icarus_dive_stop") end
	if FireSpirit == "" then FireSpirit = npcBot:GetAbilityByName("phoenix_fire_spirits") end
	if FireSpiritLaunch == "" then FireSpiritLaunch = npcBot:GetAbilityByName("phoenix_launch_fire_spirit") end
	if SunRay == "" then SunRay = npcBot:GetAbilityByName("phoenix_sun_ray") end
	if SunRayStop == "" then SunRayStop = npcBot:GetAbilityByName("phoenix_sun_ray_stop") end
	if ToggleMovement == "" then ToggleMovement = npcBot:GetAbilityByName("phoenix_sun_ray_toggle_move") end
	if Supernova == "" then Supernova = npcBot:GetAbilityByName("phoenix_supernova") end

	castIDDesire, castIDLocation = ConsiderIcarusDive();
	castIDSDesire = ConsiderIcarusDiveStop();
	castFSDesire = ConsiderFireSpirit();
	castFSLDesire, castFSLLocation = ConsiderFireSpiritLaunch();
	castSRDesire, castSRLocation = ConsiderSunRay();
	castSRSDesire = ConsiderSunRayStop();
	castTMDesire, state = ConsiderToggleMovement();
	castSNDesire = ConsiderSupernova();
	
	if castSNDesire > 0 then 
		npcBot:Action_UseAbility( Supernova );
		return;
	end
	
	if castIDDesire > 0 then 
		print("cast ID")
		npcBot:Action_UseAbilityOnLocation( IcarusDive, castIDLocation );
		return;
	end
	
	if castIDSDesire > 0 then 
		print("cast IDS")
		npcBot:Action_UseAbility( IcarusDiveStop );
		return;
	end
	
	if castFSDesire > 0 then 
		npcBot:Action_UseAbility( FireSpirit );
		print("cast FS")
		return;
	end
	
	if castFSLDesire > 0 then 
		npcBot:Action_UseAbilityOnLocation( FireSpiritLaunch, castFSLLocation );
		print("cast FSL")
		return;
	end
	
	if castSRDesire > 0 then 
		npcBot:Action_UseAbilityOnLocation( SunRay, castSRLocation );
		print("cast SR")
		return;
	end
	
	if castSRSDesire > 0 then 
		npcBot:Action_UseAbility( SunRayStop );
		print("cast SRS")
		return;
	end
	
	if castTMDesire > 0 then 
		npcBot:Action_UseAbility( ToggleMovement );
		if state == "on" then
			if not ToggleMovement:GetToggleState() then
				npcBot:Action_UseAbility( ToggleMovement );
				print("cast TM ON")
			end
		else
			if ToggleMovement:GetToggleState() then
				npcBot:Action_UseAbility( ToggleMovement );
				print("cast TM OFF")
			end
		end
		return;
	end
	
end

function ConsiderIcarusDive()

	if ( not IcarusDive:IsFullyCastable() or IcarusDive:IsHidden() or npcBot:HasModifier("modifier_phoenix_icarus_dive") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = IcarusDive:GetSpecialValueInt("dash_length");
	local nRadius = IcarusDive:GetSpecialValueInt( "dash_width" );
	local nCastPoint = IcarusDive:GetCastPoint();
	local nDamage = IcarusDive:GetSpecialValueInt("damage_per_second") * IcarusDive:GetSpecialValueFloat("burn_duration");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, utils.GetTowardsFountainLocation(GetAncient(GetTeam()):GetLocation(), nCastRange);
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange / 2 ) + 200 ) 
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and 
			 tableNearbyEnemyHeroes[1] ~= nil and GetUnitToUnitDistance(tableNearbyEnemyHeroes[1], npcBot) >= 900 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
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

	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, 2*nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderFireSpiritLaunch()

	if ( not FireSpiritLaunch:IsFullyCastable() or FireSpiritLaunch:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = FireSpirit:GetCastRange();
	local nRadius = FireSpirit:GetSpecialValueInt( "radius" );
	local nCastPoint = FireSpirit:GetCastPoint();
	local nDamage = FireSpirit:GetSpecialValueInt("damage_per_second") * FireSpirit:GetSpecialValueFloat("duration");
	local nSpeed = FireSpirit:GetSpecialValueInt("spirit_speed");
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			if not enemy:HasModifier("modifier_phoenix_fire_spirit_burn") then
				local eta = ( GetUnitToUnitDistance(enemy, npcBot) / nSpeed ) + nCastPoint ;
				return  BOT_ACTION_DESIRE_MODERATE, enemy:GetExtrapolatedLocation(eta);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange / 2 ) + 200 
			 and not npcTarget:HasModifier("modifier_phoenix_fire_spirit_burn") ) 
		then
			local eta = ( GetUnitToUnitDistance( npcTarget, npcBot ) / nSpeed ) + nCastPoint;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( eta );
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSunRay()

	if ( not SunRay:IsFullyCastable() or SunRay:IsHidden() or npcBot:HasModifier("modifier_phoenix_sun_ray") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = SunRay:GetCastRange()
	local nRadius = SunRay:GetSpecialValueInt( "radius" );
	local nCastPoint = SunRay:GetCastPoint();
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), (nCastRange / 2) + 200, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange / 2 ) + 200 ) 
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
	
	local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	
	if ( tableNearbyAlliedHeroes ~= nil and tableNearbyEnemyHeroes ~= nil and #tableNearbyAlliedHeroes < #tableNearbyEnemyHeroes ) then
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) > ( nCastRange / 2 ) + 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, "on";
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
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
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if castIDSDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if castFSDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = Supernova:GetCastRange();
	local nRadius = Supernova:GetSpecialValueInt( "aura_radius" );
	local nCastPoint = Supernova:GetCastPoint();
	local nDamage = Supernova:GetSpecialValueInt("damage_per_sec") * FireSpirit:GetSpecialValueInt("tooltip_duration");
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( (nRadius / 2) + 200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;

end