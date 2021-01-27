#include <sourcemod>
#include <regex>
#include <esko>
#include <scp>

#pragma newdecls required
#pragma semicolon 1

ArrayList g_aRWordList;
int g_iBlockedWordCount;
char db_error[512];
char db_query[512];
Handle db = null;

ArrayList arClientStats;

public Plugin myinfo =
{
  name = "ChatFilter",
  author = "ESK0",
  version = "1.0",
  description = "",
  url = "www.steamcommunity.com/id/esk0"
}

public void OnPluginStart()
{
  g_aRWordList = new ArrayList(64);
  HookEvent("round_end", Event_OnRoundEnd);
  HookEvent("player_disconnect", Event_OnPlayerDisconnect);

  arClientStats = new ArrayList(64);

  for(int i = 0; i <= MaxClients; i++)
  {
    arClientStats.Push(0);
  }

}
public void OnConfigsExecuted()
{
  LoadBlackList();
}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
  CreateNative("eChatFilter_CheckMessage", Native_CheckMessage);
  RegPluginLibrary("esko");
  return APLRes_Success;
}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    LoadClientStats(client);
  }
}
public Action Event_OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(!IsFakeClient(client))
  {
    SaveClientStats(client);
  }
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
public int Native_CheckMessage(Handle plugin, int numParams)
{
  int client = GetNativeCell(1);
  char sMessage[192];
  GetNativeString(2, sMessage, sizeof(sMessage));

  int iReplace = 0;
  char sBuffer[64];
  for(int i = 0; i < g_aRWordList.Length; i++)
  {
    g_aRWordList.GetString(i, sBuffer, sizeof(sBuffer));
    TrimString(sBuffer);
    int iLen = strlen(sBuffer)+1;
    char[] sStars = new char[iLen];
    for(int x = 0; x <= iLen; x++)
    {
      Format(sStars, iLen, "%s*", sStars);
    }
    iReplace += ReplaceString(sMessage, 192, sBuffer, sStars, false);
  }
  if(iReplace)
  {
    arClientStats.Set(client, arClientStats.Get(client)+iReplace);
  }
  SetNativeString(2, sMessage, sizeof(sMessage), true);
}
public Action OnChatMessage(int &author, Handle recipients, char[] name, char[] sMessage)
{
  if(IsValidClient(author))
  {
    StripQuotes(sMessage);
    int iReplace = 0;
    char sBuffer[192];

    iReplace += regexReplace("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", "***.***.***.***", sMessage, 192);
    iReplace += regexReplace("\\d{1,3}\\,\\d{1,3}\\,\\d{1,3}\\,\\d{1,3}", "***,****,****,****", sMessage, 192);
    iReplace += regexReplace("(?:http:\\/\\/)?(?:https:\\/\\/)?(?:www)?\\s*\\.?[\\s|\\d|A-ž]+\\s*\\.\\s*?(?:cz|sk|net|com|org|edu|tk|eu|pl|ru|co|uk|network)", "******", sMessage, 192);
    iReplace += regexReplace("^\\.[a-zA-Z\\-\\s]+{3,}\\.$", "***", sMessage, 192);

    for(int i = 0; i < g_aRWordList.Length; i++)
    {
      g_aRWordList.GetString(i, sBuffer, sizeof(sBuffer));
      TrimString(sBuffer);
      int iLen = strlen(sBuffer)+1;
      char[] sStars = new char[iLen];
      for(int x = 0; x <= iLen; x++)
      {
        Format(sStars, iLen, "%s*", sStars);
      }
      iReplace += ReplaceString(sMessage, 192, sBuffer, sStars, false);
    }
    if(iReplace)
    {
      arClientStats.Set(author, arClientStats.Get(author)+iReplace);
    }

    if (iReplace || arClientStats.Get(author))
    {
      return Plugin_Changed;
    }
  }
  return Plugin_Continue;
}
public void LoadBlackList()
{
  db = SQL_Connect("ChatFilter",true, db_error, sizeof(db_error));
  if(db == null)
  {
    SQL_GetError(db, db_error, sizeof(db_error));
    SetFailState("\n\n\n[ChatFilter] Cannot connect to the DB: %s\n\n\n", db_error);
  }
  Format(db_query, sizeof(db_query), "CREATE TABLE IF NOT EXISTS chatfilter (id INT(32) NOT NULL AUTO_INCREMENT, word VARCHAR(64) NOT NULL, PRIMARY KEY(id))");
  SQL_TQuery(db, MySql_CreateServersTable, db_query, 1);
}
public void MySql_CreateServersTable(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[ChatFilter] MySql-Query failed! Error (1): %s\n\n\n", error);
  }
  else
  {
    PrintToServer("[ChatFilter] Connected to MySQL successfuly!");
    SQL_Query(db, "SET CHARACTER SET utf8");
    LoadBlockedWords();
  }
  CloseHandle(query);
}
public void LoadBlockedWords()
{
  Format(db_query, sizeof(db_query), "SELECT * FROM chatfilter");
  SQL_TQuery(db, MySql_OnLoadBlockedWords, db_query, 1);
  g_aRWordList.Clear();
}
public void MySql_OnLoadBlockedWords(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[ChatFilter] MySql-Query failed! Error (2): %s\n\n\n", error);
  }
  else
  {
    g_iBlockedWordCount = SQL_GetRowCount(query);
    if(g_iBlockedWordCount > 0)
    {
      char sBlockedWord[64];
      while(SQL_FetchRow(query))
      {
        SQL_FetchString(query, 1, sBlockedWord, sizeof(sBlockedWord));
        g_aRWordList.PushString(sBlockedWord);
      }
      PrintToServer("[ChatFilter] ChatFilter loaded! Blocked Words: %i", g_iBlockedWordCount);
    }
  }
  CloseHandle(query);
}
public void LoadClientStats(int client)
{
  arClientStats.Set(client, 0);
  char SteamId[64];
  GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
  Format(db_query, sizeof(db_query), "SELECT count FROM chatfilter_stats WHERE steamid = '%s'", SteamId);
  SQL_TQuery(db, MySql_LoadClientStats, db_query, client);
}
public void MySql_LoadClientStats(Handle owner, Handle query, const char[] error, any client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[ChatFilter-Stats] MySql-Query failed! Error (1): %s\n\n\n", error);
  }
  else
  {
    if(!SQL_FetchRow(query))
    {
      char SteamId[64];
      GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
      Format(db_query, sizeof(db_query), "INSERT INTO chatfilter_stats (steamid,count) VALUES ('%s','0')", SteamId);
      SQL_TQuery(db, MySql_OnLoadClientStats, db_query, client);
    }
    else
    {
      arClientStats.Set(client, SQL_FetchInt(query, 0));
    }
  }
  CloseHandle(query);
}
public void MySql_OnLoadClientStats(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[ChatFilter-Stats] MySql-Query failed! Error (2): %s\n\n\n", error);
  }
  CloseHandle(query);
}
public void SaveClientStats(int client)
{
  char SteamId[64];
  GetClientAuthId(client, AuthId_SteamID64, SteamId, sizeof(SteamId));
  Format(db_query, sizeof(db_query), "UPDATE chatfilter_stats SET count='%i' WHERE steamid = '%s'",arClientStats.Get(client), SteamId);
  SQL_TQuery(db, MySql_OnSaveClientStats, db_query, client);
}
public void MySql_OnSaveClientStats(Handle owner, Handle query, const char[] error, any id)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[ChatFilter-Stats] MySql-Query failed! Error (2): %s\n\n\n", error);
  }
  CloseHandle(query);
}
public int regexReplace(char[] pattern, char[] replacement, char[] output, int size)
{
  int iReplace = 0;
  char[] sBuffer = new char[size];
  Handle regex = CompileRegex(pattern, 0, sBuffer, size);
  if (regex == INVALID_HANDLE)
  {
  return 0;
  }
  if (MatchRegex(regex, output))
  {
    int substr = 0;
    while (GetRegexSubString(regex, substr, sBuffer, size))
    {
      if(StrContains(sBuffer, "csgoucko.cz") != -1) {}
      else
      {
        iReplace += ReplaceString(output, size, sBuffer, replacement, false);
      }
      substr +=1;
    }
  }
  return iReplace;
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
