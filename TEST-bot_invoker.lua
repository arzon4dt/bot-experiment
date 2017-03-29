local nukeTOCMDB = false
local abilityQ = ""
local abilityW = ""
local abilityE = ""
local abilityR = ""
local abilityTO = ""
local abilityCM = ""
local abilityDB = ""

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]))
end

function VectorTowards(start, towards, distance)
    local facing = towards - start
    local direction = facing / GetDistance(facing, Vector(0,0)) --normalized
    return start + (direction * distance)
end

function invokeTornado(bot)
    -- Make sure invoke is castable
    if not abilityR:IsFullyCastable() then
        return false
    end

    bot:ActionPush_Delay(0.01)
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

    bot:ActionPush_Delay(0.01)
    bot:ActionPush_UseAbility( abilityR )
    bot:ActionPush_UseAbility( abilityE )
    bot:ActionPush_UseAbility( abilityW )
    bot:ActionPush_UseAbility( abilityE )

    return true
end

function prepNukeTOCMDB( bot )
    if not (abilityTO:IsFullyCastable() and abilityCM:IsFullyCastable() and abilityDB:IsFullyCastable()) then
        nukeTOCMDB = false
        return false
    end
    
    if abilityTO:IsHidden() then
        if abilityR:IsFullyCastable() then
            invokeTornado(bot)
            return true
        end
    else
        if abilityCM:IsHidden() then
            if abilityR:IsFullyCastable() then
                invokeChaosMeteor(bot)
                return true
            end
        else
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
                
            if nWex == 1 and nQuas == 1 and nExort == 1 then
                nukeTOCMDB = true
                return false
            else
                bot:ActionPush_Delay(0.01)
                bot:ActionPush_UseAbility(abilityQ)
                bot:ActionPush_UseAbility(abilityW)
                bot:ActionPush_UseAbility(abilityE)
                return true
            end
        end
    end
    
    return false
end

function nukeDamageTOCMDB( bot )
    local manaAvailable = bot:GetMana()
    local dmgTotal = 0
    local engageDist = 700
    
    if (abilityTO:IsFullyCastable() and  abilityCM:IsFullyCastable() and abilityDB:IsFullyCastable()) and
       (not abilityTO:IsHidden() and not abilityCM:IsHidden() and abilityR:IsFullyCastable()) and
       (manaAvailable >= (abilityTO:GetManaCost()+abilityCM:GetManaCost()+abilityR:GetManaCost()+abilityDB:GetManaCost())) then
    
        -- Tornado
        local damageTO = 70 + abilityTO:GetSpecialValueFloat("wex_damage")
        dmgTotal = dmgTotal + damageTO
    
        -- Check Chaos Meteor
        local burnDuration = 3.0
        local burnDamage = burnDuration * abilityCM:GetSpecialValueFloat("burn_dps")
        local mainDamage = abilityCM:GetSpecialValueFloat("main_damage")
        dmgTotal = dmgTotal + mainDamage + burnDamage
    
        -- Deafening Blast
        local damageDB = abilityDB:GetSpecialValueFloat("damage")
        dmgTotal = dmgTotal + damageDB
        
        engageDist = abilityTO:GetSpecialValueInt("travel_distance")
    end
    
    return dmgTotal, engageDist
end

function queueNukeTOCMDB(bot, location, engageDist)
    local dist = GetUnitToLocationDistance(bot, location)

    local liftDuration = abilityTO:GetSpecialValueFloat("lift_duration")
    local tornadoSpeed = abilityTO:GetSpecialValueInt("travel_speed")
    local cmLandTime = abilityCM:GetSpecialValueFloat("land_time")
    
    if dist < engageDist then
        bot:Action_ClearActions(true)

        print("INVOKER TO CM DB combo!!!")

        bot:ActionQueue_UseAbilityOnLocation(abilityTO, location)
        bot:ActionQueue_UseAbility(abilityR) -- invoke DB
        bot:ActionQueue_Delay(liftDuration - cmLandTime + engageDist/tornadoSpeed - 0.1) -- 0.1 for bot-difficulty avg delay
        bot:ActionQueue_UseAbilityOnLocation(abilityCM, VectorTowards(bot:GetLocation(), location, 200))
        bot:ActionQueue_Delay(0.4)
        bot:ActionQueue_UseAbilityOnLocation(abilityDB, location)
        bot:ActionQueue_Delay(0.01)
        return true
    end
    return false
end

local SKILL_Q = "invoker_quas"
local SKILL_W = "invoker_wex"
local SKILL_E = "invoker_exort"
local ABILITY1 = "special_bonus_attack_damage_15"
local ABILITY2 = "special_bonus_hp_125"
local ABILITY3 = "special_bonus_unique_invoker_1" -- +1 Forged Spirit Summoned
local ABILITY4 = "special_bonus_exp_boost_30"
local ABILITY5 = "special_bonus_all_stats_7"
local ABILITY6 = "special_bonus_attack_speed_35"
local ABILITY7 = "special_bonus_unique_invoker_2" -- AOE Deafening Blast
local ABILITY8 = "special_bonus_unique_invoker_3" -- -18s Tornado Cooldown

local AbilityPriority = {
    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_E,
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_E,    SKILL_Q,    SKILL_E,    ABILITY1,   ABILITY4,
    SKILL_W,    SKILL_W,    SKILL_Q,    SKILL_W,    ABILITY5,
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_Q,    ABILITY7
}

function LevelUp(bot)
    local ability = bot:GetAbilityByName(AbilityPriority[1])

    if ( ability == nil ) then
        table.remove( AbilityPriority, 1 )
        return
    end

    if ( ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel() ) then
        bot:ActionImmediate_LevelAbility(AbilityPriority[1])
        table.remove( AbilityPriority, 1 )
    end
end

function Think()
    local bot = GetBot()

    if not bot:IsAlive() then return end
    
    -- Check if we're already using an ability
    if bot:IsCastingAbility() or bot:IsChanneling() or bot:NumQueuedActions() > 0 then return end
    
    if bot:GetAbilityPoints() > 0 then
        LevelUp(bot)
    end

    if abilityQ == "" then abilityQ = bot:GetAbilityByName( "invoker_quas" ) end
    if abilityW == "" then abilityW = bot:GetAbilityByName( "invoker_wex" ) end
    if abilityE == "" then abilityE = bot:GetAbilityByName( "invoker_exort" ) end
    if abilityR == "" then abilityR = bot:GetAbilityByName( "invoker_invoke" ) end
    if abilityTO == "" then abilityTO = bot:GetAbilityByName( "invoker_tornado" ) end
    if abilityCM == "" then abilityCM = bot:GetAbilityByName( "invoker_chaos_meteor" ) end
    if abilityDB == "" then abilityDB = bot:GetAbilityByName( "invoker_deafening_blast" ) end
    
    if abilityQ:GetLevel() >= 3 then
        if nukeTOCMDB then
            local dmg, engageDist = nukeDamageTOCMDB( bot )
            local nearbyEnemyHeroes = bot:GetNearbyHeroes(engageDist, true, BOT_MODE_NONE)
            if #nearbyEnemyHeroes >= 1 then
                local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), engageDist, 200, 0, 0 )
                if locationAoE.count >= #nearbyEnemyHeroes - 1 then
                    if queueNukeTOCMDB(bot, locationAoE.targetloc, engageDist) then
                        nukeTOCMDB = false
                        return true
                    end
                end
            end
        else
            if prepNukeTOCMDB(bot) then return true end
        end
    end

    if DotaTime() > 0 then
        if bot:GetHealth() == bot:GetMaxHealth() then
            bot:Action_MoveToLocation( Vector( 0, 0 ) )
        else
            bot:Action_MoveToLocation( Vector( -7000, -7000 ) )
        end
    end
end