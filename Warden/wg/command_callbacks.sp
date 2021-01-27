public Action Command_LookAtWeapon(int client, const char[] command, int argc)
{
  if(IsValidClient(client, true) && IsClientWarden(client))
  {
    GetClientAimTargetPos(client, f_g_Marker);
    f_g_Marker[2] += 5.0;
    b_g_Marker = !b_g_Marker;
    if(b_g_Marker == true)
    {
      CreateTimer(0.3, Timer_Marker ,_,TIMER_REPEAT);
      PrintToChat(client, "[INFO] Vytvoril jsi kruh.");

    }
    else
    {
      PrintToChat(client, "[INFO] Smazal jsi kruh.");
    }
  }
  return Plugin_Continue;
}
public Action Command_Warden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsWarden() == false)
    {
      if(GetClientTeam(client) == CS_TEAM_CT)
      {
        if(IsPlayerAlive(client))
        {
          CreateWarden(client);
          PrintHintTextToAll("<font color='#B00930' size='22'>Wardenem se stal</font><br><font color='#416fff' size='28'>%N</font>", client);
          PrintToChatAll("[\x0bJail\x01] \x06Wardenem se stal \x0c%N", client);
        }
        else
        {
          PrintToChat(client, "[\x02INFO\x01] Jsi mrtvý, nemůžeš být Warden!");
        }
      }
      else
      {
        PrintToChat(client, "[\x02INFO\x01] Wardenem může být pouze CT.");
      }
    }
    else
    {
      if(IsClientWarden(client))
      {
        CreateWardenMenu(client);
      }
      else
      {
        PrintToChat(client, "[\x0bJail\x01] \x06Wardenem je \x0c%N", warden);
        PrintHintText(client, "<font color='#B00930' size='22'>Wardenem je</font><br><font color='#416fff' size='28'>%N</font>", warden);
      }
    }
  }
  return Plugin_Handled;
}
public Action Command_UnWarden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsClientWarden(client))
    {
      RemoveWarden(client);
      PrintHintTextToAll("<font color='#B00930' size='28'>%N</font><br><font color='#416fff' size='22'>se vzdal funkce Wardena</font>", client);
      PrintToChatAll("[\x0bJail\x01] Warden \x0c%N\x01 se vzdal funkce Wardena.", client);
    }
    else
    {
      PrintToChat(client, "[\x02INFO\x01] Nejsi Warden, abys mohl opustit funkci Wardena.");
    }
  }
  return Plugin_Handled;
}
public Action Command_SetWarden(int client,int args)
{
  if(IsValidClient(client))
  {
    Menu menu = CreateMenu(m_SetWarden);
    menu.SetTitle("Vyber hráče");
    LoopAliveClients(i)
    {
      if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
      {
        char userid[11];
        char username[MAX_NAME_LENGTH];
        IntToString(GetClientUserId(i), userid, sizeof(userid));
        Format(username, sizeof(username), "%N", i);
        menu.AddItem(userid,username);
      }
    }
    menu.ExitButton = true;
    menu.Display(client,MENU_TIME_FOREVER);
  }
  return Plugin_Handled;
}
public Action Command_JailAdmin(int client,int args)
{
  if(IsValidClient(client))
  {
    CreateJailAdminMenu(client);
  }
}
public Action Command_RemoveWarden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsWarden() == true)
    {
      PrintHintTextToAll("<font color='#416fff' size='28'>%N</font><br><font color='#B00930' size='22'>byl vyhozen z funkce</font>", warden);
      PrintToChatAll("[\x0bJail\x01] Warden \x0c%N\x02 byl vyhozen z funkce Adminem.", warden);
      RemoveWarden(warden);
    }
    else
    {
  	  PrintToChat(client, "[SM] Není koho vyhodit z funkce Wardena.");
    }
  }
  return Plugin_Handled;
}
public Action Command_Grab(int client,int args)
{
  if(IsValidClient(client))
  {
    if(Grab[client])
    {
      int i_wep;
      i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
      if(IsValidEntity(i_wep))
      {
        SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
        SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
      }
      i_wep = GetEntPropEnt(GrabTarget[client], Prop_Send, "m_hActiveWeapon");
      if(IsValidEntity(i_wep))
      {
        SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
        SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
      }
      Grab[client] = false;
      if(IsValidClient(GrabTarget[client], true))
      {
        SetEntityRenderColor(GrabTarget[client]);
        SetEntityMoveType(GrabTarget[client], MOVETYPE_WALK);
      }
      else
      {
        TeleportEntity(GrabTarget[client], NULL_VECTOR, NULL_VECTOR,view_as<float>({1.0, 1.0, 1.0}));
        SetEntityMoveType(GrabTarget[client], MOVETYPE_VPHYSICS);
      }
      GrabTarget[client] = -1;
    }
    else
    {
      int target = GetClientAimTarget(client, true); // bez zbrani
	  //int target = GetClientAimTarget(client, false); se zbranema
      if(IsValidEntity(target))
      {
        char classname[32];
        GetEntityClassname(target, classname,sizeof(classname));
        if(StrEqual(classname, "player"))
        {
          GrabTarget[client] = target;
          Grab[client] = true;
          GrabNew[client] = true;
          GrabCanMove[client] = false;
          TeleportEntity(target, NULL_VECTOR, NULL_VECTOR,view_as<float>({0.0, 0.0, 0.0}));
          SetEntityMoveType(GrabTarget[client], MOVETYPE_VPHYSICS);
          SetEntityRenderColor(GrabTarget[client],0,255,0,255);
        }
        /*else
        {
          for(int wep; wep < sizeof(s_allweaponslist); wep++)
          {
            if(StrEqual(classname, s_allweaponslist[wep]))
            {
              GrabTarget[client] = target;
              Grab[client] = true;
              GrabNew[client] = true;
              GrabCanMove[client] = false;
              SetEntityMoveType(GrabTarget[client], MOVETYPE_VPHYSICS);
              break;
            }
          }
        }*/

      }
    }
  }
  return Plugin_Handled;
}
public Action Command_Pause(int client,int args)
{
  Pause = !Pause;
  if(Pause == true)
  {
    PrintToChatAll("[\x02SERVER\x01] \x02Admin pozastavil hru.");
    f_Pause = GetGameTime();
    LoopAliveClients(i)
    {
      if(IsClientAdmin(i) == false)
      {
        SetEntityMoveType(i, MOVETYPE_NONE);
      }
    }
  }
  else
  {
    //TEXT - Admin odpauzoval hru, příkazy wardena stále platí
    PrintHintTextToAll("<font size='12'> </font><br><font size='30' color='#00ff00'>Hra je obnovena</font>");
    PrintToChatAll("[\x02SERVER\x01] \x04Admin obnovil hru.");
    LoopAliveClients(i)
    {
      if(IsClientAdmin(i) == false)
      {
        int i_wep = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
        SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
        SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
        SetEntityMoveType(i, MOVETYPE_WALK);
      }
    }
  }
  return Plugin_Handled;
}
public Action Command_NoBlock(int client,int args)
{
	if(IsValidClient(client) && (IsClientWarden(client) || IsClientAdmin(client)))
	{
		Noblock = !Noblock;
		if(Noblock == true)
		{
			PrintToChatAll("[\x0bJail\x01] \x0c%s \x04zapnul \x03noblock.", IsClientWarden(client)?"Warden":"Admin");
			EnableNoBlock();
		}
		else
		{
			PrintToChatAll("[\x0bJail\x01] \x0c%s \x02vypnul \x03noblock.", IsClientWarden(client)?"Warden":"Admin");
			DisableNoBlock();
		}
	}
	else if(IsValidClient(client))
	{
		PrintToChat(client, "[SM] Nemáš přístup k tomuto příkazu!");
	}
	return Plugin_Handled;
}
public Action Command_LaserColor(int client, int args)
{
  char cookie[32];
  GetClientCookie(client, g_clientcookie, cookie,sizeof(cookie));
  Menu menu = CreateMenu(h_lastercolormenu);
  menu.SetTitle("Vyber si barvu laseru!");
  for(int i; i < sizeof(s_lasershot_list); i++)
  {
    char e_buffer[4][24];
    char e_cookie[4][24];
    ExplodeString(s_lasershot_list[i], " ", e_buffer, sizeof(e_buffer), sizeof(e_buffer[]));
    ExplodeString(cookie, " ", e_cookie, sizeof(e_cookie), sizeof(e_cookie[]));
    menu.AddItem(e_buffer[0],e_buffer[0],StrEqual(e_cookie[0],e_buffer[0])?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  }
  menu.ExitButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}

public Action Command_Drop(int client, int args)
{
  if(g_gamemodes == true)
  {
    if(b_gm_lovecky == true)
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
	return Plugin_Continue;
}
