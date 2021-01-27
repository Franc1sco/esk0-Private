public int m_SetWarden(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select)
  {
    char Item[11];
    menu.GetItem(Position,Item,sizeof(Item));
    LoopAliveClients(i)
    {
      if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
      {
        int userid = GetClientUserId(i);
        if(userid == StringToInt(Item))
        {
          if(IsWarden() == true)
          {
            tempwarden[client] = userid;
            Menu menu1 = CreateMenu(m_WardenOverwrite);
            char buffer[64];
            Format(buffer,sizeof(buffer), "Wardenem je momentálně %N, chceš ho nahradit?", warden);
            menu1.SetTitle(buffer);
            menu1.AddItem("1", "Ano");
            menu1.AddItem("0", "Ne");
            menu1.ExitButton = false;
            menu1.Display(client,MENU_TIME_FOREVER);
          }
          else
          {
            CreateWarden(i);
            PrintHintTextToAll("<font color='#B00930' size='22'>ADMIN nastavil Wardena</font><br><font color='#416fff' size='28'>%N</font>", i);
            PrintToChatAll("[\x0bJail\x01] \x06ADMIN nastavil Wardena \x0c%N", i);
          }
        }
      }
    }
  }
}
public int m_WardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[11];
    menu.GetItem(Position,Item,sizeof(Item));
    int choice = StringToInt(Item);
    if(choice == 1)
    {
      int newwarden = GetClientOfUserId(tempwarden[client]);
      PrintToChatAll("[\x0bJail\x01] \x02ADMIN vyhodil Wardena: \x0c%N", warden);
      PrintToChatAll("[\x0bJail\x01] \x02ADMIN nastavil funkci Wardena hráči: \x0c%N", newwarden);
      PrintHintTextToAll("<font color='#B00930' size='22'>ADMIN nastavil Wardena</font><br><font color='#416fff' size='28'>%N</font>", client);
      ChangeWardenTo(newwarden);
    }
  }
}
public int h_wardenmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {

    char Item[11];
    menu.GetItem(Position,Item,sizeof(Item));
    if(StrEqual(Item, "color"))
    {
      CreateColorMenu(client);
    }
    else if(StrEqual(Item, "gamemodes"))
    {
      CreateGameModesMenu(client);
    }
    else if(StrEqual(Item, "teamgames"))
    {
      if(g_teamgames == false)
      {
        Format(tg_weapon,sizeof(tg_weapon), "");
        Format(tg_weapon_classname,sizeof(tg_weapon_classname), "");
        Format(tg_selectedtype,sizeof(tg_selectedtype), "");
        LoopAliveClients(i)
        {
          tg_team[i] = 0;
          SetEntityRenderColor(i);
        }
        TG_ResetSettings();
        CreateTeamGamesMenu(client);
      }
      else
      {
        StopTeamGames();
      }
    }
    else if(StrEqual(Item, "others"))
    {
      CreateOtherMenu(client);
    }
    else if(StrEqual(Item, "box"))
    {
      if(b_box == true)
      {
        DisableFF();
        PrintToChatAll("[\x0bJail\x01] Box byl vypnut.");
        b_box = false;
      }
      else
      {
        if(b_box_pre == true)
        {
          b_box_pre = false;
          PrintHintTextToAll("[\x0bJail\x01] Box byl zrušen");
        }
        else
        {
          b_box_pre = true;
          f_g_box = GetGameTime();
        }
      }
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          StripWeapons(i);
          SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
        }
      }
    }
    else if(StrEqual(Item, "hg"))
    {
      if(b_hungergames == true)
      {
        DisableFF();
        PrintToChatAll("[\x0bJail\x01] HungerGames byl vypnut.");
        b_hungergames = false;
      }
      else
      {
        if(b_hungergames_pre == true)
        {
          b_hungergames_pre = false;
          PrintHintTextToAll("[\x0bJail\x01] HungerGames byl zrušen");
        }
        else
        {
          b_hungergames_pre = true;
          f_g_hungergames = GetGameTime();
        }
      }
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          StripWeapons(i);
          SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
        }
      }
    }
  }
}
public int h_colormenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position,Item,sizeof(Item));
    menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
    for(int i; i < sizeof(color_s); i++)
    {
      if(StrEqual(Item,color_s[i]))
      {
        int target = GetClientAimTarget(client, true);
        if(IsValidClient(target,true))
        {
          SetEntityRenderColor(target,color_r[i],color_g[i],color_b[i]);
          PrintToChat(target, "[\x0bTYM\x01] Jsi v týmu: %s", color_s[i]);
          PrintToChat(target, "[\x0bTYM\x01] Jsi v týmu: %s", color_s[i]);
        }
        break;
      }
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateWardenMenu(client);
    }
  }
}
public int h_teamgamestypemenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position,Item,sizeof(Item));
    tg_weapons = false;
    tg_knife = false;
    tg_vybijena = false;
    tg_granatovana = false;

    if(StrEqual(Item, "Zbraně"))
    {
      tg_weapons = true;
    }
    else if(StrEqual(Item,"Nože"))
    {
      tg_knife = true;
    }
    else if(StrEqual(Item,"Vybíjená"))
    {
      tg_vybijena = true;
    }
    else if(StrEqual(Item,"Granátovaná"))
    {
      tg_granatovana = true;
    }
    Format(tg_selectedtype,sizeof(tg_selectedtype), Item);
    CreateTeamGamesMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateTeamGamesMenu(client);
    }
  }
}
public int h_othermenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position,Item,sizeof(Item));
    if(StrEqual(Item, "stopky"))
    {
      Stopky = !Stopky;
      f_Stopky = GetGameTime();
      if(Stopky == false)
      {
        PrintHintTextToAll("<font size='22' color='#B00930'>Warden vypnul stopky<br>Čas:</font>   <font size='28' color='#00ff00'>%0.2f</font>", Stopky_timeleft);
      }
      CreateOtherMenu(client);
    }
    else if(StrEqual(Item, "noblock"))
    {
      Noblock = !Noblock;
      if(Noblock == true)
      {
        PrintToChatAll("[\x0bJail\x01] \x0cWarden \x04zapnul \x03noblock.");
        EnableNoBlock();
      }
      else
      {
        PrintToChatAll("[\x0bJail\x01] \x0cWarden \x02vypnul \x03noblock.");
        DisableNoBlock();
      }
      CreateOtherMenu(client);
    }
    else if(StrEqual(Item, "kostka"))
    {
      CreateKostkaMenu(client);
    }
    else if(StrEqual(Item, "priklady"))
    {
      CreatePrikladyMenu(client);
    }
    else if(StrEqual(Item, "otazky"))
    {
      CreateOtazkyMenu(client);
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateWardenMenu(client);
    }
  }
}
public int h_kostkamenu(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client, true) && IsClientWarden(client))
  {
    if(action == MenuAction_Select)
    {
      char Item[20];
      menu.GetItem(Position, Item,sizeof(Item));
      int i_Kostka = StringToInt(Item);
      int iRand = GetRandomInt(1, i_Kostka);
      //TEXT - Při hodu kostkou %s(Item) padlo číslo: %i(iRand)
      PrintToChatAll("[\x03Kostka\x01] Padlo číslo: \x04%i\x01 z rozsahu 1-%s.", iRand, Item);
      PrintHintTextToAll("<font size='12'> </font><br><font size='24' color='#B00930'>Padla:</font> <font size='30' color='#00ff00'>%i</font>", iRand);
      CreateKostkaMenu(client);
    }
    else if(action == MenuAction_Cancel)
    {
      if(Position == MenuCancel_ExitBack)
      {
        CreateOtherMenu(client);
      }
    }
  }
}
public int h_prikladymenu(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client, true) && IsClientWarden(client))
  {
    if(action == MenuAction_Select)
    {
      int priklad1 = GetRandomInt(0 , 70);
      int priklad2 = GetRandomInt(0 , 70);
      int priklad3 = GetRandomInt(1 , 15);
      int priklad4 = GetRandomInt(1 , 15);
      char Item[20];
      menu.GetItem(Position, Item, sizeof(Item));
      if(StrEqual(Item, "scitani"))
      {
        int total = priklad1 + priklad2;
        PrintToChatAll( "[\x03Příklad\x01] Kolik je \x0e%d \x04+ \x0e%d", priklad1, priklad2);
        PrintHintTextToAll("<font size='26' color='#B00930'>Příklad:</font><br> <font size='28' color='#00ff00'>%d + %d = ?</font>", priklad1, priklad2);
        PrintToChat(client,"[\x03Příklad\x01] Správný výsledek je: \x06%d", total);
        CreatePrikladyMenu(client);
      }
      else if(StrEqual(Item, "odecitani"))
      {
        int total = priklad1 - priklad2;
        PrintToChatAll( "[\x03Příklad\x01] Kolik je \x0e%d \x04- \x0e%d", priklad1, priklad2);
        PrintHintTextToAll("<font size='26' color='#B00930'>Příklad:</font><br> <font size='28' color='#00ff00'>%d - %d = ?</font>", priklad1, priklad2);
        PrintToChat(client,"[\x03Příklad\x01] Správný výsledek je: \x06%d", total);
        CreatePrikladyMenu(client);
      }
      else if(StrEqual(Item, "nasobeni"))
      {
        int total = priklad3 * priklad4;
        PrintToChatAll( "[\x03Příklad\x01] Kolik je \x0e%d \x04* \x0e%d", priklad3, priklad4);
        PrintHintTextToAll("<font size='26' color='#B00930'>Příklad:</font><br> <font size='28' color='#00ff00'>%d * %d = ?</font>", priklad3, priklad4);
        PrintToChat(client,"[\x03Příklad\x01] Správný výsledek je: \x06%d", total);
        CreatePrikladyMenu(client);
      }
      else if(StrEqual(Item, "deleni"))
      {
        int vysledek1 = priklad3 * priklad4;
        int total = vysledek1 / priklad3;
        PrintToChatAll( "[\x03Příklad\x01] Kolik je \x0e%d \x04/ \x0e%d", vysledek1, priklad3);
        PrintHintTextToAll("<font size='26' color='#B00930'>Příklad:</font><br> <font size='28' color='#00ff00'>%d / %d = ?</font>", vysledek1, priklad3);
        PrintToChat(client,"[\x03Příklad\x01] Správný výsledek je: \x06%d", total);
        CreatePrikladyMenu(client);
      }
      CreatePrikladyMenu(client);
    }
    else if(action == MenuAction_Cancel)
    {
      if(Position == MenuCancel_ExitBack)
      {
        CreateOtherMenu(client);
      }
    }
  }
}
public int h_otazkymenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[20];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item,"ceny"))
    {
      int random = GetRandomInt(0,sizeof(otazky_ceny)-1);
      char buffer[2][256];
      ExplodeString(otazky_ceny[random], "|",buffer,sizeof(buffer), sizeof(buffer[]));
      PrintToChatAll("[\x03Otázka\x01] \x06%s", buffer[0]);
      PrintToChat(client, "[\x03Otázka\x01] Správně je: \x08%s", buffer[1]);
    }
    else if(StrEqual(Item,"puvod"))
    {
      int random = GetRandomInt(0,sizeof(otazky_puvody)-1);
      char buffer[2][256];
      ExplodeString(otazky_puvody[random], "|",buffer,sizeof(buffer), sizeof(buffer[]));
      PrintToChatAll("[\x03Otázka\x01] \x06%s", buffer[0]);
      PrintToChat(client, "[\x03Otázka\x01] Správně je: \x08%s", buffer[1]);
    }
    else if(StrEqual(Item,"vseobecne"))
    {
      int random = GetRandomInt(0,sizeof(otazky_vseobecne)-1);
      char buffer[2][256];
      ExplodeString(otazky_vseobecne[random], "|",buffer,sizeof(buffer), sizeof(buffer[]));
      PrintToChatAll("[\x03Otázka\x01] \x06%s", buffer[0]);
      PrintToChat(client, "[\x03Otázka\x01] Správně je: \x08%s", buffer[1]);
    }
    else if(StrEqual(Item,"hlmesta"))
    {
      int random = GetRandomInt(0,sizeof(otazky_mesta)-1);
      char buffer[2][256];
      ExplodeString(otazky_mesta[random], "|",buffer,sizeof(buffer), sizeof(buffer[]));
      PrintToChatAll("[\x03Otázka\x01] \x06%s", buffer[0]);
      PrintToChat(client, "[\x03Otázka\x01] Správně je: \x08%s", buffer[1]);
    }
    CreateOtazkyMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateOtherMenu(client);
    }
  }
}
public int h_teamgamesmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[20];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item,"random"))
    {
      tg_random = !tg_random;
      CreateTeamGamesMenu(client);
    }
    else if(StrEqual(Item, "type"))
    {
      CreateTeamGamesTypeMenu(client);
    }
    else if(StrEqual(Item,"teamy"))
    {
      CreateTeamGamesTeamMenu(client);
    }
    else if(StrEqual(Item,"selectwep"))
    {
      CreateTeamGamesSWMenu(client);
    }
    else if(StrEqual(Item,"knife"))
    {
      tg_knifedmg = !tg_knifedmg;
      CreateTeamGamesMenu(client);
    }
    else if(StrEqual(Item,"dmg"))
    {
      CreateTeamGamesDmgMenu(client);
    }
    else if(StrEqual(Item,"onehit"))
    {
      tg_knifeonehit = !tg_knifeonehit;
      CreateTeamGamesMenu(client);
    }
    else if(StrEqual(Item,"leftattack"))
    {
      tg_knifeleftattack = !tg_knifeleftattack;
      CreateTeamGamesMenu(client);
    }
    else if(StrEqual(Item,"rightattack"))
    {
      tg_kniferightattack = !tg_kniferightattack;
      CreateTeamGamesMenu(client);
    }
    else if(StrEqual(Item,"hedmg"))
    {
      CreateTeamGamesHeDmgMenu(client);
    }
    else if(StrEqual(Item,"start"))
    {
      StartTeamGames();
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateWardenMenu(client);
    }
  }
}
public int h_teamgamesswmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    for(int i; i < sizeof(s_allweaponslist);i++)
    {
      if(StrEqual(Item, s_allweaponslist[i]))
      {
        Format(tg_weapon_classname,sizeof(tg_weapon_classname),Item);
        Format(tg_weapon,sizeof(tg_weapon),s_allweaponslist_names[i]);
        CreateTeamGamesMenu(client);
        break;
      }
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateTeamGamesMenu(client);
    }
  }
}
public int h_teamgamesdmgmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    tg_weapon_damage = StringToFloat(Item) + 0.000001;
    RoundToCeil(tg_weapon_damage);
    CreateTeamGamesMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateTeamGamesMenu(client);
    }
  }
}
public int h_teamgameshedmgmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    tg_he_damage = StringToFloat(Item) + 0.000001;
    CreateTeamGamesMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateTeamGamesMenu(client);
    }
  }
}
public int h_teamgamesteammenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    int team = StringToInt(Item);
    int target = GetClientAimTarget(client, true);
    if(IsValidClient(target, true) && GetClientTeam(target) == CS_TEAM_T)
    {
      tg_team[target] = team;
      SetEntityRenderColor(target, tg_color_r[team],tg_color_g[team],tg_color_b[team]);
      PrintToChat(target, "[\x0bTeamGames\x01] \x04Jsi v týmu: \x0e%s", tg_teams[team]);
      PrintToChat(target, "[\x0bTeamGames\x01] \x04Jsi v týmu: \x0e%s", tg_teams[team]);
      PrintHintText(target,"<font size'12'>Jsi v týmu<br></font><font size='30' color='#13ccec'>%s</font>", tg_teams[team]);

    }
    CreateTeamGamesTeamMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateTeamGamesMenu(client);
    }
  }
}
public int h_gamemodesmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item,"Přestřelka"))
    {
      PrintToChatAll("[\x0bMOD\x01] Přestřelka zapnuta!");
      PrintToChatAll("[\x0bMOD\x01] T se snaží najít všechny CT a eliminovat je.");
      b_gm_prestrelka = true;
      b_gm_prestrelka_played = true;
      f_gm_prestrelka = GetGameTime();
      g_gamemodes = true;
      SetCvarInt("sm_hosties_lr", 0);
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityMoveType(i, MOVETYPE_NONE);
          SetClientBlind(i, 255);
          SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
        }
        else if(GetClientTeam(i) == CS_TEAM_CT)
        {
          Menu menu1 = CreateMenu(h_gamemodeslmsweaponmenu);
          menu1.SetTitle("Zvol si zbraň");
          for(int x; x< sizeof(s_allweaponslist); x++)
          {
            menu1.AddItem(s_allweaponslist[x], s_allweaponslist_names[x]);
          }
          menu1.ExitButton = false;
          menu1.Display(i, MENU_TIME_FOREVER);
        }
      }
    }
    else if(StrEqual(Item,"Schovka"))
    {
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityRenderColor(i,255,255,255,125);
          SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
          StripWeapons(i);
        }
        else if(GetClientTeam(i) == CS_TEAM_CT)
        {
          SetEntProp(i, Prop_Send, "m_iHideHUD", GetEntProp(i, Prop_Send, "m_iHideHUD") | HIDE_RADAR);
          SetEntityMoveType(i, MOVETYPE_NONE);
          SetClientBlind(i, 255);
          SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
        }
      }
      PrintToChatAll("[\x0bMOD\x01] Schovka zapnuta!");
      PrintToChatAll("[\x0bMOD\x01] T se běží schovat, jsou trošku hůře viditělní a mají snížené požkození!");
      f_gm_schovka = GetGameTime();
      b_gm_schovka_pre = true;
      b_gm_schovka_played = true;
      g_gamemodes = true;
    }
    else if(StrEqual(Item,"Freeday"))
    {
      i_gm_freeday_count = 0;
      LoopAliveClients(i)
      {
        b_gm_freeday_rebel[i] = false;
        b_gm_freeday_wep[i] = false;
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          i_gm_freeday_count++;
        }
      }
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Volný den započal!</font>");
      PrintToChatAll("[\x0bMOD\x01] Volný Den byl zapnut!");
      PrintToChatAll("[\x0bMOD\x01] Když T zraní CT nebo vlastní primární zbraň déle jak 5 vteřin, stává se rebelem!");
      b_gm_freeday = true;
      g_gamemodes = true;
    }
    else if(StrEqual(Item,"Zombieday"))
    {
      PrintToChatAll("[\x0bMOD\x01] Zombie den byl zapnut!");
      PrintToChatAll("[\x0bMOD\x01] T mají více HP a snaží se vykuchat všechny CT!");
      b_gm_zombieday_pre = true;
      b_gm_zombieday_played = true;
      f_gm_zombieday = GetGameTime();
      SetCvarInt("sm_hosties_lr", 0);
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityMoveType(i, MOVETYPE_NONE);
          SetClientBlind(i, 255);
          StripWeapons(i);
          SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
        }
      }
      g_gamemodes = true;
    }
    else if(StrEqual(Item,"TagDay"))
    {
      LoopAliveClients(i)
      {
        b_gm_tagday_tagged[i] = false;
        i_gm_s4s_weaponi[i] = -1;
      }
      PrintHintTextToAll("<font size='12'> <br></font><font size='34' color='#5ADBF2'>Freeze Tag Day započal!</font>");
      PrintToChatAll("[\x0bMOD\x01] Honěná byla spuštena!");
      PrintToChatAll("[\x0bMOD\x01] CT se snaží pochytat všechny T a T se mohou mezi sebou osvobozovat!");
      PrintToChatAll("[\x0bMOD\x01] Chytání a osvobozování je na blízko pomocí tlačítka E(+use)!");
      ServerCommand("sm_freeze @ct");
      h_gm_tagday = CreateTimer(1.0,Timer_TagDay_Check, client,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
      b_gm_tagday = true;
      b_gm_tagday_played = true;
      g_gamemodes = true;
      GameRules_SetProp("m_iRoundTime", 660, 4, 0, true);
    }
    else if(StrEqual(Item,"LMS"))
    {
      CreateMenuLMS(client);
    }
    else if(StrEqual(Item,"Lovecky"))
    {
      PrintToChatAll("[\x0bMOD\x01] Lovecký den byl spušten!");
      PrintToChatAll("[\x0bMOD\x01] CT se snaží postřílet T a ti se je snaží vykuchat.");
      g_gamemodes = true;
      b_gm_lovecky = true;
      b_gm_lovecky_played = true;
      f_gm_lovecky = GetGameTime();
      b_gm_lovecky_pre = true;
      SetCvarInt("sm_hosties_lr", 0);
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T)
        {
          SetEntityMoveType(i, MOVETYPE_NONE);
          StripWeapons(i);
          SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
        }
        else if(GetClientTeam(i) == CS_TEAM_CT)
        {
          StripWeapons(i);
          GivePlayerItem(i, "weapon_awp");
          SetCvarInt("sv_infinite_ammo",2);
        }
      }
    }
    else if(StrEqual(Item,"race"))
    {
      if(b_gm_race == true || b_gm_race_pre == true)
      {
        Race_Disable();
      }
      else
      {
        LoopAliveClients(i)
        {
          b_Racers[i] = false;
          b_Racers_Winners[i] = false;
          i_race_winners = 0;
          i_race_stayalive = 0;
          if(GetClientTeam(i) == CS_TEAM_T)
          {
            SetEntityRenderColor(i);
          }
        }
        b_race_start = false;
        b_race_konec = false;
        CreateRaceMenu(client);
      }
    }
    else if(StrEqual(Item, "s4s"))
    {
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T && i_gm_s4s_team[i] != 0)
        {
          StripWeapons(i);
          i_gm_s4s_team[i] = 0;
          SetEntityRenderColor(i);
        }
      }
      i_gm_s4s_iteam = 0;
      Format(s_gm_s4s_weapon,sizeof(s_gm_s4s_weapon), "");
      if(b_gm_s4s == false)
      {
        CreateMenuS4S(client);
      }
      else
      {
        PrintToChatAll("[\x0bMOD\x01] Shot4Shot byl vypnut.");
        b_gm_s4s = false;
        g_gamemodes = false;
        DisableFF();
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T && i_gm_s4s_team[i] != 0)
          {
            StripWeapons(i);
          }
        }
      }
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateWardenMenu(client);
    }
  }
}
public int h_gm_race(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item,"pridathr"))
    {
      int target = GetClientAimTarget(client, true);
      if(IsValidClient(target, true) && GetClientTeam(target) == CS_TEAM_T)
      {
        float t_pos[3];
        float e_pos[3];
        GetClientAbsOrigin(target, t_pos);
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T && i != target)
          {
            GetClientAbsOrigin(i, e_pos);
            if(GetVectorDistance(t_pos,e_pos) < 100.0)
            {
              SetEntityRenderColor(target, 255,180,3);
              SetEntityRenderColor(i, 255,180,3);
              b_Racers[i] = true;
              b_Racers[target] = true;
            }
          }
        }
      }
      CreateRaceMenu(client);
    }
    else if(StrEqual(Item,"start"))
    {
      PrintToChatAll("[\x0bMOD\x01] Warden zvolil začátek závodu.");
      //GetClientAbsOrigin(client, f_race_start);
      GetClientAimTargetPos(client, f_race_start);
      //Race_Marker_Start();
      f_race_start[2] += 10.0;
      b_race_start = true;
      CreateRaceMenu(client);
    }
    else if(StrEqual(Item,"konec"))
    {
      PrintToChatAll("[\x0bMOD\x01] Warden zvolil konec závodu.");
      //GetClientAbsOrigin(client, f_race_konec);
      GetClientAimTargetPos(client, f_race_konec);
      //Race_Marker_End(f_race_konec);
      f_race_konec[2] += 10.0;
      b_race_konec = true;
      CreateRaceMenu(client);
    }
    else if(StrEqual(Item, "alive"))
    {
      int players = 0;
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true)
        {
          players++;
        }
      }
      Menu menu1 = CreateMenu(h_gm_race_alive);
      for(int i = 1; i < players; i++)
      {
        char num[3];
        IntToString(i, num, sizeof(num));
        menu1.AddItem(num, num);
      }
      menu1.SetTitle("Zvol počet hráčů kteří přežijí");
      menu1.ExitBackButton = true;
      menu1.Display(client, MENU_TIME_FOREVER);
    }
    else if(StrEqual(Item, "run"))
    {
      if(i_race_stayalive > 0)
      {
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T && b_Racers[i] == true)
          {
            SetEntityMoveType(i, MOVETYPE_NONE);
            TeleportEntity(i, f_race_start, NULL_VECTOR, NULL_VECTOR);
          }
        }
        g_gamemodes = true;
        b_gm_race = true;
        b_gm_race_pre = true;
        i_race_winners = 0;
        f_gm_race = GetGameTime();
        CreateTimer(0.1, Timer_Race_Beacon,_,TIMER_REPEAT);
        PrintToChatAll("[\x0bMOD\x01] Warden spustil závod.");
        EnableNoBlock();
      }
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateGameModesMenu(client);
    }
    Race_Reset_Marker();
  }
}
public int h_gm_race_alive(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    i_race_stayalive = StringToInt(Item);
    PrintToChatAll("[\x0bMOD\x01] Tento závod přežije \x03%i \x01hráčů", i_race_stayalive);
    CreateRaceMenu(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateRaceMenu(client);
    }
  }
}
public int h_gamemodeslmsmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item,"choose"))
    {
      gm_lms = 1;
    }
    else if(StrEqual(Item,"random"))
    {
      gm_lms = 2;
    }
    PrintToChatAll("[MOD] LMS zapnut.");
    LoopAliveClients(i)
    {
      SetEntProp(i, Prop_Send, "m_iHideHUD", GetEntProp(i, Prop_Send, "m_iHideHUD") | HIDE_RADAR);
    }
    g_gamemodes = true;
    b_gm_lms = true;
    b_gm_lms_played = true;
    b_gm_lms_pre = true;
    SetCvarInt("sm_hosties_lr", 0);
    f_gm_lms = GetGameTime();
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateGameModesMenu(client);
    }
  }
}
public int h_gamemodeslmsweaponmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select)
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    if(g_gamemodes)
      GivePlayerItem(client, Item);
  }
}
public int h_gamemodess4smenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    if(IsValidClient(client, true))
    {
      char Item[32];
      menu.GetItem(Position, Item,sizeof(Item));
      if(StrEqual(Item, "team"))
      {
        int target = GetClientAimTarget(client, true);
        if(IsValidClient(target, true) && GetClientTeam(target) == CS_TEAM_T && i_gm_s4s_team[target] == 0)
        {
          int i_color[3];
          float t_pos[3];
          float e_pos[3];
          GetClientAbsOrigin(target, t_pos);
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T && i != target  && i_gm_s4s_team[i] == 0)
            {
              GetClientAbsOrigin(i, e_pos);
              if(GetVectorDistance(t_pos,e_pos) < 46.0)
              {
                i_color[0] = GetRandomInt(1,255);
                i_color[1] = GetRandomInt(1,255);
                i_color[2] = GetRandomInt(1,255);
                i_gm_s4s_iteam++;
                i_gm_s4s_team[target] = i_gm_s4s_iteam;
                i_gm_s4s_team[i] = i_gm_s4s_iteam;
                //StripWeapons(i);
                //StripWeapons(target);
                SetEntityRenderColor(i, i_color[0], i_color[1], i_color[2], 255);
                SetEntityRenderColor(target, i_color[0], i_color[1], i_color[2], 255);
                PrintToChatAll("[\x0bS4S\x01] Hráč %N hraje proti %N", target, i);
                break;
              }
            }
          }
        }
        CreateMenuS4S(client);
      }
      else if(StrEqual(Item, "wep"))
      {
        CreateMenuS4SWep(client);
      }
      else if(StrEqual(Item, "start"))
      {
        for(int count = 1; count <= i_gm_s4s_iteam; count++)
        {
          int pl1 = -1;
          int pl2 = -1;
          LoopAliveClients(i)
          {
            if(GetClientTeam(i) == CS_TEAM_T)
            {
              if(i_gm_s4s_team[i] == count)
              {
                if(pl1 == -1)
                {
                  pl1 = i;
                  StripWeapons(pl1);
                  i_gm_s4s_weaponi[pl1] = GivePlayerItem(pl1, s_gm_s4s_weapon);
                  SetEntityHealth(pl1,100);
                }
                else
                {
                  pl2 = i;
                  StripWeapons(pl2);
                  i_gm_s4s_weaponi[pl2] = GivePlayerItem(pl2, s_gm_s4s_weapon);
                  SetEntityHealth(pl2,100);
                }
              }
            }
          }
          int firstbullet = GetRandomInt(1,2);
          if(IsValidEntity(i_gm_s4s_weaponi[pl1])) SetEntProp(i_gm_s4s_weaponi[pl1], Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
          if(IsValidEntity(i_gm_s4s_weaponi[pl2])) SetEntProp(i_gm_s4s_weaponi[pl2], Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
          if(firstbullet == 1)
          {
            SetEntData(i_gm_s4s_weaponi[pl1], g_OffsClip1, 1);
            SetEntData(i_gm_s4s_weaponi[pl2], g_OffsClip1, 0);
          }
          else if(firstbullet == 2)
          {
            SetEntData(i_gm_s4s_weaponi[pl2], g_OffsClip1, 1);
            SetEntData(i_gm_s4s_weaponi[pl1], g_OffsClip1, 0);
          }
        }
        b_gm_s4s = true;
        g_gamemodes = true;
        EnableFF();
      }
      else if(StrEqual(Item, "refresh"))
      {
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T && i_gm_s4s_team[i] > 0)
          {
            SetEntityRenderColor(i);
            i_gm_s4s_team[i] = 0;
          }
        }
      }
    }
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateGameModesMenu(client);
    }
  }
}
public int h_gamemodess4swepmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsClientWarden(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    Format(s_gm_s4s_weapon, sizeof(s_gm_s4s_weapon), Item);
    CreateMenuS4S(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateMenuS4S(client);
    }
  }
}
public int h_lastercolormenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsPlayerVIP(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    for(int i; i < sizeof(s_lasershot_list); i++)
    {
      char e_buffer[4][24];
      ExplodeString(s_lasershot_list[i], " ", e_buffer, sizeof(e_buffer), sizeof(e_buffer[]));
      if(StrEqual(e_buffer[0],Item))
      {
        SetClientCookie(client, g_clientcookie, s_lasershot_list[i]);
        break;
      }
    }
  }
}
public int h_jailadminmenu(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsValidClient(client))
  {
    char Item[32];
    menu.GetItem(Position,Item,sizeof(Item));
    if(StrEqual(Item,"mody"))
    {
      CreateJailAdminMenu_Mody(client);
    }
  }
}
public int h_jailadminmenu_mody(Menu menu, MenuAction action, int client, int Position)
{
  if(action == MenuAction_Select && IsValidClient(client))
  {
    char Item[32];
    menu.GetItem(Position, Item,sizeof(Item));
    if(StrEqual(Item, "prestrelka"))
    {
      b_gm_prestrelka_played = !b_gm_prestrelka_played;
    }
    else if(StrEqual(Item, "schovka"))
    {
      b_gm_schovka_played = !b_gm_schovka_played;
    }
    else if(StrEqual(Item, "zombieday"))
    {
      b_gm_zombieday_played = !b_gm_zombieday_played;
    }
    else if(StrEqual(Item, "freezetagday"))
    {
      b_gm_tagday_played = !b_gm_tagday_played;
    }
    else if(StrEqual(Item, "lms"))
    {
      b_gm_lms_played = !b_gm_lms_played;
    }
    else if(StrEqual(Item, "loveckyden"))
    {
      b_gm_lovecky_played = !b_gm_lovecky_played;
    }
    CreateJailAdminMenu_Mody(client);
  }
  else if(action == MenuAction_Cancel)
  {
    if(Position == MenuCancel_ExitBack)
    {
      CreateJailAdminMenu(client);
    }
  }
}
