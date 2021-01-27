#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#include "files/globals.sp"
#include "files/misc.sp"
#include "files/data.sp"

#include "files/menu_callback.sp"

public Plugin myinfo =
{
  name = "Custom Auras",
  author = "ESK0",
  version = "1.0",
  description = "Custom auras/trails",
  url = "www.github.com/ESK0"
};

public void OnPluginStart()
{
  RegConsoleCmd("sm_trails", Command_Trail);
  RegConsoleCmd("sm_rtrails", Command_RemoveTrail);

  HookEvent("player_death", Event_OnPlayerDeath);
  HookEvent("player_spawn", Event_OnPlayerSpawn);

  h_Cookie = RegClientCookie("Nomis_Aura_Cookie", "", CookieAccess_Private);
}
public void OnMapStart()
{
  PrecacheGeneric("materials/nomis/nomis_auras.pcf", true);
  PrecacheGeneric("materials/nomis/nomis_auras1.pcf", true);

  AddFileToDownloadsTable("materials/nomis/nomis_auras.pcf");
  AddFileToDownloadsTable("materials/nomis/nomis_auras1.pcf");

  AddFileToDownloadsTable("materials/nomis/ballx.vmt");
  AddFileToDownloadsTable("materials/nomis/ballx.vtf");
  AddFileToDownloadsTable("materials/nomis/es.vmt");
  AddFileToDownloadsTable("materials/nomis/es.vtf");
  AddFileToDownloadsTable("materials/nomis/gl.vmt");
  AddFileToDownloadsTable("materials/nomis/gl.vtf");
  AddFileToDownloadsTable("materials/nomis/fire.vmt");
  AddFileToDownloadsTable("materials/nomis/fire.vtf");

  AddFileToDownloadsTable("materials/nomis/jack_o_lantern.vmt");
  AddFileToDownloadsTable("materials/nomis/jack_o_lantern.vtf");
  AddFileToDownloadsTable("materials/nomis/glowdrip_add.vmt");
  AddFileToDownloadsTable("materials/nomis/glowdrip.vtf");
  AddFileToDownloadsTable("materials/nomis/sc_softglow.vmt");
  AddFileToDownloadsTable("materials/nomis/softglow.vtf");


  PrecacheEffect("ParticleEffect");
  PrecacheAuras();
}
public void OnClientConnected(int client)
{
  if(IsValidClient(client))
  {
    i_cParticle[client] = -1;
    GetClientCookie(client, h_Cookie, s_aClient[client], sizeof(s_aClient[]));
  }
}
public void OnClientDisconnect(int client)
{
  if(IsValidClient(client))
  {
    Particle_Remove(client);
  }
}
public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsValidClient(client))
  {
    Particle_Remove(client);
  }
}
public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsValidClient(client, true))
  {
    if(strlen(s_aClient[client]) > 0)
    {
      CreateTimer(0.3, Timer_Add, client, TIMER_FLAG_NO_MAPCHANGE);
    }
  }
}
public Action Timer_Add(Handle timer, any client)
{
  Particle_Create(client, s_aClient[client]);
}
public Action Command_Trail(int client, int args)
{
  if(IsValidClient(client))
  {
    Menu menu = CreateMenu(m_Main);
    menu.SetTitle("Trail/Aura Menu");
    menu.AddItem("remove", "Odstranit trail/auru", strlen(s_aClient[client]) < 1 ? ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    menu.AddItem("trail", "Traily");
    menu.AddItem("aura", "Aury");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
  return Plugin_Handled;
}
public Action Command_RemoveTrail(int client, int args)
{
  if(IsValidClient(client))
  {
    Particle_Remove(client);
    s_aClient[client] = "";
    SetClientCookie(client, h_Cookie, "");
  }
  return Plugin_Handled;
}
