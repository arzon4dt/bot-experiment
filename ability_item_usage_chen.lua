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

local castFBDesire = 0;
local castUFBDesire = 0;
local castACDesire = 0;
local castHPDesire = 0;
local castHoGDesire = 0;


function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityUFB = npcBot:GetAbilityByName( "chen_penitence" );
	abilityFB = npcBot:GetAbilityByName( "chen_test_of_faith" );
	abilityAC = npcBot:GetAbilityByName( "chen_test_of_faith_teleport" );
	abilityHP = npcBot:GetAbilityByName( "chen_holy_persuasion" );
	abilityHoG = npcBot:GetAbilityByName( "chen_hand_of_god" );

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castACDesire, castACTarget = ConsiderAphoticShield();
	castHPDesire, castHPTarget = ConsiderHolyPersuasion();
	castHoGDesire = ConsiderHandofGod();
	
	if ( castHoGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityHoG );
		return;
	end
	
	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end

	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castHPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityHP, castHPTarget );
		return;
	end


end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastAphoticShieldOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end


function ConsiderUnrefinedFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and CanCastFireblastOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetSpecialValueInt("damage_max");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PURE ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and CanCastFireblastOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and  CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200  ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderHolyPersuasion()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityHP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityHP:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local maxHP = 0;
	local NCreep = nil;
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 1000 );
	
	if npcBot:HasScepter() and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP 
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	elseif not npcBot:HasScepter() and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then	
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP and not neutral:IsAncientCreep()
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	end
	
	if NCreep ~= nil then
		return BOT_ACTION_DESIRE_LOW, NCreep;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
function ConsiderAphoticShield()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityAC:GetCastRange();

	-- If we're in a teamfight, use it on the scariest enemy
	local lowHpAlly = nil;
	local nLowestHealth = 10000;

	local tableNearbyAllies = npcBot:GetNearbyHeroes( 1100, false, BOT_MODE_NONE  );
	for _,npcAlly in pairs( tableNearbyAllies )
	do
		if ( CanCastAphoticShieldOnTarget( npcAlly ) and npcAlly:GetUnitName() ~= npcBot:GetUnitName() and npcAlly:IsHero() and not npcAlly:IsIllusion() )
		then
			local nAllyHP = npcAlly:GetHealth();
			if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) and
				( npcAlly:GetActiveMode() == BOT_MODE_RETREAT and npcAlly:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
				)
			then
				nLowestHealth = nAllyHP;
				lowHpAlly = npcAlly;
			end
		end
	end

	if ( lowHpAlly ~= nil )
	then
		return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderHandofGod()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityHoG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	local maxDist = 0;
	local target = nil;
	for i = 1, #numPlayer
	do
		local Ally = GetTeamMember(i);
		if Ally:IsAlive() and 
			Ally:GetActiveMode() == BOT_MODE_RETREAT and Ally:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH and
			Ally:GetHealth() /Ally:GetMaxHealth() < 0.45 and Ally:WasRecentlyDamagedByAnyHero(2.0)
		then
			target = GetTeamMember(i);
			break;
		end
	end
	if target ~= nil then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end



