--print(tostring(GetBot())..tostring(GetBot():GetLocation()))
if GetBot():GetLocation() == Vector(0.000000, 0.000000, 0.000000) or DotaTime() > 0 and not GetBot():IsInvulnerable() then return; end
--if GetBot():GetLocation().z ~= 512.000000 then return; end

local npcBot = GetBot();
local DIRE_VEC  = Vector(7300.000000, 6099.996094, 512.000000);
local RADI_VEC  = Vector(-7100.000000, -6150.003906, 512.000000);
local RADI_VEC2 = Vector(-6147.167969, -6719.886230, 384.000000);
local RADI_VEC3 = Vector(-7159.090332, -5699.872070, 470.449310);

function  MinionThink(  hMinionUnit ) 

end

function Think()
	
end