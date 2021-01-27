#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
int gNameOffset = -1;
char gName[64];

public Plugin myinfo =
{
    name = "Custom weapon name",
    author = "ESKO",
    version = "1.0",
    url = "www.steamcommunity.com/id/esk0",
    description = "",
}
public void OnPluginStart()
{
  Format(gName, sizeof(gName), "<font color='#ffa500' size='23'>PORNHUB.COM</font>");
  gNameOffset = FindSendPropInfo("CBaseCombatWeapon" ,"m_szCustomName");
}
public void OnClientPutInServer(int client)
{
  SDKHook(client, SDKHook_WeaponEquip, SDKHook_OnWeaponEquip);
}
public Action SDKHook_OnWeaponEquip(int client, int weapon)
{
  if(IsValidClient(client, true))
  {
    SetEntDataString(weapon, gNameOffset, gName, sizeof(gName), true);
  }
  return Plugin_Handled;
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
