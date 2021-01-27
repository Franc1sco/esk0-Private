stock bool IsWarden()
{
  if(warden != -1) return true;
  return false;
}
public void StartTeamGames()
{
  g_teamgames_start = true;
  f_teamgames_start = GetGameTime();
}
public void Race_Disable()
{
  g_gamemodes = false;
  b_gm_race = false;
  b_gm_race_pre = false;
  Race_Reset_Marker();
  PrintToChatAll("Závod byl ukončen!");
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true)
    {
      SetEntityMoveType(i, MOVETYPE_WALK);
      SetEntityRenderColor(i);
      b_Racers[i] = false;
    }
  }
}
public void StopTeamGames()
{
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == CS_TEAM_T && IsClientInTeam(i))
    {
      StripWeapons(i);
      SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
      SetEntityRenderColor(i);
      SetEntityHealth(i, 100);
      if(tg_knife == true)
      {
        int i_wep = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
        if(IsValidEntity(i_wep))
        {
          if(tg_knifeleftattack == false) SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
          if(tg_kniferightattack == false)  SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
        }
      }
      tg_team[i] = 0;
    }
  }
  DisableFF();
  SetCvarInt("sv_infinite_ammo", 0);
  g_teamgames = false;
  g_teamgames_start = false;
}
public void TG_ResetSettings()
{
  tg_weapon_damage = 1.0;
  tg_he_damage = 1.0;
  tg_random = true;
  tg_knifedmg = false;
  tg_knife = false;
  tg_vybijena = false;
  tg_granatovana = false;
  tg_weapons = false;
  tg_knifeonehit = false;
  tg_kniferightattack = true;
  tg_knifeleftattack = true;
}
public void CreateWarden(int client)
{
  warden = client;
  b_no_warden = false;
  if(IsPlayerVIP(client))
  {
    WardenVIPColorFix = CreateTimer(0.3,Timer_WardenVIPColorFix,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
  }
  else
  {
    WardenColorFix = CreateTimer(0.5,Timer_WardenColorFix,client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
  }
}
public void RemoveWarden(int client)
{
  warden = -1;
}
public void ChangeWardenTo(int client)
{
  SetEntityRenderColor(warden);
  RemoveWarden(warden);
  CreateWarden(client);
}
stock void SetCvarInt(const char[] cvarName, int value)
{
  Handle cvar = FindConVar(cvarName);
  if(cvar != INVALID_HANDLE)
  {
    int flags = GetConVarFlags(cvar);

    flags &= ~FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
    SetConVarInt(cvar, value);

    flags |= FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
  }
}
stock int FD_CountPlayer()
{
  int count = 0;
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == CS_TEAM_T)
    {
      count++;
    }
  }
  return count;
}
stock void SetCvarBool(const char[] cvarName, bool value)
{
  Handle cvar = FindConVar(cvarName);
  int flags = GetConVarFlags(cvar);

  flags &= ~FCVAR_NOTIFY;
  SetConVarFlags(cvar, flags);
  SetConVarBool(cvar, value);

  flags |= FCVAR_NOTIFY;
  SetConVarFlags(cvar, flags);
}
stock void ClearTimer(Handle &timer)
{
    if(timer != INVALID_HANDLE)
    {
        KillTimer(timer);
        timer = INVALID_HANDLE;
    }
}
stock void EnableNoBlock()
{
  Noblock = true;
  LoopClients(i)
  {
    if (IsValidClient(i, true))
    {
      SetEntData(i, NoBlockOffSet, 2, 4, true);
    }
  }
}
stock int GetPlayerTeam(int client)
{
	for (int team = 1; team < 6; team++)
	{
		if(tg_team[client] == team)
		{
			return team;
		}
	}
	return 0;
}
stock int CountPlayersInTeam(int team, bool alive = false, int dc = 0)
{
  int count = 0;
  LoopClients(i)
  {
    if(IsValidClient(i, alive) && GetClientTeam(i) == team)
    {
      count++;
    }
  }
  //PrintToChatAll("dc = %i",dc);
  return count - dc;
}
stock int CountPlayersInTG(int team)
{
	int CountPl = 0;
	LoopClients(i)
	{
		if(IsValidClient(i, true) && GetPlayerTeam(i) ==  team)
		{
			CountPl++;
		}
	}
	return CountPl;
}
stock bool IsClientInTeam(int client)
{
	for (int team = 1; team < 6; team++)
	{
		if(tg_team[client] == team)
		{
			return true;
		}
	}
	return false;
}
stock int CountTeamGamesTeams()
{
  int Team1 = 0;
  int Team2 = 0;
  int Team3 = 0;
  int Team4 = 0;
  int Team5 = 0;
  if(CountPlayersInTG(TG_TEAM_RED) > 0) Team1 = 1;
  if(CountPlayersInTG(TG_TEAM_BLUE) > 0) Team2 = 1;
  if(CountPlayersInTG(TG_TEAM_GREEN) > 0) Team3 = 1;
  if(CountPlayersInTG(TG_TEAM_BLACK) > 0) Team4 = 1;
  if(CountPlayersInTG(TG_TEAM_YELLOW) > 0) Team5 = 1;
  return Team1+Team2+Team3+Team4+Team5;
}
stock int GetLastTeam()
{
	if(CountPlayersInTG(1) >= 1 && CountPlayersInTG(2) < 1 && CountPlayersInTG(3) < 1 && CountPlayersInTG(4) < 1 && CountPlayersInTG(5) < 1)
	{
		return 1;
	}
	if(CountPlayersInTG(2) >= 1 && CountPlayersInTG(1) < 1 && CountPlayersInTG(3) < 1 && CountPlayersInTG(4) < 1 && CountPlayersInTG(5) < 1)
	{
		return 2;
	}
	if(CountPlayersInTG(3) >= 1 && CountPlayersInTG(2) < 1 && CountPlayersInTG(1) < 1 && CountPlayersInTG(4) < 1 && CountPlayersInTG(5) < 1)
	{
		return 3;
	}
	if(CountPlayersInTG(4) >= 1 && CountPlayersInTG(2) < 1 && CountPlayersInTG(3) < 1 && CountPlayersInTG(1) < 1 && CountPlayersInTG(5) < 1)
	{
		return 4;
	}
	if(CountPlayersInTG(5) >= 1 && CountPlayersInTG(2) < 1 && CountPlayersInTG(3) < 1 && CountPlayersInTG(4) < 1 && CountPlayersInTG(1) < 1)
	{
		return 5;
	}
	return 0;
}
stock bool CheckFreeDay(bool dc = false)
{
  int count = 0;
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == CS_TEAM_T)
    {
      count++;
    }
  }
  if(dc == true)
  {
    count = count - 1;
  }
  //PrintToChatAll("pocet zivych: %i, pri zapnuti bylo: %i",count,i_gm_freeday_count);
  float diff = float(count) / float(i_gm_freeday_count);
  //PrintToChatAll("rozdil je %f",diff);
  if(diff <= 0.34)
  {
    return true;
  }
  return false;
}
stock void DisableNoBlock()
{
  Noblock = false;
  LoopClients(i)
  {
    if(IsValidClient(i))
    {
      SetEntData(i, NoBlockOffSet, 5, 4, true);
    }
  }
}
stock void StripWeapons(int client)
{
  int wepIdx;
  for (int x = 0; x <= 5; x++)
  {
    //if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
    while ((wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
    {
      RemovePlayerItem(client, wepIdx);
      RemoveEdict(wepIdx);
    }
  }
  GivePlayerItem(client, "weapon_knife");
}
stock void StripAllWeapons(int client)
{
	int wepIdx;
	for (int x = 0; x <= 5; x++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
      RemoveEdict(wepIdx);
			//AcceptEntityInput(wepIdx, "Kill");
		}
	}
}
stock void StripAllGrenades(int client)
{
	int wepIdx;
	while ((wepIdx = GetPlayerWeaponSlot(client, 3)) != -1)
	{
    RemovePlayerItem(client, wepIdx);
    RemoveEdict(wepIdx);
		//AcceptEntityInput(wepIdx, "Kill");
	}
}
/*
stock void StripWeapons(int client)
{
	int wepIdx;
	for (int x = 0; x <= 5; x++)
	{
		if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
}
stock void StripAllWeapons(int client)
{
	int wepIdx;
	for (int x = 0; x <= 5; x++)
	{
		if ((wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
}
*/
stock int TG_GetAlivePlayersInTeam(int team)
{
  int count = 0;
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == team)
    {
      if(tg_team[i] == 0)
      {
        count++;
      }
    }
  }
  return count;
}
stock void AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
	float vecAngVectors[3];
	vecAngVectors = vecAngle;
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (int i; i < 3; i++)
  {
    output[i] = vecOrigin[i] + (vecAngVectors[i] * units);
  }
}
public void MovePlayer(int client)
{
	if(IsValidEntity(GrabTarget[client]))
	{
		float posent[3];
		float playerpos[3];
		GetEntPropVector(GrabTarget[client], Prop_Send, "m_vecOrigin", posent);
		GetClientEyePosition(client, playerpos);
		if (GrabNew[client])
		{
			GrabNew[client] = false;
			//CenterClientView(client, posent);
			GrabDistance[client] = GetVectorDistance(playerpos, posent);
			if (GrabDistance[client] > 250.0) GrabDistance[client] = 250.0;
			GrabCanMove[client] = false;
			CreateTimer(0.1, Timer_GrabEnableMove, client);
		}
		else if (GrabCanMove[client])
		{
			float playerangle[3];
			GetClientEyeAngles(client, playerangle);
			float pos[3];
			AddInFrontOf(playerpos, playerangle, GrabDistance[client], pos);
			if(IsValidClient(GrabTarget[client], true)) pos[2] -= 50;
			TeleportEntity(GrabTarget[client], pos, NULL_VECTOR, NULL_VECTOR);
		}

	}
}
public void EnableFF()
{
  for(int cvar; cvar < sizeof(s_frindlyfire_cvars); cvar++)
  {
    SetCvarBool(s_frindlyfire_cvars[cvar], true);
  }
}
public void DisableFF()
{
  for(int cvar; cvar < sizeof(s_frindlyfire_cvars); cvar++)
  {
    SetCvarBool(s_frindlyfire_cvars[cvar], false);
  }
}
public void S4S_Check()
{
  int count = 0;
  LoopAliveClients(i)
  {
    if(GetClientTeam(i) == CS_TEAM_T)
    {
      if(i_gm_s4s_team[i] != 0)
      {
        count++;
      }
    }
  }
  if(count == 0)
  {
    PrintToChatAll("Shot 4 Shot skončil!");
    DisableFF();
    b_gm_s4s = false;
    g_gamemodes = false;
  }
}
stock void SetClientBlind(int client, const int amount)
{
  int targets[2];
  targets[0] = client;
  int duration = 1536;
  int holdtime = 1536;
  int flags;
  if (amount == 0)
  {
    flags = (0x0001 | 0x0010);
  }
  else
  {
    flags = (0x0002 | 0x0008);
  }
  int color[4] = { 0,0,0,0 };
  color[3] = amount;
  Handle message = StartMessageEx(g_UserMsgFade, targets, 1);
  PbSetInt(message, "duration", duration);
  PbSetInt(message, "hold_time", holdtime);
  PbSetInt(message, "flags", flags);
  PbSetColor(message, "clr", color);
  EndMessage();
}
stock int Laser_GetClientColor(int client)
{
  int i_color[4];
  i_color[3] = 255;
  if(IsPlayerVIP(client))
  {
    char buffer[64];
    GetClientCookie(client, g_clientcookie, buffer, sizeof(buffer));
    if(StrEqual(buffer, "") == false)
    {
      if(StrEqual(buffer, "Random"))
      {
        i_color[0] = GetRandomInt(1,255);
        i_color[1] = GetRandomInt(1,255);
        i_color[2] = GetRandomInt(1,255);
      }
      else
      {
        char e_buffer[4][32];
        ExplodeString(buffer, " ", e_buffer, sizeof(e_buffer), sizeof(e_buffer[]));
        i_color[0] = StringToInt(e_buffer[1]);
        i_color[1] = StringToInt(e_buffer[2]);
        i_color[2] = StringToInt(e_buffer[3]);
      }
    }
    else
    {
      i_color[0] = 23;
      i_color[1] = 76;
      i_color[2] = 191;
    }
  }
  else
  {
    i_color[0] = 23;
    i_color[1] = 76;
    i_color[2] = 191;
  }
  return i_color;
}
stock void Laser_LightCreate(float pos[3])
{
	int entity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(entity, "inner_cone", "0");
	DispatchKeyValue(entity, "cone", "80");
	DispatchKeyValue(entity, "brightness", "1");
	DispatchKeyValueFloat(entity, "spotlight_radius", 150.0);
	DispatchKeyValue(entity, "pitch", "90");
	DispatchKeyValue(entity, "style", "1");
	DispatchKeyValue(entity, "_light", "75 75 255 255");
	DispatchKeyValueFloat(entity, "distance", 128.0);
	CreateTimer(5.0, Timer_Laser_Delete, entity, TIMER_FLAG_NO_MAPCHANGE);
	DispatchSpawn(entity);
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "TurnOn");
}
stock int GetClientAimTargetPos(int client, float pos[3])
{
  if(IsValidClient(client))
  {
    float vAngles[3]; float vOrigin[3];

    GetClientEyePosition(client,vOrigin);
    GetClientEyeAngles(client, vAngles);

    Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);

    TR_GetEndPosition(pos, trace);
    pos[2] += 5.0;

    int entity = TR_GetEntityIndex(trace);

    CloseHandle(trace);
    return entity;
  }
  return 0;
}

stock void KnockbackSetVelocity(int client, float startpoint[3], float endpoint[3], float magnitude)
{
  // Create vector from the given starting and ending points.
  float vector[3];
  MakeVectorFromPoints(startpoint, endpoint, vector);
  // Normalize the vector (equal magnitude at varying distances).
  NormalizeVector(vector, vector);
  // Apply the magnitude by scaling the vector (multiplying each of its components).
  ScaleVector(vector, magnitude);
  TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}

public bool KnockbackTRFilter(int entity, int contentsMask)
{
  // If entity is a player, continue tracing.
  if (entity > 0 && entity < MAXPLAYERS)
  {
    return false;
  }
  // Allow hit.
  return true;
}
