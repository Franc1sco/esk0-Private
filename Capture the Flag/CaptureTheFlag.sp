#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>

#include "files/globals.sp"
#include "files/func.sp"
#include "files/PrecacheModels.sp"

public Plugin:myinfo = {
    name = "CTF plugin",
    author = "ESK0",
    description = "CTF plugin for CS:GO",
    version = "1.0",
};

public OnPluginStart()
{
  RegConsoleCmd("sm_flag", Event_CreateFlag);
  RegConsoleCmd("sm_rflag", Event_Removeflag);
  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Post);

  LoopClients(client)
  {
    if(IsValidClient(client))
    {
      SDKHook(client, SDKHook_StartTouch, EventSDK_OnStartTouch);
    }
  }
}
public OnMapStart()
{
  GetCurrentMap(mapname, sizeof(mapname));
  LoadSettings();
  PrecacheModels();
}
public OnClientPutInServer(client)
{
  SDKHook(client, SDKHook_StartTouch, EventSDK_OnStartTouch);
}
public OnClientDisconnect(client)
{
  SDKUnhook(client, SDKHook_StartTouch, EventSDK_OnStartTouch);
}
public Action Event_CreateFlag(client, args)
{
  PrintToChatAll("%f,%f,%f",flag_ct_vecOrgs[0],flag_ct_vecOrgs[1],flag_ct_vecOrgs[2]);
  PrintToChatAll("%f,%f,%f",flag_t_vecOrgs[0],flag_t_vecOrgs[1],flag_t_vecOrgs[2]);
  PrintToChatAll(mapname);
  /*char arg[32];
  GetCmdArg(1, arg,sizeof(arg));
  int i_flag = StringToInt(arg);
  if(i_flag == CTF_FLAG_CT)   CreateTeamFlagAtCords(i_flag, flag_ct_vecOrgs);
  else if(i_flag == CTF_FLAG_T)   CreateTeamFlagAtCords(i_flag, flag_t_vecOrgs);*/
}
public Action Event_Removeflag(client, args)
{
  char arg[32];
  GetCmdArg(1, arg,sizeof(arg));
  int i_flag = StringToInt(arg);
  if(i_flag < 1 && i_flag > 2) ReplyToCommand(client,"Wrong arg");
  else RemoveFlag(i_flag);
}
public Action EventSDK_OnStartTouch(entity, other)
{
  if(entity != other)
  {
    if(IsEntityFlag(entity) && IsValidClient(other, true))
    {
      if(GetClientTeam(other) == CS_TEAM_CT && flag_t_carrier == -1 && entity == flag_t)
      {
        PrintToChatAll("Hráč: %N sebral nepřátelskou teroristickou vlajku", other);
        RemoveFlag(CTF_FLAG_T);
        CreateParentFlag(other);
      }
      else if(GetClientTeam(other) == CS_TEAM_T && flag_ct_carrier == -1 && entity == flag_ct)
      {
        PrintToChatAll("Hráč: %N sebral nepřátelskou counter-teroristickou vlajku", other);
        RemoveFlag(CTF_FLAG_CT);
        CreateParentFlag(other);
      }
      if(GetClientTeam(other) == CS_TEAM_CT && IsClientFlagCarrier(other, 2) && entity == flag_ct && flag_ct_carrier == -1)
      {
        PrintToChatAll("Hráč: %N přinesl nepřátelskou vlajku", other);
        RemoveFlag(CTF_FLAG_T);
        CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
        flag_t_carrier = -1;
      }
      else if(GetClientTeam(other) == CS_TEAM_T && IsClientFlagCarrier(other, 1) && entity == flag_t && flag_t_carrier == -1)
      {
        PrintToChatAll("Hráč: %N přinesl nepřátelskou vlajku", other);
        RemoveFlag(CTF_FLAG_CT);
        CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
        flag_ct_carrier = -1;
      }
      float position[3];
      GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
      if(GetClientTeam(other) == CS_TEAM_CT && flag_ct_carrier == -1 && entity == flag_ct && !FloatEqual(position, flag_ct_vecOrgs))
      {
        RemoveFlag(CTF_FLAG_CT);
        CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
      }
      else if(GetClientTeam(other) == CS_TEAM_T && flag_t_carrier == -1 && entity == flag_t && !FloatEqual(position, flag_t_vecOrgs))
      {
        RemoveFlag(CTF_FLAG_T);
        CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
      }
    }
  }
}
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontbroadcast)
{
  CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
  CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
}
public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontbroadcast)
{
  int victim = GetClientOfUserId(GetEventInt(event, "userid"));
  if(IsValidClient(victim))
  {
    if(GetClientTeam(victim) == CS_TEAM_T && victim == flag_ct_carrier)
    {
      float vec[3];
      GetClientGroundPosition(victim, vec);
      vec[2] += 20.0;
      RemoveFlag(CTF_FLAG_CT);
      CreateTeamFlagAtCords(CTF_FLAG_CT,vec);
    }
    else if(GetClientTeam(victim) == CS_TEAM_CT && victim == flag_t_carrier)
    {
      float vec[3];
      GetClientGroundPosition(victim, vec);
      vec[2] += 20.0;
      RemoveFlag(CTF_FLAG_T);
      CreateTeamFlagAtCords(CTF_FLAG_T,vec);
    }
  }
}
public LoadSettings()
{
  Handle hConfig = CreateKeyValues("CaptureTheFlag");
  if(!FileExists(FILE_PATH))
  {
    SetFailState("[CTF] 'addons/sourcemod/configs/CaptureTheFlag.cfg' not found!");
    return;
  }
  FileToKeyValues(hConfig, FILE_PATH);
  if(KvJumpToKey(hConfig, mapname))
  {
    char flagbuffer[3][64];
    char flag[64];
    KvGetString(hConfig, "CT_Flag", flag,sizeof(flag));
    ExplodeString(flag, "|", flagbuffer, sizeof (flagbuffer), sizeof(flagbuffer[]));
    for(int i = 0;i <= 2; i++)
    {
      flag_ct_vecOrgs[i] = StringToFloat(flagbuffer[i]);
    }
    flag_ct_vecOrgs[2] += 20;

    KvGetString(hConfig, "T_Flag", flag,sizeof(flag));
    ExplodeString(flag, "|", flagbuffer, sizeof (flagbuffer), sizeof(flagbuffer[]));
    for(int i = 0;i <= 2; i++)
    {
      flag_t_vecOrgs[i] = StringToFloat(flagbuffer[i]);
    }
    flag_t_vecOrgs[2] += 20;
  }
  else
  {
    SetFailState("Config for 'Capture The Flag' not found!");
    return;
  }
}
