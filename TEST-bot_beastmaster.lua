function  MinionThink(  hMinionUnit ) 
	print("Test");
	if string.find(hMinionUnit:GetUnitName(), "boar") then
		hMinionUnit:Action_MoveToLocation( Vector( 0, 0, 0 ) );
	end
	
end
