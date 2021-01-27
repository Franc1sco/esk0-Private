public void Menu_CoinAdmin(int client)
{
  Menu menu = new Menu(m_CoinAdmin);
  menu.SetTitle("- CoinAdmin - [%i spawnu]", MapPos.Length);
  menu.AddItem("add", "Přidat spawn");
  menu.AddItem("rem", "Odstranit poslední spawn");
  menu.AddItem("remclose", "Odstranit nejbližší spawn");
  menu.AddItem("show", sAdmin?"Zobrazit spawny: Zapnuto":"Zobrazit spawny: Vypnuto");
  menu.AddItem("scramble", "Zamíchat spawny");
  menu.AddItem("tele", "Teleportovat na coinu");
  menu.AddItem("save", "Uložít spawny")
  menu.Pagination = MENU_NO_PAGINATION;
  menu.ExitButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}
public int m_CoinAdmin(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client))
  {
    if(action == MenuAction_Select)
    {
      char sItem[12];
      menu.GetItem(Position, sItem, sizeof(sItem));
      if(StrEqual(sItem, "add"))
      {
        Coin_CreateSpawn(client);
      }
      else if(StrEqual(sItem, "rem"))
      {
        MapPos.Erase(MapPos.Length-1);
      }
      else if(StrEqual(sItem, "remclose"))
      {
        Coin_RemoveClose(client);
      }
      else if(StrEqual(sItem, "show"))
      {
        Coins_Admin();
      }
      else if(StrEqual(sItem, "save"))
      {
        Mysql_Save();
      }
      else if(StrEqual(sItem, "scramble"))
      {
        for(int i = 0; i <= 1024; i++)
        {
          int r1 = GetRandomInt(0, MapPos.Length-1);
          int r2 = GetRandomInt(0, MapPos.Length-1);
          MapPos.SwapAt(r1, r2);
        }
      }
      else if(StrEqual(sItem, "tele"))
      {
        float fCoin[3];
        GetEntPropVector(g_iCoin, Prop_Send, "m_vecOrigin", fCoin);
        fCoin[2] += 90;
        TeleportEntity(client, fCoin, NULL_VECTOR, NULL_VECTOR);

      }
      Menu_CoinAdmin(client)
    }
  }
}
