public Action Timer_WardenVIPColorFix(Handle timer,any client)
{
  if(IsValidClient(client))
  {
    if(IsClientWarden(client))
    {
      int color[3];
      color[0] = GetRandomInt(0,255);
      color[1] = GetRandomInt(0,255);
      color[2] = GetRandomInt(0,255);
      SetEntityRenderColor(client,color[0],color[1],color[2]);
    }
    else
    {
      SetEntityRenderColor(client);
      WardenVIPColorFix = INVALID_HANDLE;
      return Plugin_Stop;
    }
  }
  else
  {
    WardenVIPColorFix = INVALID_HANDLE;
    return Plugin_Stop;
  }
  return Plugin_Continue;
}
public Action Timer_WardenColorFix(Handle timer,any client)
{
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      SetEntityRenderColor(client,0,102,204);
    }
    else
    {
      SetEntityRenderColor(client);
      WardenColorFix = INVALID_HANDLE;
      return Plugin_Stop;
    }
  }
  else
  {
    WardenColorFix = INVALID_HANDLE;
    return Plugin_Stop;
  }
  return Plugin_Continue;
}
public Action Timer_GrabEnableMove(Handle timer, any client)
{
	GrabCanMove[client] = true;
	return Plugin_Stop;
}
public Action Timer_TG_Granatovana_GiveHE(Handle timer, any client)
{
  if(IsValidClient(client, true) && IsClientInTeam(client) && g_teamgames == true && tg_granatovana == true)
  {
    StripWeapons(client);
    GivePlayerItem(client,"weapon_hegrenade");
  }
  else
  {
    return Plugin_Stop;
  }
  return Plugin_Continue;
}
public Action Timer_TG_Vybijena_RemoveThinkTick(Handle timer, any entity)
{
	SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	CreateTimer(1.4, Timer_TG_Vybijena_RemoveFlashbang, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_TG_Vybijena_RemoveFlashbang(Handle timer, any entity)
{
	if (IsValidEntity(entity))
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		AcceptEntityInput(entity, "Kill");
		if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T && IsClientInTeam(client) && g_teamgames == true && tg_vybijena == true)
		{
			StripWeapons(client);
			int flash = CreateEntityByName("weapon_flashbang");
			DispatchSpawn(flash);
			EquipPlayerWeapon(client, flash);
		}
	}
}
public Action Timer_TG_Granatovana_Damage(Handle timer, any entity)
{
  float f_damage = GetEntPropFloat(entity, Prop_Send, "m_flDamage");
  SetEntPropFloat(entity, Prop_Send, "m_flDamage", f_damage*tg_he_damage);
}
public Action Timer_TagDay_Check(Handle timer, any client)
{
  if(b_gm_tagday == true)
  {
    int count = 0;
    LoopAliveClients(i)
    {
      if(GetClientTeam(i) == CS_TEAM_T && b_gm_tagday_tagged[i] == false)
      {
        count++;
      }
    }
    if(count == 0)
    {
      PrintToChatAll("Všichni vězni byli chyceni, nové kolo začne do 8 sekund!");
      CS_TerminateRound(8.0, CSRoundEnd_CTWin);
      return Plugin_Stop;
    }
  }
  else
  {
    return Plugin_Stop;
  }
  return Plugin_Continue;
}

public Action Timer_Race_Beacon(Handle timer)
{
  if(b_gm_race == true)
  {
    Race_Beam_Start_End();
    return Plugin_Continue;
  }
  else
  {
    return Plugin_Stop;
  }
}

public Action Timer_Laser_Delete(Handle timer, any entity)
{
  if(IsValidEntity(entity))
  {
    AcceptEntityInput(entity, "Kill");
  }
}
public Action Timer_DrawMakers(Handle timer, any data)
{
	Race_Marker_Start();
	Race_Marker_End();
	return Plugin_Continue;
}
public Action Timer_Marker(Handle timer)
{
  if(IsWarden() == true)
  {
    if(b_g_Marker == true)
    {
      TE_SetupBeamRingPoint(f_g_Marker, 139.9, 140.0, g_sprite, g_spriteHalo, 0, 10, 0.6, 5.0, 0.5, {0,0,255,255}, 35, 0);
      TE_SendToAll();
      float fStart[3];
      AddVectors(fStart, f_g_Marker, fStart);
      fStart[2] -= 10.0;
      float fEnd[3];
      AddVectors(fEnd, fStart, fEnd);
      fEnd[2] += 200.0;
      TE_SetupBeamPoints(fStart, fEnd, g_sprite, g_spriteHalo, 0, 10, 0.6, 4.0, 16.0, 1, 0.0, {0,0,255,255}, 35);
      TE_SendToAll();
    }
    else
    {
      return Plugin_Stop;
    }
  }
  else
  {
    return Plugin_Stop;
  }
  return Plugin_Continue;
}
