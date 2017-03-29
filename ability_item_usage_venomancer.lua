--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
----------------------------------------------------------------------------------------------------

local castPNDesire = 0;
local castPWDesire = 0;
local castVGDesire = 0;

function AbilityUsageThink()

local npcBot = GetBot();

-- Check if we're already using an ability
if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

abilityPW = npcBot:GetAbilityByName( "venomancer_plague_ward" );
abilityVG = npcBot:GetAbilityByName( "venomancer_venomous_gale" );
abilityPN = npcBot:GetAbilityByName( "venomancer_poison_nova" );

-- Consider using each ability
castPNDesire = ConsiderPoisonNova();
castPWDesire, castPWLocation = ConsiderPlagueWard();
castVGDesire, castVGLocation = ConsiderVenomGale();


if ( castPNDesire > castPWDesire and castPNDesire > castVGDesire )
then
npcBot:Action_UseAbility( abilityPN );
return;
end

if ( castPWDesire > 0 )
then
npcBot:Action_UseAbilityOnLocation( abilityPW, castPWLocation );
return;
end

if ( castVGDesire > 0 )
then
npcBot:Action_UseAbilityOnLocation( abilityVG, castVGLocation );
return;
end

end

----------------------------------------------------------------------------------------------------

function CanCastPlagueWardOnTarget( npcTarget )
return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end


function CanCastVenomGaleOnTarget( npcTarget )
return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastPoisonNovaOnTarget( npcTarget )
return npcTarget:CanBeSeen() and npcTarget:IsHero() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderPlagueWard()

local npcBot = GetBot();

-- Make sure it's castable
if ( not abilityPW:IsFullyCastable() )
then
return BOT_ACTION_DESIRE_NONE, 0;
end

-- If we want to cast Poison Nova at all, bail
if ( castPNDesire > 0 )
then
return BOT_ACTION_DESIRE_NONE, 0;
end

-- Get some of its values
--local nRadius abilityPW:GetSpecialValueInt( "radius" );

--^Special Value

local nCastRange = abilityPW:GetCastRange();

local creeps = npcBot:GetNearbyCreeps(1000, true)
local enemyHeroes = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
--------------------------------------
-- Mode based usage
--------------------------------------

if ( npcBot:GetActiveMode() == BOT_MODE_LANING and
npcBot:GetMana()/npcBot:GetMaxMana() >= 0.75 )
then
local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true);
if(tableNearbyEnemyCreeps[1] ~= nil) then
return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
end
end


if ( npcBot:GetActiveMode() == BOT_MODE_FARM and
npcBot:GetMana()/npcBot:GetMaxMana() >= 0.8 ) then

local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true);
if(tableNearbyEnemyCreeps[1] ~= nil) then
return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
end
end

-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT )
then
local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true);
if(tableNearbyEnemyCreeps[1] ~= nil and npcBot:GetMana()/npcBot:GetMaxMana() >= 0.5) then
return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
end
end



-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
then
local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
do
if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
then
if ( CanCastPlagueWardOnTarget( npcEnemy ) )
then
return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
end
end
end
end

-- If we're going after someone
if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
npcBot:GetActiveMode() == BOT_MODE_ROAM or
npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
npcBot:GetActiveMode() == BOT_MODE_GANK or
npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
then
local npcTarget = npcBot:GetTarget();

if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange )
then
return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(0.63);
end
end

return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function ConsiderVenomGale()
local npcBot = GetBot();

-- Make sure it's castable
if ( not abilityVG:IsFullyCastable() ) then
return BOT_ACTION_DESIRE_NONE, 0;
end
if ( castPNDesire > 0 ) then
return BOT_ACTION_DESIRE_NONE, 0;
end

-- Get some of its values
local nCastRange = abilityVG:GetCastRange();
local nRadius = 125;
local creeps = npcBot:GetNearbyCreeps(1000, true)
local enemyHeroes = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)


-- If we're farming and can kill 3+ creeps with GALE
if ( npcBot:GetActiveMode() == BOT_MODE_FARM and
npcBot:GetMana()/npcBot:GetMaxMana() >= 0.6 ) then

local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true);
if(tableNearbyEnemyCreeps[1] ~= nil) then
return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
end
end

if ( npcBot:GetActiveMode() == BOT_MODE_LANING and
npcBot:GetMana()/npcBot:GetMaxMana() >= 0.8 )
then
local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 1000, true);
if(tableNearbyEnemyCreeps[1] ~= nil) then
return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
end
end

-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
then
local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 100, true, BOT_MODE_NONE );
for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
do
if ( (npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange - 100) and CanCastVenomGaleOnTarget( npcEnemy ) )
then
return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
end
end
end

-- If a mode has set a target, and we can kill them, do it
local npcTargetToKill = npcBot:GetTarget();
if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastVenomGaleOnTarget( npcTargetToKill ) )
then
if ( (npcTargetToKill:GetHealth() / npcTargetToKill:GetMaxHealth()) < 0.25 and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange ) )
then
return BOT_ACTION_DESIRE_HIGH, npcTargetToKill:GetLocation();
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

if ( npcTarget ~= nil  and npcTarget:IsHero() and CanCastVenomGaleOnTarget( npcTarget ) )
then
if ( GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange ) )
then
return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
end
end
end

return BOT_ACTION_DESIRE_NONE, 0;
end


----------------------------------------------------------------------------------------------------

function ConsiderPoisonNova()

local npcBot = GetBot();

-- Make sure it's castable
if ( not abilityPN:IsFullyCastable() ) then
return BOT_ACTION_DESIRE_NONE;
end

-- Get some of its values
local nRadius = abilityPN:GetSpecialValueInt( "radius" );
local nCastRange = 0;
local nDamage = abilityPN:GetAbilityDamage();

--------------------------------------
-- Mode based usage
--------------------------------------

-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
then
local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
do
if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
then
if ( CanCastPoisonNovaOnTarget( npcEnemy ) )
then
return BOT_ACTION_DESIRE_MODERATE;
end
end
end
end

local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE  );
	if ( #tableNearbyEnemyHeroes >= 2 )
	then
		return BOT_ACTION_DESIRE_MODERATE;
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

	if ( npcTarget ~= nil and npcTarget:IsHero() )
	then
		local EnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 150, true, BOT_MODE_NONE );
		if ( CanCastPoisonNovaOnTarget( npcTarget ) and #EnemyHeroes >= 3 )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
end


return BOT_ACTION_DESIRE_NONE;

end 