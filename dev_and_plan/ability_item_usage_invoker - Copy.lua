if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


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

local abilityQ = ""
local abilityW = ""
local abilityE = ""
local abilityR = ""

local abilityTO = ""
local abilityCS = ""
local abilityAC = ""
local abilityGW = ""
local abilityEMP = ""
local abilityCM = ""
local abilityDB = ""
local abilityIW = ""
local abilitySS = ""
local abilityFS = ""

local castTODesire = 0
local castCSDesire = 0
local castACDesire = 0
local castGWDesire = 0
local castEMPDesire = 0
local castCMDesire = 0
local castDBDesire = 0
local castIWDesire = 0
local castSSDesire = 0
local castFSDesire = 0

function AbilityUsageThink()

 if ( GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS and GetGameState() ~= GAME_STATE_PRE_GAME ) then return false end

    local bot = GetBot()

    if not bot:IsAlive() then return false end
		
    -- Check if we're already using an ability
    if bot:IsUsingAbility() or bot:IsChanneling() or bot:IsSilenced() then return false end
	
    if abilityQ == "" then abilityQ = bot:GetAbilityByName( "invoker_quas" ) end
    if abilityW == "" then abilityW = bot:GetAbilityByName( "invoker_wex" ) end
    if abilityE == "" then abilityE = bot:GetAbilityByName( "invoker_exort" ) end
    if abilityR == "" then abilityR = bot:GetAbilityByName( "invoker_invoke" ) end
	if abilityTO == "" then abilityTO = bot:GetAbilityByName( "invoker_tornado" ) end
    if abilityCS == "" then abilityCS = bot:GetAbilityByName( "invoker_cold_snap" ) end
    if abilityAC == "" then abilityAC = bot:GetAbilityByName( "invoker_alacrity" ) end
    if abilityGW == "" then abilityGW = bot:GetAbilityByName( "invoker_ghost_walk" ) end
    if abilityEMP == "" then abilityEMP = bot:GetAbilityByName( "invoker_emp" ) end
    if abilityCM == "" then abilityCM = bot:GetAbilityByName( "invoker_chaos_meteor" ) end
    if abilityDB == "" then abilityDB = bot:GetAbilityByName( "invoker_deafening_blast" ) end
    if abilityIW == "" then abilityIW = bot:GetAbilityByName( "invoker_ice_wall" ) end
    if abilitySS == "" then abilitySS = bot:GetAbilityByName( "invoker_sun_strike" ) end
    if abilityFS == "" then abilityFS = bot:GetAbilityByName( "invoker_forge_spirit" ) end

	local nearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	local nearbyEnemyCreep = bot:GetNearbyLaneCreeps( 1000, true );
	local nearbyEnemyTowers = bot:GetNearbyTowers( 1000, true );
    castTODesire, castTOLocation = ConsiderTornado(bot, nearbyEnemyHeroes)
    castEMPDesire, castEMPLocation = ConsiderEMP(bot)
    castCMDesire, castCMLocation = ConsiderChaosMeteor(bot,nearbyEnemyHeroes)
    castDBDesire, castDBLocation = ConsiderDeafeningBlast(bot)
    castSSDesire, castSSLocation = ConsiderSunStrike(bot)
    castCSDesire, castCSTarget = ConsiderColdSnap(bot)
    castACDesire = ConsiderAlacrity(bot, nearbyEnemyHeroes, nearbyEnemyCreep, nearbyEnemyTowers)
    castGWDesire = ConsiderGhostWalk(bot, nearbyEnemyHeroes)
    castIWDesire = ConsiderIceWall(bot, nearbyEnemyHeroes)
    castFSDesire = ConsiderForgedSpirit(bot,  nearbyEnemyHeroes, nearbyEnemyCreep, nearbyEnemyTowers)
	
	ConsiderEarlySpeels(bot)
	
	if not inGhostWalk(bot) then
		if castTODesire > 0 then
			--print("cast TO")
            if not abilityTO:IsHidden() then
                bot:Action_UseAbilityOnLocation( abilityTO, castTOLocation )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeTornado(bot)
                bot:ActionQueue_UseAbilityOnLocation( abilityTO, castTOLocation )
                return true
            end
        end
        
        if castCMDesire > 0 then
			--print("cast CM")
            if not abilityCM:IsHidden() then
                bot:Action_UseAbilityOnLocation( abilityCM, castCMLocation )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeChaosMeteor(bot)
                bot:ActionQueue_UseAbilityOnLocation( abilityCM, castCMLocation )
                return true
            end
        end

        if castEMPDesire > 0 then
			--print("cast EMP")
            if not abilityEMP:IsHidden() then
                bot:Action_UseAbilityOnLocation( abilityEMP, castEMPLocation )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeEMP(bot)
                bot:ActionQueue_UseAbilityOnLocation( abilityEMP, castEMPLocation )
                return true
            end
        end

        if castDBDesire > 0 then
			--print("cast DB")
            if not abilityDB:IsHidden() then
                bot:Action_UseAbilityOnLocation( abilityDB, castDBLocation )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeDeafeningBlast(bot)
                bot:ActionQueue_UseAbilityOnLocation( abilityDB, castDBLocation )
                return true
            end
        end

        if castCSDesire > 0 then
			--print("cast CS")
            if not abilityCS:IsHidden() then
                bot:Action_UseAbilityOnEntity( abilityCS, castCSTarget )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeColdSnap(bot)
                bot:ActionQueue_UseAbilityOnEntity( abilityCS, castCSTarget )
                return true
            end
        end

        if castSSDesire > 0 then
			--print("cast SS")
            if not abilitySS:IsHidden() then
                bot:Action_UseAbilityOnLocation( abilitySS, castSSLocation )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeSunStrike(bot)
                bot:ActionQueue_UseAbilityOnLocation( abilitySS, castSSLocation )
                return true
            end
        end
        
        if castACDesire > 0 then
			--print("cast AC")
            if not abilityAC:IsHidden() then
                bot:Action_UseAbilityOnEntity( abilityAC, bot )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeAlacrity(bot)
                bot:ActionQueue_UseAbilityOnEntity( abilityAC, bot )
                return true
            end
        end

        if castFSDesire > 0 then
			--print("cast FS")
            if not abilityFS:IsHidden() then
                bot:Action_UseAbility( abilityFS )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeForgedSpirit(bot)
                bot:ActionQueue_UseAbility( abilityFS )
                return true
            end
        end
        
        if castGWDesire > 0 then
			--print("cast GW")
            if not abilityGW:IsHidden() then
                bot:Action_UseAbility( abilityGW )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeGhostWalk(bot)
                bot:ActionQueue_UseAbility( abilityGW )
                return true
            end
        end

        if castIWDesire > 0 then
			--print("cast IW")
            if not abilityIW:IsHidden() then
                bot:ActionQueue_UseAbility( abilityIW )
                return true
            elseif abilityR:IsFullyCastable() then
                bot:Action_ClearActions(false)
                invokeIceWall(bot)
                bot:ActionQueue_UseAbility( abilityIW )
                return true
            end
        end
		
		local bRet = ConsiderOrbs(bot)
		if bRet then return end
        
	end
	
	 -- Initial invokes at low levels
	
	bRet = ConsiderShowUp(bot, nearbyEnemyHeroes)
	
    if bRet then return end
	
    return false
	
end

function ConsiderEarlySpeels(bot)
	 if bot:GetLevel() == 1 then
		if exortTrained() and abilitySS:IsHidden() then
			invokeSunStrike(bot)
			return
		elseif quasTrained() and abilityCS:IsHidden() then
			invokeColdSnap(bot)
			return
		elseif wexTrained() and abilityEMP:IsHidden() then
			invokeEMP(bot)
			return	
		end
    elseif bot:GetLevel() == 2 then
		if quasTrained() and exortTrained() and abilityCS:IsHidden() then
			tripleExortBuff(bot) -- this is first since we are pushing, not queueing
			invokeColdSnap(bot)
			return
		elseif quasTrained() and wexTrained() and abilityEMP:IsHidden()then 
			tripleWexBuff(bot) -- this is first since we are pushing, not queueing
			invokeEMP(bot)
			return
		end	
    end
end

function ConsiderShowUp(bot, nearbyEnemyHeroes)
	if inGhostWalk(bot) and #nearbyEnemyHeroes <= 1 or bot:HasModifier("modifier_item_dust") then
		bot:ActionPush_UseAbility(abilityW )
		bot:ActionPush_UseAbility(abilityW )
		bot:ActionPush_UseAbility(abilityW )
		return true
	end
    
    return false
end

function ConsiderOrbs(bot)
    local botModifierCount = bot:NumModifiers()
    local nQuas = 0
    local nWex = 0
    local nExort = 0
    
    for i = 0, botModifierCount-1, 1 do
        local modName = bot:GetModifierName(i)
        if modName == "modifier_invoker_wex_instance" then
            nWex = nWex + 1
        elseif modName == "modifier_invoker_quas_instance" then
            nQuas = nQuas + 1
        elseif modName == "modifier_invoker_exort_instance" then
            nExort = nExort + 1
        end
        
        if (nWex + nQuas + nExort) >= 3 then break end
    end
    
    if IsRetreating(bot) then
        if nWex < 3 then 
            tripleWexBuff(bot)
            return true
        end
    elseif bot:GetHealth()/bot:GetMaxHealth() < 0.75 then
        if nQuas < 3 then
            tripleQuasBuff(bot)
            return true
        end
    else
        if nExort < 3 then
            tripleExortBuff(bot)
            return true
        end
    end
    
    return false
end

function tripleExortBuff(bot)
    if exortTrained() then
        bot:ActionPush_UseAbility( abilityE )
        bot:ActionPush_UseAbility( abilityE )
        bot:ActionPush_UseAbility( abilityE )
    end
end

function tripleQuasBuff(bot)
    if quasTrained() then
        bot:ActionPush_UseAbility( abilityQ )
        bot:ActionPush_UseAbility( abilityQ )
        bot:ActionPush_UseAbility( abilityQ )
    end
end

function tripleWexBuff(bot)
    if wexTrained() then
        bot:ActionPush_UseAbility( abilityW )
        bot:ActionPush_UseAbility( abilityW )
        bot:ActionPush_UseAbility( abilityW )
    end
end

function inGhostWalk(bot)
    return bot:HasModifier("modifier_invoker_ghost_walk_self")
end

function quasTrained()
    return abilityQ:IsTrained()
end

function wexTrained()
    return abilityW:IsTrained()
end

function exortTrained()
    return abilityE:IsTrained()
end

function invokeTornado(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityW )

    return true
end

function invokeChaosMeteor(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityE )

    return true
end

function invokeDeafeningBlast(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityE )
    
    return true
end

function invokeForgedSpirit(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    

    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityE )

    return true
end

function invokeIceWall(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
	
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityE )
    return true
end

function invokeEMP(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityW )

    return true
end

function invokeColdSnap(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end

    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityQ )

    return true
end

function invokeSunStrike(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end

    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityE )

    return true
end

function invokeAlacrity(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end

    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityW )

    return true
end

function invokeGhostWalk(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end
    
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityQ )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityQ )

    return true
end

function IsValidTarget(npcTarget)
	if npcTarget ~= nil and npcTarget:IsHero() then
		return true;
	end
	return false;
end

function IsDisabled(npc)
	return npc:IsRooted() or npc:IsStunned() or npc:IsHexed( ) or npc:IsNightmared( );
end

function IsRetreating(npcBot)
	return npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
end

function IsDefending(npcBot)
	return npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		   npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		   npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
end

function IsPushing(npcBot)
	return npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		   npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		   npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT 
end

function CanCastAlacrityOnTarget( target )
    return not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastColdSnapOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastDeafeningBlastOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastChaosMeteorOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastTornadoOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastEMPOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastSunStrikeOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function CanCastIceWallOnTarget( target )
    return target:CanBeSeen() and not target:IsMagicImmune() and not target:IsInvulnerable()
end

function ConsiderTornado(bot, nearbyEnemyHeroes)
    if not quasTrained() or not wexTrained() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Make sure it's castable
    if not abilityTO:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Get some of its values
    local nDistance = abilityTO:GetSpecialValueInt( "travel_distance" )
    local nSpeed = 1000
    local nCastRange = abilityTO:GetCastRange()
    
    --------------------------------------
    -- Global high-priorty usage
    --------------------------------------

    -- Check for a channeling enemy
    for _, npcEnemy in pairs( nearbyEnemyHeroes ) do
        if npcEnemy:IsChanneling() and CanCastTornadoOnTarget(npcEnemy) then
            return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
        end
    end

    --------------------------------------
    -- Mode based usage
    --------------------------------------

    --------- RETREATING -----------------------
    if IsRetreating(bot) then
        for _,npcEnemy in pairs( nearbyEnemyHeroes ) do
            if bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance( bot, npcEnemy ) <= nDistance and CanCastTornadoOnTarget(npcEnemy) then
                return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation()
            end
        end
    end

    --------- TEAM FIGHT --------------------------------
    if #nearbyEnemyHeroes >= 2 then
        local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, 200, 0, 0 )

        if locationAoE.count >= 2 then
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
        end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget();
    if IsValidTarget(target) and CanCastTornadoOnTarget(target) then
        local dist = GetUnitToUnitDistance( target, bot )
        if dist < (nDistance - 200) then
            return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation( dist/nSpeed )
        end
    end

    return BOT_ACTION_DESIRE_NONE, {}
end

function ConsiderIceWall(bot, nearbyEnemyHeroes)
    if not quasTrained() or not exortTrained() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Make sure it's castable
    if  not abilityIW:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Get some of its values
    local nCastRange = abilityIW:GetSpecialValueInt( "wall_place_distance" )
    local nRadius = abilityIW:GetSpecialValueInt( "wall_element_radius" )

    --------------------------------------
    -- Mode based usage
    --------------------------------------

    --------- RETREATING -----------------------
    if IsRetreating(bot) then
        for _, npcEnemy in pairs( nearbyEnemyHeroes ) do
            if  ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or GetUnitToUnitDistance(npcEnemy, bot) < (nCastRange + nRadius) ) and CanCastIceWallOnTarget(npcEnemy) then
                return BOT_ACTION_DESIRE_MODERATE
            end
        end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget()
    if IsValidTarget(target) and CanCastIceWallOnTarget(target) then
        --FIXME: Need to check orientation
        if GetUnitToUnitDistance( bot, target ) < (nCastRange + nRadius) then
            return BOT_ACTION_DESIRE_MODERATE
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function ConsiderChaosMeteor(bot, nearbyEnemyHeroes)
    if not exortTrained() or not wexTrained() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Make sure it's castable
    if not abilityCM:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Get some of its values
    local nCastRange = abilityCM:GetCastRange()
    local nDelay = 1.35 -- 0.05 cast point, 1.3 land time
    local nTravelDistance = abilityCM:GetSpecialValueInt("travel_distance")
    local nRadius = abilityCM:GetSpecialValueInt("area_of_effect")

    --------------------------------------
    -- Mode based usage
    --------------------------------------
	local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 and  #nearbyEnemyHeroes >= 2 ) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange + nTravelDistance/2, nRadius, 0, 0 )
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget()
    if IsValidTarget(target) and CanCastChaosMeteorOnTarget(target) then
        if GetUnitToUnitDistance( target, bot ) < (nCastRange + nTravelDistance/2) then
            if IsDisabled(target) then
                return BOT_ACTION_DESIRE_MODERATE, target:GetLocation()
            else
                return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation( nDelay )
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, {}
end


function ConsiderSunStrike(bot)
    if not exortTrained() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Make sure it's castable
    if not abilitySS:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Get some of its values
    local nRadius = 175
    local nDelay = 2.0 -- 0.05 cast point, 1.7 delay, + some forgiveness
    local nDamage = abilitySS:GetSpecialValueFloat("damage")

    --------------------------------------
    -- Global Usage
    --------------------------------------
    local globalEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _,enemy in pairs(globalEnemies) do
        if enemy:GetHealth() <= nDamage and CanCastSunStrikeOnTarget(enemy) then
            if IsDisabled(enemy) then
                return BOT_ACTION_DESIRE_MODERATE, enemy:GetLocation()
            else
                return BOT_ACTION_DESIRE_MODERATE, enemy:GetExtrapolatedLocation( nDelay )
            end
        end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget()
    if IsValidTarget(target) and CanCastSunStrikeOnTarget(target) then
        if IsDisabled(target) then
            return BOT_ACTION_DESIRE_MODERATE, target:GetLocation()
        else
            return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation( nDelay )
        end
    end

    return BOT_ACTION_DESIRE_NONE, {}
end

function ConsiderDeafeningBlast(bot)
    if not quasTrained() or  not wexTrained() or not exortTrained() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Make sure it's castable
    if not abilityDB:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Get some of its values
    local nCastRange = abilityDB:GetCastRange()
    local nRadius = abilityDB:GetSpecialValueInt("radius_end")
    local nDamage = abilityDB:GetSpecialValueInt("damage")

    --------------------------------------
    -- Mode based usage
    --------------------------------------
    local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK )
    if ( #tableNearbyAttackingAlliedHeroes >= 2 )
    then
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
        local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
        if ( locationAoE.count >= 2 and #tableNearbyEnemyHeroes > 0 )
        then
            for _,npcEnemy in pairs (tableNearbyEnemyHeroes)
            do
                if CanCastDeafeningBlastOnTarget (npcEnemy) then
                    return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
                end
            end
        end
    end

    -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
    if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
    then
        local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastDeafeningBlastOnTarget (npcEnemy) )
            then
                return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation()
            end
        end
    end

    -- If a mode has set a target, and we can kill them, do it
    local npcTarget = bot:GetTarget()
    if ( npcTarget ~= nil and npcTarget:IsHero() )
    then
        if( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and
            GetUnitToUnitDistance( npcTarget, bot ) < nCastRange - (nCastRange/3) and
            CanCastDeafeningBlastOnTarget (npcTarget) )
        then
            return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
        end
    end

    -- If we're going after someone
    if ( bot:GetActiveMode() == BOT_MODE_ROAM or
         bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
         bot:GetActiveMode() == BOT_MODE_GANK or
         bot:GetActiveMode() == BOT_MODE_ATTACK or
         bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
    then
        local npcTarget = bot:GetTarget()

        if ( npcTarget ~= nil and npcTarget:IsHero() and
            GetUnitToUnitDistance( npcTarget, bot ) < nCastRange - (nCastRange/3) and
            CanCastDeafeningBlastOnTarget (npcTarget) )
        then
            return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, {}
end

function ConsiderEMP(bot)
    if not wexTrained() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Make sure it's castable
    if not abilityEMP:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, {}
    end

    -- Get some of its values
    local nCastRange = abilityEMP:GetCastRange()
    local nRadius = abilityEMP:GetSpecialValueInt( "area_of_effect" )
    local nBurn = abilityEMP:GetSpecialValueInt( "mana_burned" )
    local nPDamage = abilityEMP:GetSpecialValueInt( "damage_per_mana_pct" )

    --------------------------------------
    -- Mode based usage
    --------------------------------------

    local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK )
    if ( #tableNearbyAttackingAlliedHeroes >= 1 )
    then
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, ( nRadius/2 ), 0, 0 )

        if ( locationAoE.count >= 2 )
        then
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
        end
    end

    -- If we're going after someone
    if ( bot:GetActiveMode() == BOT_MODE_ROAM or
         bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
         bot:GetActiveMode() == BOT_MODE_GANK or
         bot:GetActiveMode() == BOT_MODE_ATTACK or
         bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
    then
        local npcTarget = bot:GetTarget()

        if ( npcTarget ~= nil and CanCastEMPOnTarget(npcTarget) and npcTarget:HasModifier("modifier_invoker_tornado") and GetUnitToUnitDistance( npcTarget, bot ) < (nCastRange - (nRadius / 2)) )
        then
            return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( )
        end
    end

    return BOT_ACTION_DESIRE_NONE, {}
end

function ConsiderGhostWalk(bot, nearbyEnemyHeroes)
    if not quasTrained() or not wexTrained() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Make sure it's castable
    if not abilityGW:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- WE ARE RETREATNG AND THEY ARE ON US
    if IsRetreating(bot) then
        for _, npcEnemy in pairs( nearbyEnemyHeroes ) do
            if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and GetUnitToUnitDistance( npcEnemy, bot ) < 600 then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end


function ConsiderColdSnap(bot)
    if not quasTrained() then
        return  BOT_ACTION_DESIRE_NONE, nil
    end

    -- Make sure it's castable
    if not abilityCS:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    -- Get some of its values
    local nCastRange = abilityCS:GetCastRange()

    --------------------------------------
    -- Global high-priorty usage
    --------------------------------------

    -- Check for a channeling enemy
    local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
    for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
    do
        if ( npcEnemy:IsChanneling() and CanCastColdSnapOnTarget(npcEnemy) )
        then
            return BOT_ACTION_DESIRE_HIGH, npcEnemy
        end
    end

    --------------------------------------
    -- Mode based usage
    --------------------------------------

    -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
    if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
    then
        local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastColdSnapOnTarget(npcEnemy) )
            then
                return BOT_ACTION_DESIRE_MODERATE, npcEnemy
            end
        end
    end

    local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK )
    if ( #tableNearbyAttackingAlliedHeroes >= 1 )
    then
        local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if ( GetUnitToUnitDistance( npcEnemy, bot ) < ( nCastRange ) and CanCastColdSnapOnTarget(npcEnemy) )
            then
                return BOT_ACTION_DESIRE_MODERATE, npcEnemy
            end
        end
    end


    -- If we're going after someone
    if ( bot:GetActiveMode() == BOT_MODE_ROAM or
         bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
         bot:GetActiveMode() == BOT_MODE_GANK or
         bot:GetActiveMode() == BOT_MODE_ATTACK or
         bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
    then
        local npcTarget = bot:GetTarget()

        if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, bot ) < nCastRange and CanCastColdSnapOnTarget(npcTarget) )
        then
            return BOT_ACTION_DESIRE_HIGH, npcTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function ConsiderAlacrity(bot, nearbyEnemyHeroes, nearbyEnemyCreep, nearbyEnemyTowers)
    if not wexTrained() or not exortTrained() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Make sure it's castable
    if not abilityAC:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    --------------------------------------
    -- Global high-priorty usage
    --------------------------------------
    -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
    if IsDefending(bot) or IsPushing(bot) then
        if #nearbyEnemyCreep >= 3 or #nearbyEnemyTowers > 0 then
            return BOT_ACTION_DESIRE_LOW
        end
    end
    --------------------------------------
    -- Mode based usage
    --------------------------------------
    for _,npcEnemy in pairs( nearbyEnemyHeroes ) do
        if GetUnitToUnitDistance( npcEnemy, bot ) < 600 then
            return BOT_ACTION_DESIRE_MODERATE
        end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget()
    if IsValidTarget(target) then
        return BOT_ACTION_DESIRE_MODERATE
    end

    if bot:GetActiveMode() == BOT_MODE_ROSHAN then
        local npcTarget = bot:GetTarget()
        if npcTarget ~= nil then
            return BOT_ACTION_DESIRE_LOW
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function ConsiderForgedSpirit(bot, nearbyEnemyHeroes, nearbyEnemyCreep, nearbyEnemyTowers)
    if not quasTrained() or not exortTrained() then
        return BOT_ACTION_DESIRE_NONE
    end

    -- Make sure it's castable
    if not abilityFS:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot:GetActiveMode() == BOT_MODE_ROSHAN then
        local npcTarget = bot:GetTarget()
        if npcTarget ~= nil then
            return BOT_ACTION_DESIRE_LOW
        end
    end

    --------------------------------------
    -- Global high-priorty usage
    --------------------------------------
    -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
    if IsDefending(bot) or IsPushing(bot) then
        if #nearbyEnemyCreep >= 3 or #nearbyEnemyTowers > 0 then
            return BOT_ACTION_DESIRE_LOW
        end
    end
    --------------------------------------
    -- Mode based usage
    --------------------------------------
    for _,npcEnemy in pairs( nearbyEnemyHeroes ) do
        if GetUnitToUnitDistance( npcEnemy, bot ) < 600 then
            return BOT_ACTION_DESIRE_MODERATE
        end
    end

    --------- CHASING --------------------------------
    local target = bot:GetTarget()
    if IsValidTarget(target) then
        return BOT_ACTION_DESIRE_MODERATE
    end

    return BOT_ACTION_DESIRE_NONE
end
