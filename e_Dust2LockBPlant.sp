#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>

#define BARICADE_MODEL "models/props_c17/fence01a.mdl"

float g_fOrigins[4][3] =
{
  {-1664.131713,720.864929,87.031250}, //T Spawn Tunnel
  {-528.961730,1424.310913,-56.968750 }, // Middle lower tunnel
  {-1313.479980,2673.615478,181.000244}, // B okno
  {-1314.358520,2213.685058,91.715801}, // B dveře
};

float g_fAngle[4][3] =
{
  {0.000000,270.483398,0.000000},
  {0.000000,359.439697,0.000000},
  {0.000000,1.972045,0.000000},
  {0.000000,343.542480,0.000000},
};

public Plugin myinfo =
{
	name = "CasePlugin",
	author = "ESK0",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/id/esko"
};

public void OnPluginStart()
{
  HookEvent("round_start", Event_OnRoundStart);
}
public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
  if(CountPlayers() < 8)
  {
    CreateBaricades();
  }
}
stock int CountPlayers()
{
  int count = 0;
  for(int i = 1; i <= MaxClients; i++)
  {
    if(IsValidClient(i))
    {
      if(GetClientTeam(i) > CS_TEAM_SPECTATOR)
      {
        count++;
      }
    }
  }
  return count;
}
public void CreateBaricades()
{
  for(int i = 0; i < 4; i++)
  {
    int baricade = CreateEntityByName("prop_dynamic_override");
    DispatchKeyValue(baricade, "model", BARICADE_MODEL);
    DispatchSpawn(baricade);
    SetEntProp(baricade, Prop_Data, "m_nSolidType", 6);
    TeleportEntity(baricade, g_fOrigins[i], g_fAngle[i], NULL_VECTOR);
  }
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
