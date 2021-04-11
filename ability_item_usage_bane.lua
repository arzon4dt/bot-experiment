if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local role = require(GetScriptDirectory() .. "/RoleUtility");

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

local abilityQ = nil;
local abilityW = nil;
local abilityE = nil;
local abilityE2 = nil;
local abilityR = nil;

local ItemGC = nil;

local castQDesire  = 0;
local castWDesire  = 0;
local castEDesire  = 0;
local castE2Desire = 0;
local castRDesire  = 0;
local nmCastTime = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "bane_enfeeble" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "bane_brain_sap" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "bane_nightmare" ) end
	if abilityE2 == nil then abilityE2 = npcBot:GetAbilityByName( "bane_nightmare_end" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "bane_fiends_grip" ) end
	
	ItemGC = mutil.GetComboItem(npcBot, 'item_glimmer_cape')
	
	castQDesire, castQTarget = ConsiderQ();
	castWDesire, castWTarget = ConsiderW();
	castEDesire, castETarget = ConsiderE();
	castE2Desire             = ConsiderE2();
	castRDesire, castRTarget = ConsiderR();
	
	if ItemGC ~= nil and ItemGC:IsFullyCastable() and castRDesire > 0 then
		npcBot:Action_UseAbilityOnEntity( ItemGC, npcBot );
		return;
	end
	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityR, castRTarget );
		return;
	end

	if ( castEDesire > 0 ) 
	then
	    nmCastTime = DotaTime();
		npcBot:Action_UseAbilityOnEntity( abilityE, castETarget );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityW, castWTarget );
		return;
	end
	
	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
		return;
	end
	
	if ( castE2Desire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityE2 );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   = abilityQ:GetCastRange( );
	local nCastPoint   = abilityQ:GetCastPoint( );
	local nManaCost    = abilityQ:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and role.IsCarry(npcEnemy:GetUnitName()) and mutil.CanCastOnMagicImmune(npcEnemy) 
			     and not mutil.StillHasModifier(npcEnemy, 'modifier_bane_enfeeble') ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if mutil.AllowedToSpam(npcBot, nManaCost) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and mutil.CanCastOnNonMagicImmune(npcEnemy) and role.IsCarry(npcEnemy:GetUnitName())
			     and not mutil.StillHasModifier(npcEnemy, 'modifier_bane_enfeeble') ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and role.IsCarry(npcTarget:GetUnitName()) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and not mutil.StillHasModifier(npcTarget, 'modifier_bane_enfeeble')  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   = abilityW:GetCastRange();
	local nDamage      = abilityW:GetSpecialValueInt('brain_sap_damage');
	local nCastPoint   = abilityW:GetCastPoint( );
	local nManaCost    = abilityW:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) and npcBot:GetMaxHealth() - npcBot:GetHealth() > nDamage 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and npcBot:GetMaxHealth() - npcBot:GetHealth() > nDamage
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() or abilityE:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   = abilityE:GetCastRange();
	local nDamage      = abilityE:GetSpecialValueFloat('duration')*abilityE:GetAbilityDamage();
	local nCastPoint   = abilityE:GetCastPoint( );
	local nManaCost    = abilityE:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	if mutil.IsProjectileIncoming(npcBot, 300)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot;
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		if npcBot:GetHealth() < nDamage then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and #tableNearbyEnemyHeroes == 2 
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcEnemy ~= npcTarget and mutil.CanCastOnMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and not mutil.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( nCastRange-200, true, BOT_MODE_NONE );
			local enemies = npcTarget:GetNearbyHeroes( nCastRange-200, false, BOT_MODE_NONE );
			if ( allies == nil or #allies == 1 ) and #enemies == 1 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE2()
	
	-- Make sure it's castable
	if ( not abilityE2:IsFullyCastable() or abilityE2:IsHidden() or DotaTime() < nmCastTime + 1.5 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if ( mutil.StillHasModifier(npcAlly, 'modifier_bane_nightmare') ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) and mutil.StillHasModifier(npcTarget, 'modifier_bane_nightmare')
		then
			local allies = npcTarget:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
			local enemies = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			if ( #allies >= 2 and #enemies == 1 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   = abilityR:GetCastRange();
	local nDamage      = abilityR:GetSpecialValueFloat('fiend_grip_duration')*abilityE:GetSpecialValueInt('fiend_grip_damage');
	local nCastPoint   = abilityR:GetCastPoint( );
	local nManaCost    = abilityR:GetManaCost( );
	
	if npcBot:HasScepter() then
	
		nDamage = abilityR:GetSpecialValueFloat('fiend_grip_duration_scepter')*abilityR:GetSpecialValueInt('fiend_grip_damage_scepter');
		
	end	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and tableNearbyEnemyHeroes[1] ~=nil 
	then
		local tableNearbyAllyHeroes = tableNearbyEnemyHeroes[1]:GetNearbyHeroes( nCastRange-200, true, BOT_MODE_NONE );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2  
		then
			return BOT_ACTION_DESIRE_HIGH,  tableNearbyEnemyHeroes[1];
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and role.IsCarry(npcEnemy:GetUnitName()) and mutil.CanCastOnMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and not mutil.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( nCastRange-200, true, BOT_MODE_NONE );
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end