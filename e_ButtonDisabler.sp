#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

ArrayList HammerIds;

bool bLoaded = false;
char mapname[64];
char sFilePath[PLATFORM_MAX_PATH];

#define PLUGIN_VERSION "1.1.0"

public Plugin myinfo =
{
	name = "MapGame Disabler",
	author = "ESK0",
	description = "CS:GO MapGame Disabler",
	version = PLUGIN_VERSION,
	url = "https://github.com/ESK0"
};
public void OnPluginStart()
{
	HammerIds = new ArrayList(64);
	RegAdminCmd("sm_getid", Command_getHammerId, ADMFLAG_ROOT);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Post);
}
public void OnMapStart()
{
	bLoaded = false;
	GetCurrentMap(mapname, sizeof(mapname));
	BuildPath(Path_SM, sFilePath, sizeof(sFilePath), "esko/%s.txt",mapname);
	HookEntityOutput("func_button", "OnUseLocked", OnButtonPressed);
	LoadBannedIds();
}
public void LoadBannedIds()
{
	HammerIds.Clear();
	Handle hFile = OpenFile(sFilePath, "r");
	if(hFile)
	{
		char sBuffer[64];
		while(ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
		  HammerIds.PushString(sBuffer);
		}
		bLoaded = true;
	}
	delete hFile;
}
public void OnButtonPressed(const char[] output,int caller,int activator, float delay)
{
	int HammerID = GetEntProp(caller, Prop_Data, "m_iHammerID");
	for(int i = 0; i < HammerIds.Length; i++)
	{
		char buffer[64];
		HammerIds.GetString(i, buffer, sizeof(buffer));
		int HamId = StringToInt(buffer);
		if(HamId == HammerID)
		{
			CPrintToChat(activator, "[{lightblue}MINIGAMES{default}] Tato atrakce je zablokovaná!");
		}
	}
}
public void OnEntityCreated(int entity, const char[] classname)
{
  if(IsValidEntity(entity))
  {
    if(StrEqual(mapname, "mg_swag_multigames_cg") || StrEqual(mapname, "mg_tomgreens_allinone_betav2_cg"))
		{
      CreateTimer(1.0, Timer_DelayDisabled, EntIndexToEntRef(entity));
		}
  }
}
public void BlockButtons()
{
	int index = -1;
	while ((index = FindEntityByClassname(index, "func_button")) != -1)
	{
		int HammerID = GetEntProp(index, Prop_Data, "m_iHammerID");
		for(int i = 0; i < HammerIds.Length; i++)
		{
			char buffer[64];
			HammerIds.GetString(i, buffer, sizeof(buffer));
			int HamId = StringToInt(buffer);
			if(HamId == HammerID)
			{
				AcceptEntityInput(index, "Lock");
			}
		}
	}
}
public Action Timer_DelayDisabled(Handle timer, int ref)
{
  int entity = EntRefToEntIndex(ref);
  if(IsValidEntity(entity))
  {
    char sClassname[64];
    GetEntityClassname(entity, sClassname, sizeof(sClassname));
    if(StrEqual(sClassname, "func_button"))
    {
      int HammerID = GetEntProp(entity, Prop_Data, "m_iHammerID");
      for(int i = 0; i < HammerIds.Length; i++)
  		{
  			char buffer[64];
  			HammerIds.GetString(i, buffer, sizeof(buffer));
  			int HamId = StringToInt(buffer);
  			if(HamId == HammerID)
  			{
  				AcceptEntityInput(entity, "Lock");
  			}
  		}
    }
  }
}

public Action Command_getHammerId(int client, int args)
{
	if(IsValidClient(client))
	{
		int target = GetClientAimTarget(client, false);
		if(IsValidEntity(target))
		{
			int HammerID = GetEntProp(target, Prop_Data, "m_iHammerID");
			char buffer[64];
			GetEntityClassname(target, buffer,sizeof(buffer));
			PrintToChat(client, "HammerID: %i | Classname: %s", HammerID, buffer);
		}
	}
	return Plugin_Handled;
}
public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(bLoaded)
	{
    if(StrEqual(mapname, "mg_swag_multigames_cg") == false || StrEqual(mapname, "mg_tomgreens_allinone_betav2_cg") == false)
		{
      BlockButtons();
		}
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
