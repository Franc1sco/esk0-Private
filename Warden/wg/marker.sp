
stock void Race_Marker_Start()
{
	if(IsWarden() == true && f_race_start[0] != 0.0)
	{
		TE_SetupBeamRingPoint(f_race_start, 79.9, 80.0, g_sprite, g_spriteHalo, 0, 10, 1.0, 5.0, 0.5, {25,255,25,255}, 10, 0);
		TE_SendToAll();
	}
}
stock void Race_Marker_End()
{
	if(IsWarden() == true  && f_race_konec[0] != 0.0)
	{
		TE_SetupBeamRingPoint(f_race_konec, 79.9, 80.0, g_sprite, g_spriteHalo, 0, 10, 1.0, 5.0, 0.5, {255,25,25,255}, 10, 0);
		TE_SendToAll();
	}
}
stock void Race_Beam_Start_End()
{
	if(IsWarden() == true && f_race_start[0] != 0.0 && f_race_konec[0] != 0.0 && b_gm_race == true)
	{
		float fEnd[3];
		AddVectors(fEnd, f_race_konec, fEnd);
		fEnd[2] += 0.0;

		LoopAliveClients(i)
		{
			if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true)
			{
				float fClient[3];
				GetClientEyePosition(i, fClient);
				fClient[2] -= 40.0;
				TE_SetupBeamPoints(fClient, fEnd, g_sprite, g_spriteHalo, 1, 1, 0.1, 4.0, 5.0, 0, 10.0, {255,255,25,255}, 5);
				TE_SendToClient(i);
			}
		}
	}
}
stock void Race_Reset_Marker()
{
	for(int i = 0; i < 3; i++)
	{
		f_race_start[i] = 0.0;
		f_race_konec[i] = 0.0;
	}
}
public bool TraceFilterAllEntities(int entity, int contentsMask, any client)
{
	if (entity == client)
		return false;
	if (entity > MaxClients)
		return false;
	if(!IsClientInGame(entity))
		return false;
	if(!IsPlayerAlive(entity))
		return false;

	return true;
}
