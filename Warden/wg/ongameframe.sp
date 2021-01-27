public void OnGameFrame()
{
  if(b_box_pre == true)
  {
    float timeleft = f_g_box - GetGameTime() + 5.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      PrintToChatAll("[\x0bMOD\x01] Box byl zapnut.");
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Box byl zapnut!</font>");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityHealth(i, 100);
        }
      }
      EnableFF();
      b_box_pre = false;
      b_box = true;
    }
    else
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Box začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>         %0.0f</font>", timeleft);
    }
  }
  if(b_hungergames_pre == true)
  {
    float timeleft = f_g_hungergames - GetGameTime() + 5.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>HungerGames započaly!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x04HungerGames započaly!");
      PrintToChatAll("[\x0bMOD\x01] Co najdeš, to použij k přežití!");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityHealth(i, 100);
        }
      }
      EnableFF();
      b_hungergames_pre = false;
      b_hungergames = true;
    }
    else
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>HungerGames začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  if(b_no_warden == true)
  {
    float timeleft = f_no_warden - GetGameTime() + 10.0;
    if(timeleft < 8.0 && timeleft > 0.01)
    {
      //PrintHintTextToAll("Příkazy padají za %0.0f", timeleft);
      PrintHintTextToAll("<font size='22' color='#B00930'>Příkazy padají za</font><br><font size='5'> </font><font size='30' color='#00ff00'>            %0.0f</font>", timeleft);
    }
    else if(timeleft < 0.01)
    {
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#B00930'>Příkazy padly!</font>");
      b_no_warden = false;
    }
  }
  if(b_g_timer == true)
  {
    float timeleft = f_g_timer - GetGameTime() + 60.0;
    if(timeleft < 0.01)
    {
      b_g_disabled = true;
      b_g_timer = false;
    }
  }
  if(g_teamgames_start == true)
  {
    float timeleft = f_teamgames_start - GetGameTime() + 5.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      g_teamgames = true;
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Týmové hry započaly!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x07Týmové hry započaly!");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T && IsClientInTeam(i))
        {
          if(tg_weapons == true)
          {
            SetCvarInt("sv_infinite_ammo", 2);
            StripWeapons(i);
            if(tg_random == true)
            {
              GivePlayerItem(i,s_allweaponslist[GetRandomInt(0,sizeof(s_allweaponslist)-1)]);
            }
            else
            {
              GivePlayerItem(i,tg_weapon_classname);
            }
          }
          else if(tg_knife == true)
          {
            StripWeapons(i);
          }
          else if(tg_granatovana == true)
          {
            StripWeapons(i);
            GivePlayerItem(i,"weapon_hegrenade");
          }
          else if(tg_vybijena == true)
          {
            StripWeapons(i);
            int index = CreateEntityByName("weapon_flashbang");
            DispatchSpawn(index);
            EquipPlayerWeapon(i, index);
          }
          SetEntityHealth(i,100);
        }
      }
      EnableFF();
      g_teamgames_start = false;
    }
    else
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>TeamGames začnou za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  if(Pause == true)
  {
    float timeleft = f_Pause - GetGameTime() + 1.0;
    if(timeleft < 0.0)
    {
      //TEXT - Admin pozastavil hru, chvilku strpení ( nějaká barva pomocí html)
      PrintHintTextToAll("<font size='12'> </font><br><font size='30' color='#B00930'>Hra je pozastavena</font>");
      int time = GameRules_GetProp("m_iRoundTime");
      GameRules_SetProp("m_iRoundTime", time+1, 4, 0, true);
      f_Pause = GetGameTime();
    }
  }
  if(Stopky == true)
  {
    Stopky_timeleft = GetGameTime() - f_Stopky;
    if(Stopky_timeleft > 0.0)
    {
      PrintHintTextToAll("<font size='22' color='#B00930'>Warden zapnul stopky<br>Čas:</font>   <font size='28' color='#00ff00'>%0.2f</font>", Stopky_timeleft);
    }
  }
  // Last Man Standing 5ADBF2
  if(b_gm_lms == true)
  {
    float timeleft = f_gm_lms - GetGameTime() + 35.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      //TEXT - Last man standing začal
      PrintHintTextToAll("<font size='12'> <br></font><font size='32' color='#5ADBF2'>Last Man Standing začal!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x07Moře krve započalo!");
      if(gm_lms == 1)
      {
        Menu menu1 = CreateMenu(h_gamemodeslmsweaponmenu);
        menu1.SetTitle("Zvol si zbraň");
        for(int i; i< sizeof(s_allweaponslist); i++)
        {
          menu1.AddItem(s_allweaponslist[i], s_allweaponslist_names[i]);
        }
        menu1.ExitButton = false;
        LoopAliveClients(x)
        {
          StripWeapons(x);
          menu1.Display(x, MENU_TIME_FOREVER);
          GivePlayerItem(x,"weapon_glock");
        }
      }
      else if(gm_lms == 2)
      {
        LoopAliveClients(i)
        {
          StripWeapons(i);
          GivePlayerItem(i,s_allweaponslist[GetRandomInt(0,sizeof(s_allweaponslist)-1)]);
        }
      }
      SetCvarInt("mp_teammates_are_enemies",1);
      SetCvarInt("sv_infinite_ammo",2);
      //b_gm_lms_rnd = true
      b_gm_lms = false;
      b_gm_lms_pre = false;
    }
    else if(timeleft > 0.01)
    {
      //TEXT PrintToChatAll("Spustí se za %0.0f", timeleft);
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Last Man Standing</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  // Přestřelka
  if(b_gm_prestrelka == true)
  {
    float timeleft = f_gm_prestrelka - GetGameTime() + 35.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      //TEXT - Přestřelka začala
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Přestřelka začala!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x04Přestřelka začala.");
      PrintToChatAll("[\x0bMOD\x01] T se snaží najít a eliminovat všechna CT.");
      SetCvarInt("sv_infinite_ammo", 2);
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityMoveType(i, MOVETYPE_WALK);
          SetClientBlind(i, 0);
          SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
          Menu menu1 = CreateMenu(h_gamemodeslmsweaponmenu);
          menu1.SetTitle("Zvol si zbraň");
          for(int x; x < sizeof(s_allweaponslist); x++)
          {
            menu1.AddItem(s_allweaponslist[x], s_allweaponslist_names[x]);
          }
          menu1.ExitButton = false;
          menu1.Display(i, MENU_TIME_FOREVER);
        }
        StripAllGrenades(i);
      }
      b_gm_prestrelka_active = true;
      b_gm_prestrelka = false;
    }
    else if(timeleft > 0.01)
    {
      //TEXT PrintToChatAll("Spustí se za %0.0f", timeleft);
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Přestřelka začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  //Schovka
  if(b_gm_schovka_pre == true)
  {
    float timeleft = f_gm_schovka - GetGameTime() + 40.0;
    if(timeleft == 5.0)
    {
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>CT už vidí!!</font>");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_CT)
        {
          SetClientBlind(i, 0);
        }
      }
    }
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      //TEXT - schovka začala
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Schovka začala!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x04Schovka začala!");
      PrintToChatAll("[\x0bMOD\x01] \x0ePřísný zákaz razení polohy ostatních!(platí pro živé i mrtvé)");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_CT)
        {
          SetEntityMoveType(i, MOVETYPE_WALK);
          SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
        }
      }
      b_gm_schovka = true;
      b_gm_schovka_pre = false;
    }
    else if(timeleft > 0.01)
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Schovka začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  //Zombieday
  if(b_gm_lovecky_pre == true)
  {
    float timeleft = f_gm_lovecky - GetGameTime() + 25.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      b_gm_lovecky_pre = false;
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Lovecký den začal!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x04Lovecký den začal!");
      PrintToChatAll("[\x0bMOD\x01] CT mají AWP a nemohou zaměřovat.");
      PrintToChatAll("[\x0bMOD\x01] T mají jen nůž, větší ryhlost a menší gravitaci.");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityMoveType(i, MOVETYPE_WALK);
          SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
        }
      }
    }
    else
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Lovecký den začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  if(b_gm_race_pre == true)
  {
    float timeleft = f_gm_race - GetGameTime() + 5.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      PrintToChatAll("[\x0bMOD\x01] \x04Závod byl odstartován!");
      PrintHintTextToAll("<font size='12'> <br></font><font size='30' color='#5ADBF2'>Závod byl odstartován!</font>");
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true)
        {
          SetEntityMoveType(i, MOVETYPE_WALK);
        }
      }
      b_gm_race_pre = false;
    }
    else
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Závod bude odstartován za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
  if(b_gm_zombieday_pre == true)
  {
    float timeleft = f_gm_zombieday - GetGameTime() + 35.0;
    if(timeleft == 4.0) EmitSoundToAllAny("esko/warden/teamgames/3.mp3");
    if(timeleft == 3.0) EmitSoundToAllAny("esko/warden/teamgames/2.mp3");
    if(timeleft == 2.0) EmitSoundToAllAny("esko/warden/teamgames/1.mp3");
    if(timeleft < 1.0)
    {
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#31F095'>Zombie day započal!</font>");
      PrintToChatAll("[\x0bMOD\x01] \x04Zombie day začal!");
      PrintToChatAll("[\x0bMOD\x01] T mají více HP a snaží se vykuchat všechna CT, která se brání!");
      b_gm_zombieday_pre = false;
      b_gm_zombieday = true;
      //SetCvarInt("sv_infinite_ammo", 2);
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_CT)
        {
          //StripWeapons(i);
          StripAllGrenades(i);
        }
        else if(GetClientTeam(i) == CS_TEAM_T)
        {
          //SetEntityModel(i, "models/player/custom_player/legacy/zombie/zombie_v3.mdl");
          SetEntityHealth(i, 1700);
          StripWeapons(i);
          SetClientBlind(i, 0);
          //SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
          SetEntityMoveType(i, MOVETYPE_WALK);
          SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
        }
      }
    }
    else if(timeleft > 1.0)
    {
      PrintHintTextToAll("<font size='22' color='#5ADBF2'>Zombie day začne za</font><br><font size='5'> </font><br><font size='30' color='#E56161'>            %0.0f</font>", timeleft);
    }
  }
}
