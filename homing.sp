#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
  name = "[CS:GO] Homing Grenade",
  author = "ESK0",
  description = "",
  version = "1.0",
  url = "www.github.com/ESK0"
};

public OnGameFrame()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) > CS_TEAM_SPECTATOR)
		{
			SetHomingProjectile(i, "hegrenade_projectile");
		}
	}
}
SetHomingProjectile(client, const char[] classname)
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, classname))!=INVALID_ENT_REFERENCE)
	{
		int owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
    if(IsClientInGame(owner))
    {
      int Target = GetClosestTarget(entity, owner);
      if(IsClientInGame(Target))
      {
        if(owner == client)
        {
          float ProjLocation[3]
          float ProjVector[3]
          float ProjSpeed
          float ProjAngle[3]
          float TargetLocation[3]
          float AimVector[3];
          GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLocation);
          GetClientAbsOrigin(Target, TargetLocation);
          TargetLocation[2] += 40.0;
          MakeVectorFromPoints(ProjLocation, TargetLocation , AimVector);
          GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);
          ProjSpeed = GetVectorLength(ProjVector);
          AddVectors(ProjVector, AimVector, ProjVector);
          NormalizeVector(ProjVector, ProjVector);
          GetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);
          GetVectorAngles(ProjVector, ProjAngle);
          SetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);
          ScaleVector(ProjVector, ProjSpeed);
          SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);
        }
      }
    }
	}
}

GetClosestTarget(entity, owner)
{
	float TargetDistance = 0.0;
	int ClosestTarget = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
    if(IsClientInGame(i) && i != owner && IsPlayerAlive(i) && GetClientTeam(owner) != GetClientTeam(i))
    {
      float EntityLocation[3]
      float TargetLocation[3];
      GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EntityLocation);
  		GetClientAbsOrigin(i, TargetLocation);
      float distance = GetVectorDistance(EntityLocation, TargetLocation);
  		if(TargetDistance)
  		{
  			if(distance < TargetDistance)
  			{
  				ClosestTarget = i;
  				TargetDistance = distance;
  			}
  		}
  		else
  		{
  			ClosestTarget = i;
  			TargetDistance = distance;
  		}
    }
	}
	return ClosestTarget;
}
