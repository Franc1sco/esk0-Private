#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
  name = "WarmUP Godmod",
  author = "ESK0",
  version = "1.0",
  description = "",
  url = "www.steamcommunity.com/id/ESK0"
};

public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
  }
}
public Action EventSDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
  if(GameRules_GetProp("m_bWarmupPeriod") == 1)
  {
    return Plugin_Handled;
  }
  return Plugin_Continue;
}

stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
