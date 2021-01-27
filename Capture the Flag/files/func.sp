#define LoopValidClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsValidClient(%1))
#define LoopAliveClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsValidClient(%1, true))

stock void SetCvarString(const char[] cvarName, const char[] value)
{
  Handle cvar = FindConVar(cvarName);
  if(cvar != INVALID_HANDLE)
  {
    int flags = GetConVarFlags(cvar);

    flags &= ~FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
    SetConVarString(cvar, value);

    flags |= FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
  }
}
stock void SetCvarInt(const char[] cvarName, const int value)
{
  Handle cvar = FindConVar(cvarName);
  if(cvar != INVALID_HANDLE)
  {
    int flags = GetConVarFlags(cvar);

    flags &= ~FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
    SetConVarInt(cvar, value);

    flags |= FCVAR_NOTIFY;
    SetConVarFlags(cvar, flags);
  }
}
stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}
stock int CountPlayerInTeam(int team)
{
	int count = 0;
	LoopValidClients(i)
	{
		if(GetClientTeam(i) > 1)
		{
			count++;
		}
	}
	return count;
}
stock bool IsEntityFlag(int entity)
{
	if(entity == flag_ct || entity == flag_t) return true;
	return false;
}
stock bool IsFlagCarrying(int ctf_flag)
{
	int flag = -1;
	if(ctf_flag == CTF_FLAG_T) flag = flag_t_carrier;
	else if(ctf_flag == CTF_FLAG_CT) flag = flag_ct_carrier;

	if(flag != -1) return true;
	return false;
}
stock bool IsClientFlagCarrier(int client, int flag)
{
	if(flag == CTF_FLAG_T)
	{
		if(client == flag_t_carrier) return true;
		return false;
	}
	if(flag == CTF_FLAG_CT)
	{
		if(client == flag_ct_carrier) return true;
		return false;
	}
	return false;
}
stock int GetClientFlag(int client)
{
  return (GetClientTeam(client) == CS_TEAM_CT ? CTF_FLAG_T : GetClientTeam(client) == CS_TEAM_T ? CTF_FLAG_CT : -1);
}
public void CreateParentFlag(int parent)
{
	float vecOrgs[3];
	float angOrgs[3];

	GetClientEyePosition(parent, vecOrgs);
	GetClientEyeAngles(parent, angOrgs);
	vecOrgs[2] -= 15.0;

	int flag = CreateEntityByName("prop_dynamic_override");
	if(GetClientTeam(parent) == CS_TEAM_T) DispatchKeyValue(flag, "model", FLAG_MODEL_BLUE), flag_ct_carrier = parent, flag_ct = flag;
	else if(GetClientTeam(parent) == CS_TEAM_CT) DispatchKeyValue(flag, "model", FLAG_MODEL_RED), flag_t_carrier = parent, flag_t = flag;
	SetEntProp(flag, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(flag, Prop_Data, "m_nSolidType", 6);
	SetEntProp(flag, Prop_Send, "m_CollisionGroup", 1);
	DispatchSpawn(flag);
	TeleportEntity(flag, vecOrgs, angOrgs, NULL_VECTOR);
	SDKHook(flag, SDKHook_StartTouch, EventSDK_OnStartTouch);
	SetVariantString("!activator");
	AcceptEntityInput(flag, "SetParent", parent);
	SetVariantString("defusekit");
	AcceptEntityInput(flag, "SetParentAttachment");
}
public void CreateTeamFlagAtCords(int t_flag, float cords[3])
{
	int index = CreateEntityByName("prop_dynamic_override");
	SetEntityRenderMode(index,RENDER_TRANSCOLOR);
	SetEntityRenderColor(index,255,255,255,255);
	if(t_flag == CTF_FLAG_CT)
	{
		DispatchKeyValue(index, "model", FLAG_MODEL_BLUE);
		flag_ct = index;
		flag_ct_carrier = -1;
	}
	else if(t_flag == CTF_FLAG_T)
	{
		DispatchKeyValue(index, "model", FLAG_MODEL_RED);
		flag_t = index;
		flag_t_carrier = -1;
	}
	SetEntProp(index, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(index, Prop_Data, "m_nSolidType", 6);
	SetEntProp(index, Prop_Send, "m_CollisionGroup", 1);
	DispatchSpawn(index);
	TeleportEntity(index, cords, NULL_VECTOR, NULL_VECTOR);
	SDKHook(index, SDKHook_StartTouch, EventSDK_OnStartTouch);
}
stock bool FloatEqual(float firstfloat[3], float secondfloat[3])
{
	if(firstfloat[0] == secondfloat[0] && firstfloat[1] == secondfloat[1] && firstfloat[2] == secondfloat[2])
	{
		return true;
	}
	return false;
}
stock void RemoveFlag(int index)
{
	if(index == CTF_FLAG_CT) index = flag_ct;
	else if(index == CTF_FLAG_T) index = flag_t;
	if(IsValidEntity(index) && index > 0)
	{
		AcceptEntityInput(index, "Kill");
		SDKUnhook(index, SDKHook_StartTouch, EventSDK_OnStartTouch);
		index = -1;
	}
}
stock bool GetClientGroundPosition(int iClient, float fGround[3])
{
	float fOrigin[3];
	GetClientAbsOrigin(iClient, fOrigin);

	float fAngles[3] = {90.0, 0.0, 0.0};
	TR_TraceRayFilter(fOrigin, fAngles, MASK_SOLID, RayType_Infinite, TraceRay_DontHitSelf, iClient);
	if(TR_DidHit())
	{
		TR_GetEndPosition(fGround);
		return true;
	}
	return false;
}

public bool TraceRay_DontHitSelf (int iTarget,int iMask, int iClient)
{
	return (iTarget != iClient);
}
