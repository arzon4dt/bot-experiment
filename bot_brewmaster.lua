local utils = require(GetScriptDirectory() ..  "/util")

local CastDMDesire = 0
local CastCYDesire = 0
local CastWWDesire = 0
local CastHBDesire = 0
local AttackDesire = 0
local MoveDesire = 0
local RetreatDesire = 0
local castSCDesire = 0;
local castCHDesire = 0;
local radius = 1000;

function  MinionThink(  hMinionUnit ) 

if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_storm") then
		
		if ( hMinionUnit:IsUsingAbility() ) then return end
		
		abilityDM = hMinionUnit:GetAbilityByName( "brewmaster_storm_dispel_magic" );
		abilityCY = hMinionUnit:GetAbilityByName( "brewmaster_storm_cyclone" );
		abilityWW = hMinionUnit:GetAbilityByName( "brewmaster_storm_wind_walk" );
		abilityCH = hMinionUnit:GetAbilityByName( "brewmaster_drunken_haze" );
		CastDMDesire, DMLocation = ConsiderDM(hMinionUnit); 
		CastCYDesire, CYTarget = ConsiderCY(hMinionUnit); 
		castCHDesire, castCHTarget = ConsiderCorrosiveHaze(hMinionUnit);
		CastWWDesire, WWTarget = ConsiderWW(hMinionUnit); 
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if ( CastDMDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnLocation( abilityDM, DMLocation );
			return;
		end
		
		if ( CastCYDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityCY, CYTarget );
			return;
		end
		
		if ( castCHDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
			return;
		end
		
		if ( CastWWDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityWW, WWTarget );
			return;
		end
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_earth") then
		
		if ( hMinionUnit:IsUsingAbility() ) then return end
		
		abilityHB = hMinionUnit:GetAbilityByName( "brewmaster_earth_hurl_boulder" );
		abilitySC = hMinionUnit:GetAbilityByName( "brewmaster_thunder_clap" );
		castSCDesire = ConsiderSlithereenCrush(hMinionUnit);
		CastHBDesire, HBTarget = ConsiderHB(hMinionUnit); 
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		RetreatDesire, RetreatLocation = ConsiderRetreat(hMinionUnit); 
		
		if ( RetreatDesire > 0 ) 
		then
			hMinionUnit:Action_MoveToLocation( RetreatLocation );
			return;
		end
		if ( castSCDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbility( abilitySC );
			return;
		end
		if ( CastHBDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityHB, HBTarget );
			return;
		end
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_fire") then
		
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if hMinionUnit:IsIllusion() then
		
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( GetBot():GetLocation() + RandomVector(100) );
			return
		end
		
	end
end
	
end

function CanCastCYOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared( ) or npcTarget:IsSilenced( ) then
		return true;
	end
	return false;
end

function ConsiderAttacking(hMinionUnit)
    local radius = 1000;
	local Target = nil;
	if IsDisabled(hMinionUnit) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
    local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( radius, true, BOT_MODE_NONE );
	if #NearbyEnemyHeroes > 0 then
		Target = GetClosestUnit(NearbyEnemyHeroes, hMinionUnit);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyCreeps = hMinionUnit:GetNearbyLaneCreeps( radius, true );
	if #NearbyEnemyCreeps > 0 then
	    Target = GetClosestUnit(NearbyEnemyCreeps, hMinionUnit);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyTowers = hMinionUnit:GetNearbyTowers( radius, true );
	if #NearbyEnemyTowers > 0 then
		Target = GetClosestUnit(NearbyEnemyTowers, hMinionUnit);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyBarracks = hMinionUnit:GetNearbyBarracks( radius, true );
	if #NearbyEnemyBarracks > 0 then
		Target = GetClosestUnit(NearbyEnemyBarracks, hMinionUnit);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function GetClosestUnit(tableNearbyEntity, hMinionUnit)
		local closestDistance = 5000;
		local closestEntity = tableNearbyEntity[1];
		for _,Entity in pairs( tableNearbyEntity )
		do
		if Entity:CanBeSeen() and not Entity:IsInvulnerable() then
			local distance = GetUnitToUnitDistance(Entity, hMinionUnit);
			if ( distance < closestDistance ) 
			then
				closestDistance = distance;
				closestEntity = Entity;
			end
		end	
		end
		
		return closestEntity;
end

function ConsiderMove(hMinionUnit)
	local radius = 1000;
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( radius, true, BOT_MODE_NONE );
	local NearbyEnemyCreeps = hMinionUnit:GetNearbyCreeps( radius, true );
	local NearbyEnemyTowers = hMinionUnit:GetNearbyTowers( radius, true );
	local NearbyEnemyBarracks = hMinionUnit:GetNearbyBarracks( radius, true );
	
	if NearbyEnemyHeroes[1] == nil and NearbyEnemyCreeps[1] == nil and NearbyEnemyTowers[1] == nil and NearbyEnemyBarracks[1] == nil then
		local location = Vector(0, 0)
		if GetOpposingTeam( ) == TEAM_DIRE then
			location = DB;
		end
		if GetOpposingTeam( ) == TEAM_RADIANT then
			location = RB;
		end
		return BOT_ACTION_DESIRE_LOW, location;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderRetreat(hMinionUnit)
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local tableNearbyAllyHeroes = hMinionUnit:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	local location = Vector(0, 0)
	if #tableNearbyAllyHeroes == 0 and #tableNearbyEnemyHeroes >= 2 then
		if GetOpposingTeam( ) == TEAM_DIRE then
			location = RB;
		end
		if GetOpposingTeam( ) == TEAM_RADIANT then
			location = DB;
		end
		return BOT_ACTION_DESIRE_LOW, location;
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderDM(hMinionUnit)

	if not abilityDM:IsFullyCastable() and abilityDM:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityDM:GetCastRange();
	local nRadius = abilityDM:GetSpecialValueInt( "radius" );
	
	local Allies = hMinionUnit:GetNearbyHeroes( nCastRange + nRadius, false, BOT_MODE_NONE );
		for _,Ally in pairs( Allies )
		do
			if ( IsDisabled(Ally) ) 
			then
				return BOT_ACTION_DESIRE_LOW, Ally:GetLocation();
			end
		end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if #tableNearbyEnemyHeroes == 1 and tableNearbyEnemyHeroes[1]:HasModifier("modifier_brewmaster_storm_cyclone") then
		return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation()
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderCY(hMinionUnit)

	if not abilityCY:IsFullyCastable() and abilityCY:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityCY:GetCastRange();
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = hMinionUnit:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local EnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( EnemyHeroes )
		do
			if ( CanCastCYOnTarget( npcEnemy ) and not IsDisabled(npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, hMinionUnit, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_LOW, npcMostDangerousEnemy;
		end
	end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 2*nCastRange, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and not IsDisabled(npcEnemy) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderCorrosiveHaze(hMinionUnit)

	if not abilityCH:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityCH:GetCastRange();
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = hMinionUnit:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local EnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( EnemyHeroes )
		do
			if ( CanCastCYOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, hMinionUnit, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_LOW, npcMostDangerousEnemy;
		end
	end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderWW(hMinionUnit)

	if not abilityWW:IsFullyCastable() and abilityWW:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityWW:GetCastRange();
	local tableNearbyAllyHeroes = hMinionUnit:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if ( GetUnitToUnitDistance(npcAlly, hMinionUnit) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcAlly;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSlithereenCrush(hMinionUnit)

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("damage");

	local locationAoE = hMinionUnit:FindAoELocation( true, true, hMinionUnit:GetLocation(), 0, nRadius, 0, 3000 );
	if ( locationAoE.count >= 1 ) then
		return BOT_ACTION_DESIRE_LOW;
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderHB(hMinionUnit)

	if not abilityHB:IsFullyCastable() and abilityHB:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityHB:GetCastRange();
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and GetUnitToUnitDistance(npcEnemy, hMinionUnit) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
