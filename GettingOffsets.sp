#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
  name = "Getting Offsets",
  author = "ESK0",
  url = "www.steamcommunity.com/id/esk0"
}
public void OnPluginStart()
{
  RegConsoleCmd("sm_offset", Command_Offset);
}

public Action Command_Offset(int client, int args)
{
  int i_ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
  for (int i = 0; i < 32; i++)
  {
    PrintToConsole(client, "Offset: %i - Count: %i", i, GetEntData(client, i_ammoOffset+(i*4)));
  }
  return Plugin_Handled;
}
