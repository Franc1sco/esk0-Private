#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#pragma newdecls required

#include "files/globals.sp"
#include "files/func.sp"
#include "files/sdkhooks.sp"
#include "files/precachemodels.sp"
#include "files/eventhooks.sp"
#include "files/commands_callbacks.sp"

public Plugin myinfo =
{
    name = "CS:GO Capture The Flag",
    author = "ESK0",
    description = "Capture the Flag mod",
    version = "1.0",
    url = "www.github.com/ESK0"
};
public void OnPluginStart()
{
  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("player_death", Event_OnPlayerDeath);
  HookEvent("player_connect_full", Event_OnPlayerConnectFull, EventHookMode_Pre);

  AddCommandListener(Command_LAW, "+lookatweapon");
}
public void OnMapStart()
{
  GetCurrentMap(mapname, sizeof(mapname));
  LoadSettings();
  PrecacheModels();
  SetCvarString("mp_teamname_1", "USA");
  SetCvarString("mp_teamname_2", "SSSR");

  SetCvarInt("mp_ignore_round_win_conditions", 1);
}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
  }
}
public void LoadSettings()
{
  KeyValues hConfig = new KeyValues("CaptureTheFlag");
  if(!FileExists(FILE_PATH))
  {
    SetFailState("[Capture The Flag] '%s' not found!", FILE_PATH);
    return;
  }
  hConfig.ImportFromFile(FILE_PATH);
  if(hConfig.JumpToKey(mapname))
  {
    char flagbuffer[3][64];
    char flag[64];
    hConfig.GetString("CT_Flag", flag, sizeof(flag));
    ExplodeString(flag, "|", flagbuffer, sizeof (flagbuffer), sizeof(flagbuffer[]));
    for(int i = 0;i <= 2; i++)
    {
      flag_ct_vecOrgs[i] = StringToFloat(flagbuffer[i]);
    }
    flag_ct_vecOrgs[2] += 20;

    hConfig.GetString("T_Flag", flag, sizeof(flag));
    ExplodeString(flag, "|", flagbuffer, sizeof (flagbuffer), sizeof(flagbuffer[]));
    for(int i = 0;i <= 2; i++)
    {
      flag_t_vecOrgs[i] = StringToFloat(flagbuffer[i]);
    }
    flag_t_vecOrgs[2] += 20;
  }
  else
  {
    SetFailState("Config for 'Capture The Flag' not found!");
    return;
  }
  delete hConfig;
}
