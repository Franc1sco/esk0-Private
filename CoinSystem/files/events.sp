public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
  if(CountPlayer() > 9)
  {
    if(MapPos.Length > 0)
    {
      if(StrContains(sMapName, "mg_") != -1)
      {
        int rand = GetRandomInt(1, 100);
        if(rand >= 50 && rand <= 75)
        {
          SpawnCoin(false);
        }
      }
      else
      {
        SpawnCoin(true);
      }
    }
  }
  else
  {
    CPrintToChatAll("[{Lime}Coins{Default}] Ke spawnutí mince není dostatek hráčů. Celkem 10");
  }
}
public void SpawnCoin(bool broadcast)
{
  int rand = GetRandomInt(0, MapPos.Length-1);
  char sMap[256];
  char sMapEx[3][256];
  MapPos.GetString(rand, sMap, sizeof(sMap));
  ExplodeString(sMap, ";", sMapEx, sizeof(sMapEx), sizeof(sMapEx[]));
  float sPos[3];
  for(int i = 0; i < 3; i++)
  {
    sPos[i] = StringToFloat(sMapEx[i]);
  }
  sPos[2] += 10.0;
  CreateCoin(sPos, broadcast);
}
public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
  for(int client = 1; client <= MaxClients; client++)
  {
    if(IsValidClient(client))
    {
      SaveClientStats(client);
    }
  }
}
public Action Event_OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsValidClient(client))
  {
    SaveClientStats(client);
  }
}
