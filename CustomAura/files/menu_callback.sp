public int m_Main(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client))
  {
    if(action == MenuAction_Select)
    {
      char Item[12];
      menu.GetItem(Position, Item, sizeof(Item));
      if(StrEqual(Item, "remove"))
      {
        if(IsPlayerAlive(client))
        {
          Particle_Remove(client);
        }
        s_aClient[client] = "";
        SetClientCookie(client, h_Cookie, s_aClient[client]);
      }
      else if(StrEqual(Item, "trail"))
      {
        char s_Int[12];
        Menu menu1 = CreateMenu(m_Trail);
        menu1.SetTitle("Traily");
        for(int i; i < sizeof(s_aTrails); i++)
        {
          IntToString(i, s_Int, sizeof(s_Int));
          menu1.AddItem(s_Int, s_aTrailsNames[i]);
        }
        menu1.ExitBackButton = true;
        menu1.Display(client, MENU_TIME_FOREVER);
      }
      else if(StrEqual(Item, "aura"))
      {
        char s_Int[12];
        Menu menu2 = CreateMenu(m_Aury);
        menu2.SetTitle("Aury");
        for(int i; i < sizeof(s_aAuras); i++)
        {
          IntToString(i, s_Int, sizeof(s_Int));
          menu2.AddItem(s_Int, s_aAurasNames[i]);
        }
        menu2.ExitBackButton = true;
        menu2.Display(client, MENU_TIME_FOREVER);
      }
    }
  }
}
public int m_Trail(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client))
  {
    if(action == MenuAction_Select)
    {
      char Item[12];
      menu.GetItem(Position, Item, sizeof(Item));
      menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
      int index = StringToInt(Item);
      if(IsPlayerAlive(client))
      {
        Particle_Remove(client);
        Particle_Create(client, s_aTrails[index]);
      }
      Format(s_aClient[client], sizeof(s_aClient[]), s_aTrails[index]);
      SetClientCookie(client, h_Cookie, s_aClient[client]);
    }
    else if(action == MenuAction_Cancel)
    {
      if(Position == MenuCancel_ExitBack)
      {
        Command_Trail(client, 0);
      }
    }
  }
}
public int m_Aury(Menu menu, MenuAction action, int client, int Position)
{
  if(IsValidClient(client))
  {
    if(action == MenuAction_Select)
    {
      char Item[12];
      menu.GetItem(Position, Item, sizeof(Item));
      menu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
      int index = StringToInt(Item);
      if(IsPlayerAlive(client))
      {
        Particle_Remove(client);
        Particle_Create(client, s_aAuras[index]);
      }
      Format(s_aClient[client], sizeof(s_aClient[]), s_aAuras[index]);
      SetClientCookie(client, h_Cookie, s_aClient[client]);
    }
    else if(action == MenuAction_Cancel)
    {
      if(Position == MenuCancel_ExitBack)
      {
        Command_Trail(client, 0);
      }
    }
  }
}
