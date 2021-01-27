#include <sourcemod>
#include <emitsoundany>
#include <multicolors>
#include <sdktools>
#include <sdkhooks>

#include "files/globals.sp"
#include "files/mysql.sp"
#include "files/events.sp"
#include "files/func.sp"
#include "files/menu.sp"
#include "files/commands.sp"
#include "files/sdkhooks.sp"


public Plugin myinfo =
{
  name = "Coin System",
  author = "ESK0",
  version = "2.0",
  description = "",
  url = "www.steamcommunity.com/id/esk0"
}

public void OnPluginStart()
{
  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("round_end", Event_OnRoundEnd);
  HookEvent("player_disconnect", Event_OnPlayerDisconnect);

  RegAdminCmd("sm_coinadmin", Command_CoinAdmin, ADMFLAG_ROOT);

  MapPos = new ArrayList(256);
  ClientStats = new ArrayList(64);

  for(int i = 0; i <= MaxClients; i++)
  {
    ClientStats.Push(0);
  }
}
public void OnMapStart()
{
  AddFileToDownloadsTable("models/custom_props/coin/coin.dx90.vtx");
  AddFileToDownloadsTable("models/custom_props/coin/coin.mdl");
  AddFileToDownloadsTable("models/custom_props/coin/coin.phy");
  AddFileToDownloadsTable("models/custom_props/coin/coin.vvd");
  PrecacheModel(MODEL_COIN, true);

  AddFileToDownloadsTable("sound/esko/coin/coin_collect.mp3");
  PrecacheSoundAny("esko/coin/coin_collect.mp3");

  g_sprite = PrecacheModel(MODEL_LASERBEAM, true);
  g_spriteHalo = PrecacheModel(MODEL_LASER_GLOW, true);

  sAdmin = false;

  Mysql_Init();

  GetCurrentMap(sMapName, sizeof(sMapName));
}
public void OnGameFrame()
{
  if(hAdmin)
  {
    float timeleft = g_fPauzaTime - GetGameTime() + 1.0;
    if(timeleft < 0.0)
    {
      int time = GameRules_GetProp("m_iRoundTime");
      GameRules_SetProp("m_iRoundTime", time+1, 4, 0, true);
      g_fPauzaTime = GetGameTime();
    }
  }
}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    LoadClient(client);
  }
}
public Action Timer_ShowCoins(Handle timer, any userid)
{
  if(hAdmin)
  {
    char sMap[256];
    char sMapEx[3][256];
    for(int i = 0; i < MapPos.Length; i++)
    {
      MapPos.GetString(i, sMap, sizeof(sMap));
      ExplodeString(sMap, ";", sMapEx, sizeof(sMapEx), sizeof(sMapEx[]));
      float sPos[3];
      for(int x = 0; x < 3; x++)
      {
        sPos[x] = StringToFloat(sMapEx[x]);
      }
      sPos[2] += 10.0;
      TE_SetupBeamRingPoint(sPos, 1.0, 1.1, g_sprite, g_spriteHalo, 1, 1, 1.1, 8.0, 5.0, {0,125,125,150}, 0, 0);
      TE_SendToAll();
    }
  }
  else
  {
    delete hAdmin;
  }
}
