public Action Event_OnRoundStart(Handle event,const char[] name,bool dontBroadcast)
{
  warden = -1;

  f_g_timer = GetGameTime();
  b_g_timer = true;
  b_g_disabled = false;

  Noblock = false;
  b_no_warden = false;
  Pause = false;
  Stopky = false;
  g_teamgames = false;
  g_teamgames_start = false;
  g_gamemodes = false;
  b_gm_lms = false;
  b_gm_lms_pre = false;
  b_gm_prestrelka = false;
  b_gm_schovka = false;
  b_gm_schovka_pre = false;
  b_gm_tagday = false;
  b_gm_zombieday = false;
  b_gm_zombieday_pre = false;
  b_gm_freeday = false;
  b_gm_s4s = false;
  b_gm_race = false;
  b_gm_race_pre = false;
  b_gm_lovecky = false;
  b_gm_lovecky_pre = false;
  b_hungergames = false;
  b_hungergames_pre = false;
  b_box = false;
  b_box_pre = false;

  b_gm_prestrelka_active = false;
  gm_lms = 0;
  Race_Reset_Marker();
  DisableFF();

  return Plugin_Continue;
}
public Action Event_OnRoundEnd(Handle event,const char[] name,bool dontBroadcast)
{
  SetCvarInt("mp_teammates_are_enemies",0);
  SetCvarInt("sv_infinite_ammo",0);
  SetCvarInt("sm_hosties_lr", 1);
  DisableFF();
  return Plugin_Continue;
}
public Action Event_OnPlayerSpawn(Handle event,const char[] name,bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  if(IsValidClient(client))
  {
    SetEntityRenderMode(client, RENDER_TRANSCOLOR);
    SetEntityRenderColor(client);
    SetEntityGravity(client, 1.0);
    tg_team[client] = 0;
    Grab[client] = false;
    if(IsValidClient(GrabTarget[client], true))
    {
      SetEntityMoveType(GrabTarget[client], MOVETYPE_WALK);
    }
    GrabTarget[client] = -1;
  }
  return Plugin_Continue;
}
public Action Event_OnPlayerHurt(Handle event,const char[] name,bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
  char weapon[32];
  GetEventString(event, "weapon", weapon, sizeof(weapon));
  if(IsValidClient(client))
  {
    if(GetClientTeam(client) == CS_TEAM_T)
    {
      if(g_teamgames == true)
      {
        if(tg_vybijena == true)
        {
          if(IsValidClient(attacker))
          {
            if(IsClientInTeam(client) && IsClientInTeam(attacker))
            if(StrEqual(weapon,"flashbang",false) == true)
            {
              SetEntityHealth(client, 0);
            }
          }
        }
      }
    }
  }
  return Plugin_Continue;
}
public Action Event_OnPlayerDeath(Handle event,const char[] name,bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
  if(IsValidClient(client))
  {
    LoopClients(i)
    {
      if(IsValidClient(i, true) && IsValidClient(client) && client == GrabTarget[i] && Grab[i])
      {
        Grab[i] = false;
        GrabTarget[i] = -1;
      }
    }
    if(IsClientWarden(client))
    {
      PrintToChatAll("[\x0bJail\x01] Warden \x0c%N \x02zemřel.", client);
      PrintHintTextToAll("<font color='#B00930' size='20'>Warden</font> <font color='#1E63E9' size='22'>%N</font> <font color='#B00930' size='22'>zemřel</font>", client);
      b_no_warden = true;
      f_no_warden = GetGameTime();
      RemoveWarden(client);
      if(g_teamgames == true)
      {
        StopTeamGames();
      }
      if(g_gamemodes == true)
      {
        if(b_gm_s4s == true)
        {
          PrintToChatAll("Shot 4 Shot vypnut");
          b_gm_s4s = false;
          g_gamemodes = false;
          DisableFF();
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T)
            {
              StripWeapons(i);
            }
          }
        }
        if(b_gm_race == true)
        {
          Race_Disable();
        }
        if(b_gm_schovka == true)
        {
          int count = 0;
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T)
            {
              count++;
            }
          }
          if(count <= 1)
          {
            g_gamemodes = false;
            b_gm_schovka = false;
            PrintToChatAll("[\x0bMOD\x01] \x04Schovka skončila.");
          }
        }
      }
    }
    if(g_teamgames == true)
    {
      char buffer[32];
      for(int team = 1; team < 6; team++)
      {
        if(GetPlayerTeam(client) == team)
        {
          tg_team[client] = 0;
          if(CountPlayersInTG(team) < 1)
          {
            Format(buffer, sizeof(buffer), "%sCH",tg_teams[team]);
            PrintToChatAll("[\x0bTG\x01] Tým \x03%s \x01vypadáva ze hry!", buffer);
          }
          break;
        }
      }
      if(GetLastTeam() != 0)
      {
        int team = GetLastTeam();
        PrintToChatAll("[\x0bTG\x01] \x03%s \x01tým vyhrává!",tg_teams[team]);
        StopTeamGames();
      }
      if(IsValidClient(attacker, true) && GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(client) == CS_TEAM_T && client != attacker)
      {
        SetEntProp(client, Prop_Data, "m_iFrags", GetClientFrags(client)+2);
      }
      if (client == client || attacker == 0)
      {
        SetEntProp(client, Prop_Data, "m_iFrags", GetClientFrags(client)+1);
      }
    }
    if(g_gamemodes == true)
    {
      if(b_gm_freeday == true)
      {
        if(CheckFreeDay() && FD_CountPlayer() > 0)
        {
          PrintToChatAll("[\x0bMOD\x01] \x06************************");
          PrintToChatAll("[\x0bMOD\x01] \x04*Volný den lze ukončit!*");
          PrintToChatAll("[\x0bMOD\x01] \x06************************");
        }
      }
      else if(b_gm_s4s == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T)
        {
          PrintToChatAll("[\x0bS4S\x01] Hráč \x03%N \x01vyhřadil \x03%N \x01ze hry!", attacker, client);
          SetEntityRenderColor(attacker);
          StripWeapons(attacker);
          SetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(attacker, CS_SLOT_KNIFE));
        }
        if(GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(client) == CS_TEAM_T)
        {
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T)
            {
              if(i_gm_s4s_team[client] == i_gm_s4s_team[i])
              {
                StripWeapons(i);
                i_gm_s4s_team[i] = 0;
                SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
                SetEntityRenderColor(i);
                break;
              }
            }
          }
        }
        i_gm_s4s_team[client] = 0;
        i_gm_s4s_team[attacker] = 0;
        S4S_Check();
      }
    }
    if(b_hungergames == true)
    {
      if(GetClientTeam(client) == CS_TEAM_T)
      {
        if(CountPlayersInTeam(CS_TEAM_T, true) == 1)
        {
          DisableFF();
          b_hungergames = false;
          PrintToChatAll("[\x0bMOD\x01] \x04HungerGames skončil.");
        }
      }
    }
    if(b_box == true)
    {
      if(GetClientTeam(client) == CS_TEAM_T)
      {
        if(CountPlayersInTeam(CS_TEAM_T, true) == 1)
        {
          DisableFF();
          b_box = false;
          PrintToChatAll("[\x0bMOD\x01] \x04Box skončil.");
        }
      }
    }
    if(b_gm_schovka == true)
    {
      if(CountPlayersInTeam(CS_TEAM_T, true, false) <= 1)
      {
        b_gm_schovka = false;
        g_gamemodes = false;
        PrintToChatAll("[\x0bMOD\x01] \x04Schovka skončila.");
      }
    }
  }
  return Plugin_Continue;
}
public void Event_OnWeaponFire(Handle event, const char[] name,bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  char wepname[64];
  GetEventString(event, "weapon", wepname, sizeof(wepname));
  if(IsValidClient(client, true) && g_teamgames == true && tg_granatovana == true)
  {
    if(StrEqual(wepname, "hegrenade", false) && GetClientTeam(client) == CS_TEAM_T && IsClientInTeam(client))
    {
      CreateTimer(2.5, Timer_TG_Granatovana_GiveHE, client, TIMER_FLAG_NO_MAPCHANGE);
    }
  }
  if(g_gamemodes == true)
  {
    if(b_gm_s4s == true)
    {
      if(GetClientTeam(client) == CS_TEAM_T)
      {
        if(StrEqual(wepname, s_gm_s4s_weapon) == true)
        {
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T && i != client)
            {
              if(i_gm_s4s_team[i] == i_gm_s4s_team[client])
              {
                SetEntData(i_gm_s4s_weaponi[i], g_OffsClip1, 1);
                break;
              }
            }
          }
        }
      }
    }
  }
}
public void Event_OnBulletImpact(Handle event, const char[] name,bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      if(GetClientButtons(client) & IN_USE)
      {
        float bulletOrigin[3];
        float bulletDestination[3];
        GetClientEyePosition(client, bulletOrigin);

        bulletOrigin[2] = (bulletOrigin[2] - 5);
        bulletDestination[0] = GetEventFloat( event, "x" );
        bulletDestination[1] = GetEventFloat( event, "y" );
        bulletDestination[2] = GetEventFloat( event, "z" );
        TE_SetupBeamPoints( bulletOrigin, bulletDestination, g_sprite, g_spriteHalo, 0, 0, 3.0, 0.5, 1.0, 1, 0.0, Laser_GetClientColor(client), 0);
        TE_SendToAll();
        for (int i = 0; i < 2; i++)
        {
          TE_SetupBeamRingPoint(bulletDestination, 1.0, 1.1, g_sprite, g_spriteHalo, 1, 1, 5.0, 10.0, 5.0, Laser_GetClientColor(client), 0, 0);
          TE_SendToAll();
        }
        Laser_LightCreate(bulletDestination);
      }
    }
  }
}
