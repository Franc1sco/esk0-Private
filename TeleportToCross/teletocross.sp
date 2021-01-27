#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define LoopClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1))
#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))

public Plugin myinfo =
{
  name = "TeleToCross teleport",
  author = "ESK0",
  version = "1.0"
}
public void OnPluginStart()
{
  RegAdminCmd("sm_tele", Command_Teleport, ADMFLAG_SLAY);
}
public Action Command_Teleport(int client, int args)
{
  if(IsValidClient(client))
  {
    float f_cLoc[3];
    float f_cAng[3];
    float f_cEndPos[3];
    GetClientEyePosition(client, f_cLoc);
    GetClientEyeAngles(client, f_cAng);
    TR_TraceRayFilter(f_cLoc, f_cAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
    TR_GetEndPosition(f_cEndPos);

    float f_floor[3];
    GetGroundPosition(f_cEndPos, f_floor);

    char arg[32];
    GetCmdArg(1, arg,sizeof(arg));
    char target_name[MAX_TARGET_LENGTH];
    int target_list[MAXPLAYERS+1];
    int target_count;
    bool tn_is_ml;
    if(GetVectorDistance(f_cEndPos, f_cLoc) < 500.0)
    {
      if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
      {
        ReplyToCommand(client, "[SM] No matching client");
        return Plugin_Handled;
      }
      for (int i = 0; i < target_count; i++)
      {
        TeleportEntity(target_list[i], f_cEndPos, NULL_VECTOR, NULL_VECTOR);
      }
    }
    else
    {
      ReplyToCommand(client, "[SM] You are looking too far away");
      return Plugin_Handled;
    }
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
public bool TraceRayTryToHit(int entity, int mask)
{
	if(entity > 0 && entity <= MaxClients)
  {
    return false;
  }
	return true;
}
stock bool GetGroundPosition(float input[3], float fGround[3])
{
	float fAngles[3] = {90.0, 0.0, 0.0};
	TR_TraceRayFilter(input, fAngles, MASK_SOLID, RayType_Infinite, TraceRayTryToHit);
	if(TR_DidHit())
	{
		TR_GetEndPosition(fGround);
		return true;
	}
	return false;
}
