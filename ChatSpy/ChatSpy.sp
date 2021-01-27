#include <sourcemod>
#include <cstrike>
#include <multicolors>
#include <clientprefs>
//#include <esko>

#define TAG "[{orange}CHATSPY{default}]"
Handle g_clientcookie;

public Plugin myinfo =
{
  name = "[CS:GO] ChatSpy",
  author = "ESK0",
  version = "1337",
  url = "www.steamcommunity.com/id/esk0"
}

public void OnPluginStart()
{
  AddCommandListener(OnPlayerSayTeam, "say_team");
  RegAdminCmd("sm_chatspy", Command_ChatSpy, ADMFLAG_GENERIC);

  g_clientcookie = RegClientCookie("esko_chatspy", "", CookieAccess_Private);
}
public Action Command_ChatSpy(int client, int args)
{
  char value[12];
  GetClientCookie(client, g_clientcookie, value, sizeof(value));
  if(StrEqual(value, ""))
  {
  	SetClientCookie(client, g_clientcookie, "1");
  	CPrintToChat(client,"%s ChatSpy ON", TAG);
  }
  else
  {
  	SetClientCookie(client, g_clientcookie, "");
  	CPrintToChat(client,"%s ChatSpy OFF", TAG);
  }
  return Plugin_Handled;
}
public Action OnPlayerSayTeam(int client, const char[] command, int args)
{
  char sMessage[192];
  GetCmdArg(1, sMessage, sizeof(sMessage));
  //eChatFilter_CheckMessage(client, sMessage);
  int sender = GetClientTeam(client);
  int reciever;
  if(IsValidClient(client))
  {
    if(sMessage[0] == '/' || sMessage[0] == '@' || sMessage[0] == 0)
		{
      return Plugin_Handled;
		}
    for(int i = 1; i <= MaxClients; i++)
    {
      if(IsValidClient(i))
      {
        if(CheckCommandAccess(i, "", ADMFLAG_GENERIC))
        {
          reciever = GetClientTeam(i);
          if(sender != reciever)
          {
            char value[12];
            GetClientCookie(i, g_clientcookie, value, sizeof(value));
            if(StrEqual(value, "1"))
            {
              CPrintToChat(i, "%s%s%s %N : %s",
  								(sender == CS_TEAM_CT) ? "{blue}" : (sender == CS_TEAM_T) ? "{orange}" : "{gray}",
  								IsPlayerAlive(client) ? "" : (sender == CS_TEAM_T) ? "*DEAD*" : (sender == CS_TEAM_CT) ? "*DEAD*" : "",
  								(sender == CS_TEAM_CT) ? "(Counter-Terorist)" : (sender == CS_TEAM_T) ? "(Terorist)" : "", client, sMessage);
            }
          }
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
