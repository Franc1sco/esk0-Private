#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define SHOT_SOUND "weapons/aug/aug-1.wav"
#define LoopIngamePlayers(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientInGame(%1) && !IsFakeClient(%1))

float g_fAim[MAXPLAYERS + 1] =  { 0.0, ... };

bool g_bCanShoot[MAXPLAYERS + 1] =  { true, ... };
bool g_bAim[MAXPLAYERS + 1] =  { true, ... };
bool g_bBring[MAXPLAYERS + 1] =  { false, ... };

int g_iSentryGun[MAXPLAYERS + 1] =  { -1, ... };
int g_BeamSprite = -1;
int g_HaloSprite = -1;

public Plugin myinfo =
{
	name = "Sentry",
	author = "ESK0",
	description = "",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_sentry", Command_CreateSentryGun);

	HookEvent("round_start", Event_RoundStart);
}

public void OnMapStart()
{
	PrecacheSound(SHOT_SOUND);
	PrecacheSound("player/damage1.wav");
	PrecacheSound("player/damage2.wav");
	PrecacheSound("player/damage3.wav");
	g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	LoopIngamePlayers(i)
	{
		g_iSentryGun[i]=-1;
		g_bCanShoot[i]=true;
		g_bBring[i]=false;
	}
	return Plugin_Continue;
}

public Action Command_CreateSentryGun(int client, int args)
{
	/* if(g_iSentryGun[client] != -1)
	{
		PrintToChat(client, "You have a sentry gun!");
		return Plugin_Handled;
	} */

	int ent = CreateEntityByName("prop_physics_override");
	if(ent != -1)
	{
		PrecacheModel("models/player/ctm_gsg9.mdl");
		SetEntityModel(ent, "models/player/ctm_gsg9.mdl");
		DispatchSpawn(ent);

		SetEntPropFloat(ent, Prop_Send, "m_flCycle", 0.1);

		float pos[3], angle[3], vecDir[3];

		GetClientEyeAngles(client, angle);
		GetAngleVectors(angle, vecDir, NULL_VECTOR, NULL_VECTOR);
		GetClientEyePosition(client, pos);

		pos[0] += vecDir[0]*100.0;
		pos[1] += vecDir[1]*100.0;
		pos[2] -= 60.0;
		angle[0] = 0.0;
		TeleportEntity(ent, pos, angle, NULL_VECTOR);
		g_iSentryGun[client] = ent;
	}
	else
		PrintToChat(client, "Invalid enttiy:(");
	return Plugin_Continue;
}

public void OnGameFrame()
{
	LoopIngamePlayers(i)
		if(g_iSentryGun[i] != -1)
			TickSentry(i);
}

void TickSentry(int client)
{
	float SentryPos[3];

	GetEntPropVector(g_iSentryGun[client], Prop_Send, "m_vecOrigin", SentryPos);
	int iTeam = GetClientTeam(client);
	LoopIngamePlayers(i)
	{
		if(IsPlayerAlive(i))
		{
			if (GetClientTeam(i) != iTeam)
			{
				float EnemyPos[3];
				GetClientEyePosition(i, EnemyPos);
				float m_vecMins[3];
				float m_vecMaxs[3];
				GetEntPropVector(g_iSentryGun[client], Prop_Send, "m_vecMins", m_vecMins);
				GetEntPropVector(g_iSentryGun[client], Prop_Send, "m_vecMaxs", m_vecMaxs);

				TR_TraceHullFilter(SentryPos, EnemyPos, m_vecMins, m_vecMaxs, MASK_SOLID, DontHitOwnerOrNade, client);
				if(TR_GetEntityIndex() == i)
				{
					SentryTickFollow(client, i);
					return;
				}
			}
		}
	}
	SentryTickIdle(client);
}

void SentryTickIdle(int client)
{
	if(g_fAim[client] <= 0.1)
		g_bAim[client]=true;
	if(g_fAim[client] >= 0.9)
		g_bAim[client]=false;

	if(g_bAim[client])
		g_fAim[client]=FloatAdd(g_fAim[client], 0.01);
	else
		g_fAim[client]=FloatSub(g_fAim[client], 0.01);

	SetEntPropFloat(g_iSentryGun[client], Prop_Send, "m_flPoseParameter", g_fAim[client], 0);
	SetEntPropFloat(g_iSentryGun[client], Prop_Send, "m_flPoseParameter", 0.5, 1);
}

void SentryTickFollow(int owner, int player)
{
	float SentryPos[3], EnemyPos[3], EnemyAngle[3], TuretAngle[3], vecDir[3];

	GetEntPropVector(g_iSentryGun[owner], Prop_Send, "m_angRotation", TuretAngle);
	GetEntPropVector(g_iSentryGun[owner], Prop_Send, "m_vecOrigin", SentryPos);
	GetClientAbsOrigin(player, EnemyPos);

	MakeVectorFromPoints(EnemyPos, SentryPos, vecDir);
	GetVectorAngles(EnemyPos, EnemyAngle);
	GetVectorAngles(vecDir, vecDir);
	vecDir[2]=0.0;

	TuretAngle[1]+=180.0;

	float m_iDegreesY = 0.0;
	float m_iDegreesX= (((vecDir[1]-TuretAngle[1])+30.0)/60.0);

	if(m_iDegreesX < 0.0 || m_iDegreesX > 1.0)
	{
		SentryTickIdle(owner);
		return;
	}

	g_fAim[owner] = m_iDegreesX;

	SetEntPropFloat(g_iSentryGun[owner], Prop_Send, "m_flPoseParameter", m_iDegreesX, 0);
	SetEntPropFloat(g_iSentryGun[owner], Prop_Send, "m_flPoseParameter", m_iDegreesY, 1);

	if(g_bCanShoot[owner])
	{
		SentryPos[2]+=50.0;
		EnemyPos[2]=FloatAdd(EnemyPos[2], GetRandomFloat(10.0, 40.0));
		EnemyPos[0]=FloatAdd(EnemyPos[0], GetRandomFloat(-5.0, 5.0));
		EnemyPos[1]=FloatAdd(EnemyPos[1], GetRandomFloat(-5.0, 5.0));
		TE_SetupBeamPoints(SentryPos, EnemyPos, g_BeamSprite, g_HaloSprite, 0, 30, GetRandomFloat(0.1, 0.3), 1.0, 1.0, 0, 1.0, {255,250,0, 100}, 0);
		TE_SendToAll();
		int hp = GetClientHealth(player)-15;
		if(hp <= 0.0)
			ForcePlayerSuicide(player);
		else
		{
			SetEntityHealth(player, hp);
			char szFile[128];
			Format(szFile, sizeof(szFile), "player/damage%d.wav", GetRandomInt(1, 3));
			EmitSoundToClient(player, szFile);
			EmitAmbientSound(SHOT_SOUND, SentryPos);
		}
		g_bCanShoot[owner]=false;
		CreateTimer(0.1, SentrySetState, owner);
	}
}

public Action SentrySetState(Handle timer, any data)
{
	g_bCanShoot[data]=true;
}

public bool DontHitOwnerOrNade(int entity, int contentsMask, any data)
{
	if(entity > 0 && entity < 65 && IsClientInGame(entity))
		return true;
	return false;
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon)
{
	if(g_bBring[client] && IsPlayerAlive(client))
	{
		if(buttons & IN_USE)
			g_bBring[client]=false;
		else
		{
			float pos[3], angle[3], vecDir[3];

			GetClientEyeAngles(client, angle);
			GetAngleVectors(angle, vecDir, NULL_VECTOR, NULL_VECTOR);
			GetClientEyePosition(client, pos);

			pos[0] += vecDir[0]*100.0;
			pos[1] += vecDir[1]*100.0;
			pos[2] -= 60.0;
			angle[0] = 0.0;
			TeleportEntity(g_iSentryGun[client], pos, angle, NULL_VECTOR);
		}
	}
	else
	{
		if(buttons & IN_USE	)
		{
			int ent = GetClientAimTarget(client, false);
			if(g_iSentryGun[client] == ent && ent != -1)
				g_bBring[client]=true;
		}
	}

}
