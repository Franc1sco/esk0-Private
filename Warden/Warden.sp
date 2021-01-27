#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <emitsoundany>
#include <clientprefs>
#include <overwarden>

#pragma newdecls required

#include "wg/globals.sp"
#include "wg/otazky.sp"
#include "wg/clients.sp"
#include "wg/command_callbacks.sp"
#include "wg/func.sp"
#include "wg/eventhooks.sp"
#include "wg/ongameframe.sp"
#include "wg/timers.sp"
#include "wg/menu_callbacks.sp"
#include "wg/menus.sp"
#include "wg/onplayerruncmd.sp"
#include "wg/sdkhooks.sp"
#include "wg/natives.sp"
#include "wg/precaches.sp"
#include "wg/marker.sp"


public Plugin myinfo =
{
  name = "Warden",
  author = "ESK0, Nereziel",
  version = "www.csgoucko.cz",
  description = "Main JailBreakPlugin",
  url = "http://csgoucko.cz/"
}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("OW_IsClientWarden", Native_IsClientWarden);
	RegPluginLibrary("overwarden");
	return APLRes_Success;
}
public void OnPluginStart()
{
  //Server Check
  int ips[4];
  char serverip[128];
  int ip = GetConVarInt(FindConVar("hostip"));
  int port = GetConVarInt(FindConVar("hostport"));
  ips[0] = (ip >> 24) & 0x000000FF;
  ips[1] = (ip >> 16) & 0x000000FF;
  ips[2] = (ip >> 8) & 0x000000FF;
  ips[3] = ip & 0x000000FF;
  Format(serverip, sizeof(serverip), "%d.%d.%d.%d:%d", ips[0], ips[1], ips[2], ips[3],port);
  if(StrEqual(serverip, "185.91.116.38:27031")){}
  else SetFailState("CSGOucko.cz Copyright. Disabling plugin");

  /// PLAYER COMMANDS
  RegConsoleCmd("sm_w", Command_Warden);
  RegConsoleCmd("sm_warden", Command_Warden);
  RegConsoleCmd("sm_uw", Command_UnWarden);
  RegConsoleCmd("sm_unwarden", Command_UnWarden);
  RegConsoleCmd("sm_nb", Command_NoBlock);
  RegConsoleCmd("sm_noblock", Command_NoBlock);
  AddCommandListener(Command_LookAtWeapon, "+lookatweapon");

  RegConsoleCmd("drop", Command_Drop);

  /// ADMIN COMMANDS
  RegAdminCmd("sm_sw", Command_SetWarden, ADMFLAG_GENERIC);
  RegAdminCmd("sm_rw", Command_RemoveWarden, ADMFLAG_GENERIC);
  RegAdminCmd("sm_pauza", Command_Pause, ADMFLAG_GENERIC);
  RegAdminCmd("sm_ja", Command_JailAdmin, ADMFLAG_GENERIC);
  RegAdminCmd("sm_grab", Command_Grab, ADMFLAG_BAN);
  RegAdminCmd("sm_lm", Command_LaserColor, ADMFLAG_RESERVATION);

  /// HOOKS
  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("round_end", Event_OnRoundEnd);
  HookEvent("player_spawn", Event_OnPlayerSpawn);
  HookEvent("player_death", Event_OnPlayerDeath);
  HookEvent("player_hurt", Event_OnPlayerHurt);
  HookEvent("weapon_fire", Event_OnWeaponFire);
  HookEvent("bullet_impact", Event_OnBulletImpact);

  NoBlockOffSet = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
  g_offsNextPrimaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextPrimaryAttack");
  g_offsNextSecondaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
  g_OffsClip1 = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
  g_UserMsgFade = GetUserMessageId("Fade");

  g_clientcookie = RegClientCookie("OW_LaserShot", "", CookieAccess_Private);

  LoopClients(i)
  {
    if(IsValidClient(i))
    {
      SDKHook(i, SDKHook_WeaponCanUse, EventSDK_OnWeaponCanUse);
      SDKHook(i, SDKHook_WeaponDrop, EventSDK_OnWeaponDrop);
      SDKHook(i, SDKHook_WeaponSwitch, EventSDK_OnWeaponSwitch);
      SDKHook(i, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
      SDKHook(i, SDKHook_PreThink, EventSDK_OnClientThink);
    }
  }

}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_WeaponCanUse, EventSDK_OnWeaponCanUse);
    SDKHook(client, SDKHook_WeaponDrop, EventSDK_OnWeaponDrop);
    SDKHook(client, SDKHook_WeaponSwitch, EventSDK_OnWeaponSwitch);
    SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
  }
}
public void OnClientDisconnect(int client)
{
  if(IsClientWarden(client))
  {
    PrintToChatAll("%N byl warden a odpojil se",client);
    b_no_warden = true;
    f_no_warden = GetGameTime();
    RemoveWarden(client);
    if(g_teamgames == true)
    {
      StopTeamGames();
    }
    if(g_gamemodes == true)
    {
      if(b_gm_s4s == true)
      {
        PrintToChatAll("Shot 4 Shot vypnut");
        b_gm_s4s = false;
        g_gamemodes = false;
        DisableFF();
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T)
          {
            StripWeapons(i);
          }
        }
      }
      if(b_gm_race == true)
      {
        Race_Disable();
      }
    }
  }
  if(g_gamemodes == true)
  {
    //PrintToChatAll("gamemodes je %i",g_gamemodes);
    if(b_gm_freeday == true)
    {
      if(CheckFreeDay(true) && FD_CountPlayer() > 0)
      {
        PrintToChatAll("[\x0bMOD\x01] \x06************************");
        PrintToChatAll("[\x0bMOD\x01] \x04*Volný den lze ukončit!*");
        PrintToChatAll("[\x0bMOD\x01] \x06************************");
      }
    }
    else if(b_gm_s4s == true)
    {
      LoopAliveClients(i)
      {
        if(GetClientTeam(i) == CS_TEAM_T && i != client)
        {
          if(i_gm_s4s_team[client] == i_gm_s4s_team[i])
          {
            i_gm_s4s_team[i] = 0;
            StripWeapons(i);
            //SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, CS_SLOT_KNIFE));
            SetEntityRenderColor(i);
            break;
          }
        }
      }
      StripWeapons(client);
      i_gm_s4s_team[client] = 0;
      S4S_Check();
    }
  }
  if(b_hungergames == true)
  {
    if(GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
    {
      if(CountPlayersInTeam(CS_TEAM_T, true, 1) == 1)
      {
        DisableFF();
        b_hungergames = false;
        PrintToChatAll("HungerGames skončil. Predposledni hrac se odpojil.");
        LoopAliveClients(i)
        {
          if(GetClientTeam(i) == CS_TEAM_T)
          {
            StripWeapons(i);
          }
        }
      }
    }
  }
  if(b_box == true)
  {
    if(GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
    {
      if(CountPlayersInTeam(CS_TEAM_T, true, 1) == 1)
      {
        DisableFF();
        b_box = false;
        PrintToChatAll("Box skončil. Predposledni hrac se odpojil.");
      }
    }
  }
  if(b_gm_schovka == true)
  {
    if(GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
    {
      if(CountPlayersInTeam(CS_TEAM_T, true, 1) == 1)
      {
        g_gamemodes = false;
        b_gm_schovka = false;
        PrintToChatAll("Schovka skončila. Predposledni hrac se odpojil.");
      }
    }
  }
}
public void OnMapStart()
{
  g_sprite = PrecacheModel(MODEL_LASERBEAM, true);
  g_spriteHalo = PrecacheModel(MODEL_LASER_GLOW, true);
  b_gm_prestrelka_played = false;
  b_gm_schovka_played = false;
  b_gm_zombieday_played = false;
  b_gm_tagday_played = false;
  b_gm_lms_played = false;
  b_gm_lovecky_played = false;
  SoundPrecache();
  //ModelPrecache();

  CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public void OnMapEnd()
{
  ClearTimer(WardenColorFix);
  ClearTimer(WardenVIPColorFix);
  ClearTimer(h_gm_tagday);
}
public void OnEntityCreated(int entity, const char[] classname)
{
  if(StrEqual(classname, "flashbang_projectile") && g_teamgames == true && tg_vybijena == true)
  {
    SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
  }
  else if(StrEqual(classname, "hegrenade_projectile") && g_teamgames == true && tg_granatovana == true )
  {
    SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawned);
  }
}
public void OnEntitySpawned(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T && IsClientInTeam(client))
	{
    if(g_teamgames == true)
    {
      if(tg_vybijena == true)
      {
        CreateTimer(0.1, Timer_TG_Vybijena_RemoveThinkTick, entity, TIMER_FLAG_NO_MAPCHANGE);
      }
      else if(tg_granatovana == true)
      {
        CreateTimer(0.01, Timer_TG_Granatovana_Damage, entity, TIMER_FLAG_NO_MAPCHANGE);
      }
    }
	}
}
