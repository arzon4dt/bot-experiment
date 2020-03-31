if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local meepoStatus = require(GetScriptDirectory() .."/meepo_status" )
local teamStatus = require( GetScriptDirectory() .."/team_status" )

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

----------------------------------------------------------------------------------------------------
if not GetBot():IsIllusion() then
	meepoStatus.AddMeepo(GetBot())
	teamStatus.AddHero(GetBot())
else
	print("ILLUSION ALERT!")
end

local castNetDesire = 0;
local castPoofDesire = 0;
local castBlinkInitDesire = 0; 
local castTalonDesire = 0;
local min = 0
local sec = 0
----------------------------------------------------------------------------------------------------
local courierTime = 0
----------------------------------------------------------------------------------------------------

function AbilityUsageThink()
	local npcBot = GetBot();

	min = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() ) then return end

	abilityNet = npcBot:GetAbilityByName( "meepo_earthbind" );
	abilityPoof = npcBot:GetAbilityByName( "meepo_poof" );
	itemBlink = "item_blink";
	itemTalon = "item_iron_talon";
	for i=0, 5 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if(_item == itemBlink) then
				itemBlink = npcBot:GetItemInSlot(i);
				meepoStatus.SetIsFarmed(true)
			end
			if(_item == itemTalon) then
				itemTalon = npcBot:GetItemInSlot(i);
			end
		end
	end

	-- Consider using each ability

	castNetDesire, castNetTarget = ConsiderEarthBind();
	castPoofDesire, castPoofTarget = ConsiderPoof();
	castBlinkInitDesire, castBlinkInitTarget = ConsiderBlinkInit();
	castTalonDesire, castTalonTarget = ConsiderTalon();

	local highestDesire = castNetDesire;
	local desiredSkill = 1;

	if ( castPoofDesire > highestDesire) 
		then
			highestDesire = castPoofDesire;
			desiredSkill = 2;
	end

	if ( castBlinkInitDesire > highestDesire) 
		then
			highestDesire = castBlinkInitDesire;
			desiredSkill = 3;
	end

	if ( castTalonDesire > highestDesire) 
		then
			highestDesire = castTalonDesire;
			desiredSkill = 4;
	end

	if highestDesire == 0 then return;
    elseif desiredSkill == 1 then 
		npcBot:Action_UseAbilityOnLocation( abilityNet, castNetTarget );
    elseif desiredSkill == 2 then 
		npcBot:Action_UseAbilityOnEntity( abilityPoof, castPoofTarget );
    elseif desiredSkill == 3 then 
		performBlinkInit( castBlinkInitTarget );
    elseif desiredSkill == 4 then 
		npcBot:Action_UseAbilityOnEntity( itemTalon, castTalonTarget );
	end	
end

----------------------------------------------------------------------------------------------------

function CanCastEarthBindOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderEarthBind()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityNet:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityNet:GetSpecialValueInt( "radius" );
	local nCastRange = abilityNet:GetCastRange();
	local nSpeed = abilityNet:GetSpecialValueInt( "speed" )

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
		for _,npcTarget in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcTarget, 2.0 ) ) 
			then
				if ( CanCastEarthBindOnTarget( npcTarget ) ) 
				then
				--print("retreat Net")
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(100);
				end
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			if ( not npcTarget:HasModifier("modifier_meepo_earthbind") and CanCastEarthBindOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange)
			then
				-- closest meepo with net should cast
				local closest = 0
				local distance = 100000
				for _,meepo in pairs(meepoStatus.GetMeepos()) do
					local net = meepo:GetAbilityByName("meepo_earthbind")
					if net:IsFullyCastable() or net:GetCooldownTimeRemaining() > 7 then
						if GetUnitToUnitDistance(meepo, npcTarget) < distance then
							distance = GetUnitToUnitDistance(meepo, npcTarget)
							closest = meepo
						end
					end
				end
				if closest ~= npcBot then
					return BOT_ACTION_DESIRE_NONE
				end

				--print("Chase Net At:" ..  GetUnitToUnitDistance( npcBot, npcTarget ) / 857 .. ":" .. tostring(npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance( npcBot, npcTarget ) / 857))  + npcTarget:GetLocation() ))
				return BOT_ACTION_DESIRE_MODERATE, (npcTarget:GetExtrapolatedLocation( GetUnitToUnitDistance( npcBot, npcTarget ) / 857  ));
			end
		end
	end

	-- If we're about to meepmeep someone

	if  npcBot:GetActiveMode() == BOT_MODE_ATTACK
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil) 
		then
			if ( CanCastEarthBindOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < 160)
			then
			--print("MeepMeep Net")
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(100);
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function CanCastPoofOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderPoof()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPoof:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- If we want to cast priorities at all, bail
	if ( castNetDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilityPoof:GetSpecialValueInt( "radius" );
	local nDamage = abilityPoof:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can poof away
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,meepo in pairs( meepoStatus.GetMeepos() )
		do
			if (meepo:GetActiveMode() ~= BOT_MODE_EVASIVE_MANEUVERS and
				meepo:GetActiveMode() ~= BOT_MODE_ATTACK and
				meepo:GetActiveMode() ~= BOT_MODE_ROSHAN and
				meepo:GetActiveMode() ~= BOT_MODE_DEFEND_ALLY and
				GetUnitToUnitDistance( npcBot, meepo ) > 1500 and
				meepo:DistanceFromFountain() < npcBot:DistanceFromFountain() ) -- TODO check that they aren't more screwed than you
			then
			--print("retreat Poof")
				return BOT_ACTION_DESIRE_MODERATE, meepo;
			end
		end
	end

	-- if we're in creep wave and in range of enemy hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local npcTarget = tableNearbyEnemyHeroes[1];

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastPoofOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius / 2 )
			then
				if(npcBot:GetMana() > (npcBot:GetMaxMana() * .75))
				then
				--print("Harass Poof")
					return BOT_ACTION_DESIRE_MODERATE, npcBot;
				end
			end
		else

		end
	end

		-- if we're farming and feel like it
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM and not ((min % 2 == 0 and sec > 40) or (min %2 == 1 and sec < 3)))
	then
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( nRadius, true ) 
		if(npcBot:GetMana() > (npcBot:GetMaxMana() * (.4 - (1 - (npcBot:GetHealth() / npcBot:GetMaxHealth())))) and #tableNearbyCreeps >= 2)
		then
		--print("Farm Poof")
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end

	-- if we're pushing
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID)
	then
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( nRadius, true ) 
		if(npcBot:GetMana() > (npcBot:GetMaxMana() * (.4 - (1 - (npcBot:GetHealth() / npcBot:GetMaxHealth())))) and #tableNearbyCreeps >= 4)
		then
		--print("Push Poof")
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end

	-- If we need to save another meepo
	if npcBot:GetActiveMode() ~= BOT_MODE_RETREAT and npcBot:GetHealth() > (npcBot:GetMaxHealth() * .4) then
		for _,meepo in pairs(meepoStatus.GetMeepos()) do
			tableNearbyEnemyHeroes = meepo:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and GetUnitToUnitDistance(npcBot, meepo) > 2000 then
				if meepo:WasRecentlyDamagedByAnyHero( 1.0 ) then
					return BOT_ACTION_DESIRE_HIGH, meepo
				end
			end
		end
	end

	-- If we're about to meepmeep someone
	if npcBot:GetActiveMode() ~= BOT_MODE_RETREAT and npcBot:GetHealth() > (npcBot:GetMaxHealth() * .4) then
		for _,meepo in pairs(meepoStatus.GetMeepos()) do
			tableNearbyEnemyHeroes = meepo:GetNearbyHeroes( 160, true, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and npcBot:GetHealth() > meepo:GetHealth() then
				if tableNearbyEnemyHeroes[1] ~= nil and meepo:GetActiveMode() ~= BOT_MODE_LANING then
					--print("Save Poof")
					return BOT_ACTION_DESIRE_HIGH, meepo;
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderBlinkInit()

	local npcBot = GetBot();

	-- Make sure it's castable
	if  not abilityPoof:IsFullyCastable() 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 1200;
	local nRadius = abilityPoof:GetSpecialValueInt( "radius" );
	local dmg = abilityPoof:GetAbilityDamage() * #meepoStatus.GetMeepos() * 1.25
	-- Find vulnerable enemy 
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	for k,v in ipairs(tableNearbyEnemyHeroes) do
		if(v:GetHealth() < dmg) then
			return BOT_ACTION_DESIRE_MODERATE, v:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function performBlinkInit( castBlinkInitTarget )
	local npcBot = GetBot();

	if( itemBlink ~= "item_blink" and itemBlink:IsFullyCastable()) then
		npcBot:Action_UseAbilityOnLocation( itemBlink, castBlinkInitTarget);
	end
end

----------------------------------------------------------------------------------------------------

function ConsiderTalon()
	local npcBot = GetBot();

	-- Make sure it's castable
	if (  itemTalon == "item_iron_talon" or not itemTalon:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if npcBot:GetActiveMode() == BOT_MODE_FARM then
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( 300, true ) 
		local health = 0
		local highHealthTarget = 0
		for _,v in pairs(tableNearbyCreeps) do
			if v:GetHealth() > health then
				health = v:GetHealth()
				highHealthTarget = v
			end
		end
		if health > 0 then
			return BOT_ACTION_DESIRE_HIGH, highHealthTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

----------------------------------------------------------------------------------------------------

-- attempt to disable buybacks for clones to prevent a clone buying in alone
if DotaTime() < 0 then
	
	--print("I would still like buy in permission plz")
	return
end

