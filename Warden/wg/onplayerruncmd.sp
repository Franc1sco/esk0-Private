public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
  if(IsValidClient(client) && Grab[client])
  {
    if(buttons & IN_ATTACK) GrabDistance[client] += 10.0;
    else if(buttons & IN_ATTACK2) GrabDistance[client] -= 10.0;
    else if(buttons & IN_RELOAD)
    {
      if(IsValidClient(Grab[client]))
      {
        int i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if(IsValidEntity(i_wep))
        {
          SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
          SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
        }
        Grab[client] = false;
        char classname[32];
        if(IsValidClient(GrabTarget[client]))
        {
          GetEntityClassname(GrabTarget[client], classname, sizeof(classname));
        }
        if(StrEqual(classname, "player"))
        {
          ForcePlayerSuicide(GrabTarget[client]);
        }
        GrabTarget[client] = -1;
      }
    }
    int i_wep;
    i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if(IsValidEntity(i_wep))
    {
      float f_gametime = GetGameTime();
      SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, f_gametime*2);
      SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, f_gametime*2);
    }
    if(IsValidClient(GrabTarget[client]))
    {
      i_wep = GetEntPropEnt(GrabTarget[client], Prop_Send, "m_hActiveWeapon");
    }
    if(IsValidEntity(i_wep))
    {
      float f_gametime = GetGameTime();
      SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, f_gametime*2);
      SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, f_gametime*2);
    }
    MovePlayer(client);
  }
  if(g_teamgames == true)
  {
    if(GetClientTeam(client) == CS_TEAM_T && IsClientInTeam(client))
    {
      SetEntityRenderColor(client, tg_color_r[tg_team[client]],tg_color_g[tg_team[client]],tg_color_b[tg_team[client]]);
      if(tg_knife == true)
      {
        int i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if(IsValidEntity(i_wep))
        {
          float f_gametime = GetGameTime();
          if(tg_knifeleftattack == false) SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, f_gametime*2);
          if(tg_kniferightattack == false)  SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, f_gametime*2);
        }
      }
    }
  }
  if(Pause == true)
  {
    if(IsClientAdmin(client) == false)
    {
      int i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
      float f_gametime = GetGameTime();
      SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, f_gametime*2);
      SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, f_gametime*2);
    }
  }
  if(g_gamemodes == true)
  {
    if(IsValidClient(client, true))
    {
      if(b_gm_race == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T && b_Racers[client] == true && b_Racers_Winners[client] == false)
        {
          float f_pos[3];
          GetClientAbsOrigin(client, f_pos);
          if(GetVectorDistance(f_pos, f_race_konec) < 40.0)
          {
            PrintToChatAll("[\x0cMOD\x01] Hráč: \x03%N \x01doběhl závod do konce!", client);
            b_Racers_Winners[client] = true;
            i_race_winners++;
            if(i_race_winners == i_race_stayalive)
            {
              LoopAliveClients(i)
              {
                if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true && b_Racers_Winners[i] == false)
                {
                  ForcePlayerSuicide(i);
                }
              }
              Race_Disable();
            }
          }
        }
      }
      if(b_gm_tagday == true)
      {
        if(buttons & IN_USE)
        {
          int target = GetClientAimTarget(client, true);
          if(IsValidClient(target, true))
          {
            if(GetClientTeam(client) == CS_TEAM_CT)
            {
              if(GetClientTeam(target) == CS_TEAM_T)
              {
                float c_origin[3];
                float t_origin[3];
                GetClientAbsOrigin(client, c_origin);
                GetClientAbsOrigin(target, t_origin);
                if(GetVectorDistance(c_origin,t_origin) <= 85.0)
                {
                  if(b_gm_tagday_tagged[target] == false)
                  {
                    PrintToChatAll("[\x0cMOD\x01] Policista \x03%N \x01chytil vězně \x03%N",client,target);
                    SetEntityMoveType(target, MOVETYPE_NONE);
                    SetEntityRenderColor(target, 255,0,0);
                    b_gm_tagday_tagged[target] = true;
                  }
                }
              }
            }
            else if(GetClientTeam(client) == CS_TEAM_T)
            {
              if(GetClientTeam(target) == CS_TEAM_T)
              {
                float c_origin[3];
                float t_origin[3];
                GetClientAbsOrigin(client, c_origin);
                GetClientAbsOrigin(target, t_origin);
                if(GetVectorDistance(c_origin,t_origin) <= 80.0)
                {
                  if(b_gm_tagday_tagged[target] == true && b_gm_tagday_tagged[client] == false)
                  {
                    PrintToChatAll("[\x0cMOD\x01] Vězeň \x03%N \x01osvobodil spoluvězně \x03%N", client, target);
                    SetEntityMoveType(target, MOVETYPE_WALK);
                    SetEntityRenderColor(target);
                    b_gm_tagday_tagged[target] = false;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  if(g_gamemodes == true)
  {
    if(IsValidClient(client, true))
    {
      if(b_gm_freeday == true)
      {
        if(b_gm_freeday_wep[client] == true)
        {
          float timeleft = f_gm_freeday_wep[client] - GetGameTime() + 8.0;
          if(timeleft < 0.01)
          {
            PrintToChat(client, "[\x0cVD\x01] \x07Nezahodil jsi včas zbraň, jsi označen jako rebel");
            SetEntityRenderColor(client, 255,0,0);
            b_gm_freeday_rebel[client] = true;
            b_gm_freeday_wep[client] = false;
          }
        }
      }
    }
  }
}
