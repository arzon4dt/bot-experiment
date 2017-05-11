mode_push_tower_generic = dofile( GetScriptDirectory().."/ps/mode_push_tower" )

function OnStart()
	mode_push_tower_generic.OnStart();
end

function OnEnd()
	mode_push_tower_generic.OnEnd();
end

function GetDesire()
	return mode_push_tower_generic.GetDesire();
end

function Think()
	mode_push_tower_generic.Think();
end
