public void CreateWardenMenu(int client)
{
  Menu menu = CreateMenu(h_wardenmenu);
  menu.SetTitle("WardenMenu");
  menu.AddItem("color","Obarvit hráče");
  menu.AddItem("gamemodes","Herní mody",(g_teamgames == true || g_gamemodes == true || b_box == true || b_hungergames == true)?(b_gm_s4s == true || b_gm_race == true?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED):(CountPlayersInTeam(CS_TEAM_T, true) < 2)?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  menu.AddItem("teamgames",g_teamgames == true?"TeamGames [Vypnout]":IsPlayerVIP(client)?"TeamGames":"TeamGames [Pouze pro VIP]",(g_gamemodes == true || b_box == true || b_hungergames == true)?ITEMDRAW_DISABLED:IsPlayerVIP(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
  menu.AddItem("box",(b_box == true || b_box_pre == true)?"Box [Vypnout]":"Box [Zapnout]",(g_teamgames == true || g_gamemodes == true || b_hungergames == true)?ITEMDRAW_DISABLED:(CountPlayersInTeam(CS_TEAM_T, true) < 2)?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  menu.AddItem("hg", (b_hungergames == true || b_hungergames_pre == true)?"Hunger Games [Vypnout]":(IsPlayerVIP(client)?(CountPlayersInTeam(CS_TEAM_T, true) < 2?"Hunger Games [Nedostatek hráčů]":"Hunger Games [Zapnout]"):"Hunger Games [Poze pro VIP]"),(g_teamgames == true || g_gamemodes == true || b_box == true)?ITEMDRAW_DISABLED:(IsPlayerVIP(client)?(CountPlayersInTeam(CS_TEAM_T, true) < 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT):ITEMDRAW_DISABLED));
  menu.AddItem("others","Ostatní");
  menu.ExitButton = true;
  menu.Display(client,MENU_TIME_FOREVER);
}
public void CreateColorMenu(int client)
{
  Menu menu = CreateMenu(h_colormenu);
  menu.SetTitle("Zvol barvu");
  for(int i; i < sizeof(color_s); i++)
  {
    menu.AddItem(color_s[i],color_s[i]);
  }
  menu.ExitBackButton = true;
  menu.Display(client,MENU_TIME_FOREVER);
}
public void CreateOtherMenu(int client)
{
  Menu menu = CreateMenu(h_othermenu);
  menu.SetTitle("Ostatní");
  menu.AddItem("stopky",Stopky?"Stopky [VYPNOUT]":"Stopky [ZAPNOUT]");
  menu.AddItem("noblock",Noblock?"NoBlock [VYPNOUT]":"NoBlock [ZAPNOUT]");
  menu.AddItem("kostka","Hod kostkou");
  menu.AddItem("priklady","Příklady");
  menu.AddItem("otazky","Otázky");
  menu.ExitBackButton = true;
  menu.Display(client,MENU_TIME_FOREVER);
}
public void CreateJailAdminMenu(int client)
{
  Menu menu = CreateMenu(h_jailadminmenu);
  menu.SetTitle("JailAdmin Menu");
  menu.AddItem("mody", "Správa modů");
  menu.ExitButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateJailAdminMenu_Mody(int client)
{
  Menu menu = CreateMenu(h_jailadminmenu_mody);
  menu.SetTitle("Správa modů");
  menu.AddItem("prestrelka",b_gm_prestrelka_played == true?"Přestřelka [POVOLIT]":"Přestřelka [ZAKAZAT]");
  menu.AddItem("schovka",b_gm_schovka_played == true?"Schovka [POVOLIT]":"Schovka [ZAKAZAT]");
  menu.AddItem("zombieday",b_gm_zombieday_played == true?"Zombie Day [POVOLIT]":"Zombie Day [ZAKAZAT]");
  menu.AddItem("freezetagday",b_gm_tagday_played == true?"Freeze Tag Day [POVOLIT]":"Freeze Tag Day [ZAKAZAT]");
  menu.AddItem("lms",b_gm_lms_played == true?"Last man standing [POVOLIT]":"Last man standing [ZAKAZAT]");
  menu.AddItem("loveckyden",b_gm_lovecky_played == true?"Lovecký den [POVOLIT]":"Lovecký den [ZAKAZAT]");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateKostkaMenu(int client)
{
  Menu menu = CreateMenu(h_kostkamenu);
  menu.SetTitle("Hod kostkou");
  menu.AddItem("6","Kostka 6 čísel");
  menu.AddItem("12","Kostka 12 čísel");
  menu.AddItem("24","Kostka 24 čísel");
  menu.AddItem("32","Kostka 32 čísel");
  menu.AddItem("64","Kostka 64 čísel");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreatePrikladyMenu(int client)
{
  Menu menu = CreateMenu(h_prikladymenu);
  menu.SetTitle("Příklady");
  menu.AddItem("scitani","Sčítání");
  menu.AddItem("odecitani","Odečítání");
  menu.AddItem("nasobeni","Násobení");
  menu.AddItem("deleni","Dělení");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateOtazkyMenu(int client)
{
  Menu menu = CreateMenu(h_otazkymenu);
  menu.SetTitle("Zvol kategorii");
  menu.AddItem("ceny","Ceny");
  menu.AddItem("puvod","Původy zbraní");
  menu.AddItem("vseobecne","Všeobecné");
  menu.AddItem("hlmesta","Hlavní města");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesMenu(int client)
{
  char buffer[64];
  Menu menu = CreateMenu(h_teamgamesmenu);
  menu.SetTitle("TeamGames Menu");
  menu.AddItem("teamy","Vytvořit teamy");
  if(StrEqual(tg_selectedtype, "")) Format(buffer,sizeof(buffer), "Typ: [Zvolte]");
  else Format(buffer,sizeof(buffer), "Typ: [%s]",tg_selectedtype);
  menu.AddItem("type", buffer);
  if(tg_weapons == true)
  {
    menu.AddItem("random",tg_random?"Náhodné zbraně [ANO]":"Náhodné zbraně [NE]");
    if(StrEqual(tg_weapon, "")) Format(buffer,sizeof(buffer), "Vybrat zbraň");
    else Format(buffer,sizeof(buffer), "Zbraň [%s]",tg_weapon);
    menu.AddItem("selectwep",buffer,tg_random?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    menu.AddItem("knife",tg_knifedmg?"Poškození nožem [ANO]":"Poškození nožem [NE]");
    Format(buffer,sizeof(buffer), "Poškození zbraní [%0.1fX]",tg_weapon_damage);
    menu.AddItem("dmg",buffer);
    menu.AddItem("start", "! START !",CountTeamGamesTeams() < 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  }
  else if(tg_knife == true)
  {
    menu.AddItem("onehit", tg_knifeonehit?"Zabití jedním hitem [ANO]":"Zabití jedním hitem [NE]");
    menu.AddItem("leftattack", tg_knifeleftattack?"Povolit slabý útok(LMB) [ANO]":"Povolit slabý útok(LMB) [NE]");
    menu.AddItem("rightattack", tg_kniferightattack?"Povolit silný útok(RMB) [ANO]":"Povolit silný útok(RMB) [NE]");
    menu.AddItem("start", "! START !",(tg_knifeleftattack == false && tg_kniferightattack == false)?ITEMDRAW_DISABLED:(CountTeamGamesTeams() < 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT));
  }
  else if(tg_granatovana == true)
  {
    Format(buffer,sizeof(buffer), "Poškození granátu [%0.1fX]",tg_he_damage);
    menu.AddItem("hedmg",buffer);
    menu.AddItem("start", "! START !",CountTeamGamesTeams() < 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  }
  else if(tg_vybijena == true)
  {
    menu.AddItem("start", "! START !",CountTeamGamesTeams() < 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesTypeMenu(int client)
{
  Menu menu = CreateMenu(h_teamgamestypemenu);
  menu.SetTitle("Zvolte typ TG");
  menu.AddItem("Zbraně", "Zbraně");
  menu.AddItem("Nože", "Nože");
  menu.AddItem("Granátovaná", "Granátovaná");
  menu.AddItem("Vybíjená", "Vybíjená");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesSWMenu(int client)
{
  Menu menu = CreateMenu(h_teamgamesswmenu);
  menu.SetTitle("Zvol zbraň");
  for(int i; i < sizeof(s_allweaponslist);i++)
  {
    menu.AddItem(s_allweaponslist[i],s_allweaponslist_names[i]);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesDmgMenu(int client)
{
  char buffer[32];
  char sfloat[10];
  Menu menu = CreateMenu(h_teamgamesdmgmenu);
  menu.SetTitle("Zvol násobek poškození");
  for(float i = 0.2; i <= 3.01; i+=0.2)
  {
    if(i == 1.0) Format(buffer,sizeof(buffer), "Normální");
    else Format(buffer,sizeof(buffer), "%0.1fX",i);
    FloatToString(i, sfloat,sizeof(sfloat));
    menu.AddItem(sfloat,buffer);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesHeDmgMenu(int client)
{
  char buffer[32];
  char sfloat[10];
  Menu menu = CreateMenu(h_teamgameshedmgmenu);
  menu.SetTitle("Zvolte násobek poškození");
  for(float i = 0.2; i <= 2.01; i+=0.2)
  {
    if(i == 1.0) Format(buffer,sizeof(buffer), "Normální");
    else Format(buffer,sizeof(buffer), "%0.1fX",i);
    FloatToString(i, sfloat,sizeof(sfloat));
    menu.AddItem(sfloat,buffer);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateTeamGamesTeamMenu(int client)
{
  char buffer[64];
  Menu menu = CreateMenu(h_teamgamesteammenu);
  Format(buffer,sizeof(buffer), "Přesuň hráče do teamu \nPočet T bez teamu: %i", TG_GetAlivePlayersInTeam(CS_TEAM_T));
  menu.SetTitle(buffer);
  for(int i = 0; i < sizeof(tg_teams);i++)
  {
    IntToString(i,buffer,sizeof(buffer));
    menu.AddItem(buffer,tg_teams[i]);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);

}
public void CreateGameModesMenu(int client)
{
  Menu menu = CreateMenu(h_gamemodesmenu);
  if(b_gm_s4s == false && b_gm_race == false)
  {
    menu.SetTitle("Herní mody");
    //menu.AddItem("Freeday", "Freeday");
    menu.AddItem("Přestřelka", b_gm_prestrelka_played == true?"Přestřelka [Hráno tuto mapu]":(b_g_disabled == true?"Přestřelka (60s uběhlo)":"Přestřelka"),b_gm_prestrelka_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT));
    menu.AddItem("Schovka", IsPlayerVIP(client)?(b_gm_schovka_played == true?"Schovka [Hráno tuto mapu]":(b_g_disabled == true?"Schovka (60s uběhlo)":"Schovka")):"Schovka [Pouze pro VIP]",IsPlayerVIP(client)?(b_gm_schovka_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT)):ITEMDRAW_DISABLED);
    menu.AddItem("Zombieday", b_gm_zombieday_played == true?"Zombie Day [Hráno tuto mapu]":(b_g_disabled == true?"Zombie Day (60s uběhlo)":"Zombie Day"),b_gm_zombieday_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT));
    menu.AddItem("TagDay", IsPlayerVIP(client)?(b_gm_tagday_played == true?"Freeze Tag Day [Hráno tuto mapu]":(b_g_disabled == true?"Freeze Tag Day (60s uběhlo)":"Freeze Tag Day")):"Freeze Tag Day [Pouze pro VIP]",IsPlayerVIP(client)?(b_gm_tagday_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT)):ITEMDRAW_DISABLED);
    menu.AddItem("LMS", IsPlayerVIP(client)?(b_gm_lms_played == true?"Last Man Standing [Hráno tuto mapu]":(b_g_disabled == true?"Last Man Standing (60s uběhlo)":"Last Man Standing")):"Last Man Standing [Pouze pro VIP]",IsPlayerVIP(client)?(b_gm_lms_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT)):ITEMDRAW_DISABLED);
    //menu.AddItem("LMS", b_gm_lms_played == true?"Last man standing [Hráno tuto mapu]":(b_g_disabled == true?"Last Man Standing (60s uběhlo)":"Last man standing"),b_gm_lms_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT));
    menu.AddItem("Lovecky", b_gm_lovecky_played == true?"Lovecký den [Hráno tuto mapu]":(b_g_disabled == true?"Lovecký den (60s uběhlo)":"Lovecký den"),b_gm_lovecky_played == true?ITEMDRAW_DISABLED:(b_g_disabled == true?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT));
    menu.AddItem("s4s", b_gm_s4s == true?"Shot 4 Shot [Vypnout]":IsPlayerVIP(client)?"Shot 4 Shot":"Shot 4 Shot [Pouze pro VIP]",IsPlayerVIP(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
    menu.AddItem("race", b_gm_race == true?"Závod [Vypnout]":IsPlayerVIP(client)?"Závod":"Závod [Pouze pro VIP]",IsPlayerVIP(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
  }
  else if(b_gm_s4s == true)
  {
    menu.AddItem("s4s", b_gm_s4s == true?"Shot 4 Shot [Vypnout]":IsPlayerVIP(client)?"Shot 4 Shot":"Shot 4 Shot [Pouze pro VIP]",IsPlayerVIP(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
  }
  else if(b_gm_race == true)
  {
    menu.AddItem("race", b_gm_race == true?"Závod [Vypnout]":IsPlayerVIP(client)?"Závod":"Závod [Pouze pro VIP]",IsPlayerVIP(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateMenuLMS(int client)
{
  Menu menu = CreateMenu(h_gamemodeslmsmenu);
  menu.SetTitle("Zvol typ");
  menu.AddItem("choose", "Výběr zbraně z menu");
  //menu.AddItem("random", "Náhodné zbraně");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateMenuS4S(int client)
{
  char buffer[64];
  char wepbuff[32];
  strcopy(wepbuff,sizeof(wepbuff), s_gm_s4s_weapon);
  Menu menu = CreateMenu(h_gamemodess4smenu);
  menu.SetTitle("Shot 4 Shot");
  menu.AddItem("team", "Přiřadit do teamu");
  ReplaceString(wepbuff, sizeof(wepbuff), "weapon_", "");
  if(StrEqual(s_gm_s4s_weapon, "")) Format(buffer,sizeof(buffer), "Zbraň: [Zvolte]");
  else Format(buffer,sizeof(buffer), "Zbraň: [%s]",wepbuff);
  menu.AddItem("wep", buffer);
  menu.AddItem("start", "Start");
  menu.AddItem("refresh", "Obnovit");
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateMenuS4SWep(int client)
{
  Menu menu = CreateMenu(h_gamemodess4swepmenu);
  menu.SetTitle("Zvol zbraň");
  for(int i; i < sizeof(s_allweaponslist);i++)
  {
    menu.AddItem(s_allweaponslist[i],s_allweaponslist_names[i]);
  }
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public void CreateRaceMenu(int client)
{
  char buffer[64];
  Menu menu = CreateMenu(h_gm_race);
  menu.SetTitle("Závody");
  menu.AddItem("pridathr", "Přidat hráče");
  menu.AddItem("start", b_race_start?"Začátek závodu [Změnit]":"Začátek závodu");
  menu.AddItem("konec", b_race_konec?"Konec závodu [Změnit]":"Konec závodu");
  Format(buffer, sizeof(buffer), "Počet přeživších [%i]", i_race_stayalive);
  menu.AddItem("alive", i_race_stayalive == 0?"Počet přeživších":buffer);
  menu.AddItem("run", "Start",(b_race_start == true && b_race_konec == true && i_race_stayalive > 0)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
  menu.ExitBackButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
