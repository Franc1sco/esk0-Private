public Action EventSDK_OnWeaponCanUse(int client, int weapon)
{
  if(IsValidClient(client))
  {
    char buffer[32];
    if(IsValidEntity(weapon))
    {
      GetEntityClassname(weapon, buffer,sizeof(buffer));
    }
    if(g_teamgames == true)
    {
      if(GetClientTeam(client) == CS_TEAM_T && IsClientInTeam(client))
      {
        if(IsValidEntity(weapon))
        {
          if(tg_weapons == true)
          {
            if(tg_random == false)
            {
              //PrintToChatAll("tg: %s / g: %s",tg_weapon_classname,buffer);
              if(StrEqual(buffer,tg_weapon_classname) == false)
              {
                if(StrEqual(tg_weapon_classname,"weapon_cz75a") == true && StrEqual(buffer, "weapon_p250") == true)
                {
                  return Plugin_Continue;
                }
                if(StrEqual(tg_weapon_classname,"weapon_usp_silencer") == true && StrEqual(buffer, "weapon_hkp2000") == true)
                {
                  return Plugin_Continue;
                }
                if(StrEqual(tg_weapon_classname, "weapon_m4a1_silencer") == true && StrEqual(buffer, "weapon_m4a1") == true)
                {
                  return Plugin_Continue;
                }
                if(StrEqual(buffer,"weapon_knife") == true)
                {
                  return Plugin_Continue;
                }
                return Plugin_Handled;
              }
            }
          }
          else if(tg_knife == true)
          {
            if(StrEqual(buffer,"weapon_knife") == false)
            {
              return Plugin_Handled;
            }
          }
          else if(tg_granatovana == true)
          {
            if(StrEqual(buffer,"weapon_hegrenade") == true || StrEqual(buffer,"weapon_knife") == true)
            {
              //PrintToChatAll("knife:%i / he: %i",StrEqual(buffer,"weapon_knife"),StrEqual(buffer,"weapon_hegrenade"));
              return Plugin_Continue;
            }
            else
            {
              return Plugin_Handled;
            }
          }
        }
      }
    }
    if(g_gamemodes == true)
    {
      if(b_gm_schovka == true || b_gm_schovka_pre == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(StrEqual(buffer, "weapon_knife") == false)
          {
            return Plugin_Handled;
          }
          else
          {
            //PrintToChatAll("%N chtel sebrat %s",client,buffer);
            return Plugin_Continue;
          }
        }
      }
      if(b_gm_lovecky == true || b_gm_lovecky_pre == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(StrEqual(buffer, "weapon_knife") == false)
          {
            return Plugin_Handled;
          }
        }
        else if(GetClientTeam(client) == CS_TEAM_CT)
        {
          if(StrEqual(buffer, "weapon_knife") == true || StrEqual(buffer, "weapon_awp") == true)
          {
            return Plugin_Continue;
          }
          else
          {
            return Plugin_Handled;
          }
        }
      }
      else if(b_gm_zombieday == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(StrEqual(buffer, "weapon_knife") == false)
          {
            return Plugin_Handled;
          }
        }
        else if(GetClientTeam(client) == CS_TEAM_CT)
        {
          if(StrEqual(buffer, "weapon_hegrenade") == true || StrEqual(buffer, "weapon_molotov") == true || StrEqual(buffer, "weapon_incgrenade") == true || StrEqual(buffer, "weapon_smokegrenade") == true || StrEqual(buffer, "weapon_flashbang") == true || StrEqual(buffer, "weapon_decoy") == true)
          {
            return Plugin_Handled;
          }
        }
      }
      else if(b_gm_freeday == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(b_gm_freeday_rebel[client] == false)
          {
            for(int i; i < sizeof(s_gm_freeday_wep);i++)
            {
              if(StrEqual(buffer,s_gm_freeday_wep[i]) )
              {
                PrintToChat(client, "Sebral si zakázanou zbraň, okamžitě jí zahoď!");
                b_gm_freeday_wep[client] = true;
                f_gm_freeday_wep[client] = GetGameTime();
                break;
              }
            }
          }
        }
      }
      else if(b_gm_s4s == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(i_gm_s4s_team[client] != 0)
          {
            return Plugin_Handled;
          }
        }
      }
      else if (gm_lms > 0 || b_gm_prestrelka_active == true)
      {
        //PrintToChatAll("%N sebral: %s",client, buffer);
        if(StrEqual(buffer, "weapon_hegrenade") == true || StrEqual(buffer, "weapon_molotov") == true || StrEqual(buffer, "weapon_incgrenade") == true || StrEqual(buffer, "weapon_smokegrenade") == true || StrEqual(buffer, "weapon_flashbang") == true || StrEqual(buffer, "weapon_decoy") == true)
        {
          return Plugin_Handled;
        }
      }
    }
    if(Grab[client] == true)
    {
      return Plugin_Handled;
    }
    if(b_box == true)
    {
      if(GetClientTeam(client) == CS_TEAM_T)
      {
        if(StrEqual(buffer, "weapon_knife") == false)
        {
          return Plugin_Handled;
        }
      }
    }
  }
  return Plugin_Continue;
}
public Action EventSDK_OnWeaponDrop(int client, int weapon)
{
  char buffer[32];
  if(IsValidEntity(weapon))
  {
    GetEntityClassname(weapon, buffer,sizeof(buffer));
  }
  if(IsValidClient(client, true))
  {
    if(g_gamemodes == true)
    {
      if(b_gm_freeday == true)
      {
        if(b_gm_freeday_wep[client] == true)
        {
          for(int i; i < sizeof(s_gm_freeday_wep); i++)
          {
            if(StrEqual(buffer,s_gm_freeday_wep[i]) )
            {
              PrintToChat(client, "No máš štěstí, že jsi to zahodil");
              b_gm_freeday_wep[client] = false;
              break;
            }
          }
        }
      }
      else if(b_gm_s4s == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          if(i_gm_s4s_team[client] != 0)
          {
            return Plugin_Handled;
          }
        }
      }
      else if(b_gm_lovecky == true)
      {
        if(GetClientTeam(client) == CS_TEAM_CT)
        {
          return Plugin_Handled;
        }
      }
      else if(gm_lms == 2)
      {
          return Plugin_Handled;
      }
    }
  }
  return Plugin_Continue;
}
public Action EventSDK_OnWeaponSwitch(int client, int weapon)
{
  if(Pause)
  {
    if(IsClientAdmin(client) == false)
    {
      return Plugin_Handled;
    }
  }
  if(Grab[client])
  {
    return Plugin_Handled;
  }
  return Plugin_Continue;
}
public Action EventSDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
  char weapon_class[32];
  int buttons;
  if(IsValidClient(attacker))
  {
    buttons = GetClientButtons(attacker);
  }
  if(IsValidEntity(weapon))
  {
    GetEntityClassname(weapon, weapon_class, sizeof(weapon_class));
  }
  if(IsClientWarden(attacker))
  {
    if(buttons & IN_USE)
    {
      return Plugin_Handled;
    }
  }
  if(g_teamgames == true)
  {
    if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_T)
    {
      if(IsClientInTeam(attacker))
      {
        return Plugin_Handled;
      }
    }
    if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_CT)
    {
      return Plugin_Handled;
    }
    if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T)
    {
      if(IsClientInTeam(attacker) && !IsClientInTeam(victim) || !IsClientInTeam(attacker) && IsClientInTeam(victim))
      {
        return Plugin_Handled;
      }
      if(tg_team[victim] == tg_team[attacker])
      {
        return Plugin_Handled;
      }
      else
      {
        if(tg_weapons == true)
        {
          damage *= tg_weapon_damage;
          if(StrEqual(weapon_class,"weapon_knife") == true)
          {
            if(tg_knifedmg == false)
            {
              return Plugin_Handled;
            }
          }
          return Plugin_Changed;
        }
        else if(tg_knife == true)
        {
          if(tg_knifeonehit == true)
          {
            damage = 400.0;
            return Plugin_Changed;
          }
        }
        else if(tg_vybijena == true)
        {
          if(StrEqual(weapon_class,"weapon_knife") == true)
          {
            return Plugin_Handled;
          }
        }
        else if(tg_granatovana == true)
        {
          if(StrEqual(weapon_class,"weapon_knife") == true)
          {
            return Plugin_Handled;
          }
        }
      }
    }
  }
  if(g_gamemodes == true)
  {
    if(b_gm_schovka == true)
    {
      if(IsValidClient(attacker))
      {
        if(GetClientTeam(attacker) == CS_TEAM_T)
        {
          if(damage > 90.0)
          {
            damage = 90.0 * 0.5;
          }
          else
          {
            damage *= 0.5;
          }
          return Plugin_Changed;
        }
      }
    }
    else if(b_gm_lms_pre == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim)
        {
          return Plugin_Handled;
        }
      }
    }
    else if(b_gm_tagday == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim)
        {
          return Plugin_Handled;
        }
      }
    }
    else if(b_gm_freeday == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim && GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
        {
          b_gm_freeday_rebel[attacker] = true;
          PrintToChat(attacker, "Zautočil si na policistu, si označen jako rebel!");
          SetEntityRenderColor(attacker, 255,0,0);
        }
      }
    }
    else if(b_gm_lovecky == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim && GetClientTeam(attacker) == CS_TEAM_CT)
        {
          if(StrEqual(weapon_class,"weapon_awp") == false)
          {
            return Plugin_Handled;
          }
        }
      }
    }
    /* zombie day knockback
    else if(b_gm_zombieday == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim && GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT)
        {
          float knockback = 2.0; // knockback amount
          float victimloc[3];
          float attackerloc[3];

          GetClientAbsOrigin(victim, victimloc);
          // Get attackers eye position.
          GetClientEyePosition(attacker, attackerloc);
          // Get attackers eye angles.
          float attackerang[3];
          GetClientEyeAngles(attacker, attackerang);
          // Calculate knockback end-vector.
          TR_TraceRayFilter(attackerloc, attackerang, MASK_ALL, RayType_Infinite, KnockbackTRFilter);
          TR_GetEndPosition(victimloc);
          // Apply damage knockback multiplier.
          knockback *= damage;
          if(StrEqual(weapon_class,"weapon_negev") == true || StrEqual(weapon_class,"weapon_m249") == true) knockback *= 0.5;
          if(GetEntPropEnt(victim, Prop_Send, "m_hGroundEntity") == -1) knockback *= 0.5;
          // Apply knockback.
          KnockbackSetVelocity(victim, attackerloc, victimloc, knockback);
        }
      }
    }
    */
    else if(b_gm_s4s == true)
    {
      if(IsValidClient(attacker) && IsValidClient(victim))
      {
        if(attacker != victim)
        {
          if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_T)
          {
            if(StrEqual(s_gm_s4s_weapon, "weapon_cz75a") == true && StrEqual(weapon_class, "weapon_p250") == true)
            {
              return Plugin_Continue;
            }
            if(StrEqual(s_gm_s4s_weapon, "weapon_m4a1_silencer") == true && StrEqual(weapon_class, "weapon_m4a1") == true)
            {
              return Plugin_Continue;
            }
            if(StrEqual(s_gm_s4s_weapon, "weapon_usp_silencer") == true && StrEqual(weapon_class, "weapon_hkp2000") == true)
            {
              return Plugin_Continue;
            }
            if(StrEqual(weapon_class, s_gm_s4s_weapon) == false)
            {
              return Plugin_Handled;
            }
            if(i_gm_s4s_team[victim] != i_gm_s4s_team[attacker])
            {
              return Plugin_Handled;
            }
          }
          if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT && i_gm_s4s_team[attacker] != 0)
          {
            return Plugin_Handled;
          }
          if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_CT)
          {
            return Plugin_Handled;
          }
        }
      }
    }
  }
  if(b_box == true)
  {
    if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
    {
      return Plugin_Handled;
    }
    if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_CT)
    {
      return Plugin_Handled;
    }
  }
  if(b_hungergames == true)
  {
    if(GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(victim) == CS_TEAM_CT)
    {
      return Plugin_Handled;
    }
    if(IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_CT)
    {
      return Plugin_Handled;
    }
  }
  return Plugin_Continue;
}
public void EventSDK_OnClientThink(int client)
{
  if(IsValidClient(client, true))
  {
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    char wep_name[MAX_NAME_LENGTH];
    if (IsValidEdict(weapon))
    {
      GetEdictClassname(weapon, wep_name, sizeof(wep_name));
    }
    if(g_gamemodes == true)
    {
      if(b_gm_zombieday == true)
      {
        if(GetClientTeam(client) == CS_TEAM_T)
        {
          SetEntityGravity(client, 0.6);
          SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
          if(StrEqual(wep_name, "weapon_knife") == false)
          {
            SetEntDataFloat(weapon, g_offsNextPrimaryAttack, GetGameTime() + 2.0);
            SetEntDataFloat(weapon, g_offsNextSecondaryAttack, GetGameTime() + 2.0);
          }
        }
      }
      else if(b_gm_lovecky == true)
      {
        if(GetClientTeam(client) == CS_TEAM_CT)
        {
          if(StrEqual(wep_name, "weapon_awp"))
          {
            SetEntDataFloat(weapon, g_offsNextSecondaryAttack, GetGameTime() + 2.0);
          }
        }
        else if(GetClientTeam(client) == CS_TEAM_T)
        {
          SetEntityGravity(client, 0.6);
          SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
        }
      }
    }
  }
}
