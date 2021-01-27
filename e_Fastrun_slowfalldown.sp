#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#pragma newdecls required

ConVar cV_FallDown;
float cVf_FallDown;
ConVar cV_Gravity;
float cVf_Gravity;
ConVar cV_Speed;
float cVf_Speed;

public Plugin myinfo =
{
	name = "FastRun/Slow Falldown",
	author = "ESK0",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/id/esko"
};

public void OnPluginStart()
{
	cV_FallDown = CreateConVar("furien_falldown", "1.5", "Falldown speed");
	cVf_FallDown = GetConVarFloat(cV_FallDown);
	HookConVarChange(cV_FallDown,OnConVarChanged);
	cV_Gravity = CreateConVar("furien_gravity", "0.25", "Furiens gravity multiplier");
	cVf_Gravity = GetConVarFloat(cV_Gravity);
	HookConVarChange(cV_Gravity,OnConVarChanged);
	cV_Speed = CreateConVar("furien_speed", "1.5", "Furiens speed multiplier");
	cVf_Speed = GetConVarFloat(cV_Speed);
	HookConVarChange(cV_Speed,OnConVarChanged);
}
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
  }
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(IsValidClient(client, true))
	{
		int cFlags = GetEntityFlags(client);
		if(IsClientInAir(client, cFlags))
		{
		  float vVel[3];
		  GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
		  if(vVel[2] < -1.0)
		  {
		    vVel[2] += cVf_FallDown;
		    SetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
		    TeleportEntity(client, NULL_VECTOR,NULL_VECTOR,vVel);
		  }
		  else if(vVel[2] > 200.0)
		  {
		    vVel[2] -= 20.0;
		    SetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
		    TeleportEntity(client, NULL_VECTOR,NULL_VECTOR,vVel);
		  }
		}
	}
}
public void EventSDK_OnClientThink(int client)
{
	if(IsValidClient(client))
	{
		if(IsPlayerAlive(client))
		{
			SetEntityGravity(client, cVf_Gravity);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", cVf_Speed);
		}
	}
}
public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
  if(convar == cV_Gravity)
  {
    cVf_Gravity = GetConVarFloat(cV_Gravity);
  }
  else if(convar == cV_Speed)
  {
    cVf_Speed = GetConVarFloat(cV_Speed);
  }
  else if(convar == cV_FallDown)
  {
    cVf_FallDown = GetConVarFloat(cV_FallDown);
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
stock bool IsClientInAir(int client, int flags)
{
  return !(flags & FL_ONGROUND);
}
