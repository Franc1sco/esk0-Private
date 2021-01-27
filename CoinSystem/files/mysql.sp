public void Mysql_Init()
{
  db = SQL_Connect("esko",true, db_error, sizeof(db_error));
  if(db == null)
  {
    SQL_GetError(db, db_error, sizeof(db_error));
    SetFailState("\n\n\n[CoinSystem] Cannot connect to the DB: %s\n\n\n", db_error);
  }
  Mysql_LoadMap();
}
public void Mysql_LoadMap()
{
  MapPos.Clear();
  char map[64];
  GetCurrentMap(map, sizeof(map));
  Format(db_query, sizeof(db_query), "SELECT * FROM coins_maps WHERE mapa = '%s'", map);
  SQL_TQuery(db, MySql_OnMapLoad, db_query, 1);
}
public void MySql_OnMapLoad(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem] MySql-Query failed! Error (1): %s\n\n\n", error);
  }
  else
  {
    char sPos[512];
    while(SQL_FetchRow(query))
    {
      SQL_FetchString(query, 2, sPos, sizeof(sPos));
      MapPos.PushString(sPos);
    }
  }
  CloseHandle(query);
}
public void Mysql_Save()
{
  char map[64];
  GetCurrentMap(map, sizeof(map));
  Format(db_query, sizeof(db_query), "DELETE FROM coins_maps WHERE mapa = '%s'", map);
  SQL_TQuery(db, MySql_OnRemove, db_query, 1);
}
public void MySql_OnRemove(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem] MySql-Query failed! Error (2): %s\n\n\n", error);
  }
  else
  {
    char map[64];
    char sMap[512];
    GetCurrentMap(map, sizeof(map));
    for(int i = 0; i < MapPos.Length; i++)
    {
      MapPos.GetString(i, sMap, sizeof(sMap));
      Format(db_query, sizeof(db_query), "INSERT INTO coins_maps (mapa,pos) VALUES ('%s','%s')", map, sMap);
      SQL_TQuery(db, MySql_OnSave, db_query, 1);
    }
  }
  CloseHandle(query);
}
public void MySql_OnSave(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem] MySql-Query failed! Error (3): %s\n\n\n", error);
  }
  CloseHandle(query);
}
public void LoadClient(int client)
{
  ClientStats.Set(client, 0);
  char SteamId[64];
  GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
  Format(db_query, sizeof(db_query), "SELECT count FROM coins_stats WHERE steamid = '%s'", SteamId);
  SQL_TQuery(db, MySql_LoadClient, db_query, client);
}
public void MySql_LoadClient(Handle owner, Handle query, const char[] error, any client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem Stats] MySql-Query failed! Error (4): %s\n\n\n", error);
  }
  else
  {
    if(!SQL_FetchRow(query))
    {
      char SteamId[64];
      GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
      Format(db_query, sizeof(db_query), "INSERT INTO coins_stats (steamid,count,jmeno) VALUES ('%s','0', '%N')", SteamId, client);
      SQL_TQuery(db, MySql_OnLoadClientStats, db_query, client);
    }
    else
    {
      ClientStats.Set(client, SQL_FetchInt(query, 0));
    }
  }
  CloseHandle(query);
}
public void MySql_OnLoadClientStats(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem Stats] MySql-Query failed! Error (5): %s\n\n\n", error);
  }
  CloseHandle(query);
}
public void SaveClientStats(int client)
{
  char SteamId[64];
  GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
  Format(db_query, sizeof(db_query), "UPDATE coins_stats SET count='%i' WHERE steamid = '%s'", ClientStats.Get(client), SteamId);
  SQL_TQuery(db, MySql_SaveClientStats, db_query, 1);
}
public void MySql_SaveClientStats(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[CoinSystem Stats] MySql-Query failed! Error (6): %s\n\n\n", error);
  }
  CloseHandle(query);
}
