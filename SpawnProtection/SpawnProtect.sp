#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>

float RoundStartTime;
bool SpawnProtection;
public Plugin myinfo =
{
	name = "[GameSites] Spawn protect",
	author = "ESK0",
	description = "Gamesites's Spawn protect",
	version = "1.0",
	url = "www.github.com/ESK0"
}
public OnPluginStart()
{
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("bomb_planted", Event_BombPlanted);

}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}
public Action Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(SpawnProtection)
	{
		PrintToChatAll("%N has been slayed for planting bomb while SpawnProtect was active", client);
		ForcePlayerSuicide(client);
	}
}
public Action SDK_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(SpawnProtection)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public OnGameFrame()
{
	if(SpawnProtection)
	{
		for(int i = 1; i<= MaxClients; i++)
		{
			if(IsValidPlayer(i, true))
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					SetEntityRenderColor(i, 0,0,255);
				}
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntityRenderColor(i, 255,0,0);
				}
			}
		}
		float time = 19.0;
		float timeleft = RoundStartTime - GetGameTime() + time;
		char centerText[256];
		if(timeleft > 0.01)
		{
			Format(centerText, sizeof(centerText),"<font size='15'>\n</font>    <font color='#0d98ba' size='25'>SpawnProtection: </font><font color='#ff2052' size='25'>%0.2f</font>", timeleft);
			Format(centerText, sizeof(centerText),"%s\n  <font color='#ffc0cb' size='12'>by ESK0</font>",centerText);
			PrintHintTextToAll(centerText);
		}
		else
		{
			Format(centerText, sizeof(centerText), "<font size='15'>\n</font>    <font color='#0d98ba' size='25'>SpawnProtection: </font><font color='#ff2052' size='25'>OFF</font>");
			Format(centerText, sizeof(centerText),"%s\n  <font color='#ffc0cb' size='12'>by ESK0</font>",centerText);
			PrintHintTextToAll(centerText);
			for(int i = 1; i<= MaxClients; i++)
			{
				if(IsValidPlayer(i, true))
				{
					SpawnProtection = false;
					SetEntityRenderColor(i,255,255,255,255);
				}
			}
		}
	}
}
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	SpawnProtection = true;
	RoundStartTime = GetGameTime();
}
stock bool IsValidPlayer(client, bool alive = false)
{
    if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
		{
        return true;
    }
    return false;
}
