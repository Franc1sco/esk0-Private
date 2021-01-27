#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

bool b_FixAllowed = false;

public Plugin myinfo =
{
  name = "[CS:GO] Aim_P2000FIX",
  author = "ESK0",
  version = "1.0"
};
public void OnMapStart()
{
  char mapname[32];
  GetCurrentMap(mapname, sizeof(mapname));
  if(StrEqual(mapname, "aim_p2000") == true)
  {
    b_FixAllowed = true;
  }
  else
  {
    b_FixAllowed = false;
  }
}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_WeaponEquip, EventSDK_OnWeaponEquip);
  }
}
public Action EventSDK_OnWeaponEquip(int client, int weapon)
{
  if(b_FixAllowed == true)
  {
    if(IsValidClient(client, true))
    {
      if(IsValidEntity(weapon))
      {
        char sWeaponClassname[32];
        GetEntityClassname(weapon, sWeaponClassname, sizeof(sWeaponClassname));
        int iWeaponIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        if(iWeaponIndex == 1 || iWeaponIndex == 61)
        {
          RemovePlayerItem(client, weapon);
          SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 32);
          EquipPlayerWeapon(client, weapon);
        }
      }
    }
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
