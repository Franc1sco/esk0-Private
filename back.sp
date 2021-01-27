#include <sourcemod>
#include <sdkhooks>
#include <sdktools>



#define BACKSTAB_ANGLE 93.0
#define BACKSTAB_MAX_DAMAGE 0.0

public Plugin myinfo =
{
  name = "No back damage",
  author = "ESK0",
  version = "1.0"
};
public void OnClientPutInServer(int client)
{
  if(IsValidClient(client))
  {
    SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
  }
}
public void OnMapStart()
{
  SetLightStyle(0, "z");
}
public Action EventSDK_OnTakeDamage(int victim,int &attacker,int &inflictor, float &damage,int &damagetype,int &weapon, float damageForce[3], float damagePosition[3])
{
  if(IsValidClient(attacker))
  {
    if(IsValidClient(victim))
    {
      float f_Result = GetAngleBetweenVector(attacker, victim);
      PrintToChatAll("%0.3f", f_Result);
    }
  }
}

stock bool IsClientShootingEnemyBack(int target, int client)
{
  float angAbsRotation1[3];
  float angAbsRotation2[3];
  GetEntPropVector(client, Prop_Data, "m_angRotation", angAbsRotation1);
  GetEntPropVector(target, Prop_Data, "m_angRotation", angAbsRotation2);
  float ang = max(angAbsRotation1[1], angAbsRotation2[1]) - min(angAbsRotation1[1], angAbsRotation2[1])
  if(ang > 180.0)
  {
    ang = 360.0 - ang;
  }
  if(ang < 55)
  {
    return true;
  }
  return false;
}
stock float GetAngleBetweenVector(int client, int target)
{
    float f_OutPut;
    float f_ClienAng[3];
    float f_VecOrg[3];
    float f_TargetVecOrg[3];
    float f_AngVec[3];
    GetEntPropVector(client, Prop_Data, "m_angRotation", f_ClienAng);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", f_VecOrg);
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", f_TargetVecOrg);
    GetAngleVectors(f_ClienAng, f_AngVec, NULL_VECTOR, NULL_VECTOR);
    f_VecOrg[0] = f_TargetVecOrg[0] - f_VecOrg[0];
    f_VecOrg[1] = f_TargetVecOrg[1] - f_VecOrg[1];
    f_VecOrg[2] = 0.0;
    f_AngVec[2] = 0.0;
    NormalizeVector(f_AngVec, f_AngVec);
    ScaleVector(f_VecOrg, 1/SquareRoot(f_VecOrg[0]*f_VecOrg[0]+f_VecOrg[1]*f_VecOrg[1]+f_VecOrg[2]*f_VecOrg[2]));
    f_OutPut = ArcCosine(f_VecOrg[0]*f_AngVec[0]+f_VecOrg[1]*f_AngVec[1]+f_VecOrg[2]*f_AngVec[2]);
    return RadToDeg(f_OutPut);
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
