stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
stock bool IsClientVIP(int client)
{
  if(CheckCommandAccess(client, "", ADMFLAG_RESERVATION))
  {
    return true;
  }
  return false;
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
public bool TraceRay_DontHitSelf(int iTarget,int iMask, int iClient)
{
	return (iTarget != iClient);
}
stock void Coin_CreateSpawn(int client)
{
  float fVec[3];
  char sVec[256];
  GetClientGroundPosition(client, fVec);
  Format(sVec, sizeof(sVec), "%f;%f;%f",fVec[0],fVec[1],fVec[2]);
  MapPos.PushString(sVec);
}
stock void Coin_RemoveClose(int client)
{
  float fVec[3];
  float fVecExp[3];
  char sVec[256];
  char sVecEx[3][256];
  GetClientGroundPosition(client, fVec);
  Format(sVec, sizeof(sVec), "%f;%f;%f",fVec[0],fVec[1],fVec[2]);
  for(int i = 0; i < MapPos.Length; i++)
  {
    MapPos.GetString(i, sVec, sizeof(sVec));
    ExplodeString(sVec, ";", sVecEx, sizeof(sVecEx), sizeof(sVecEx[]));
    fVecExp[0] = StringToFloat(sVecEx[0]);
    fVecExp[1] = StringToFloat(sVecEx[1]);
    fVecExp[2] = StringToFloat(sVecEx[2]);
    if(GetVectorDistance(fVec, fVecExp) < 80)
    {
      MapPos.Erase(i);
      break;
    }
  }
}
stock void Coins_Admin()
{
  sAdmin = !sAdmin;
  PrintToChatAll("[CoinSystem] - %s", sAdmin?"Zapnuto":"Vypnuto");
  if(sAdmin == true)
  {
    g_fPauzaTime = GetGameTime();
    hAdmin = CreateTimer(1.0, Timer_ShowCoins, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
  }
  else
  {
    delete hAdmin;
  }
}
public void CreateCoin(float cords[3], bool broadcast)
{
  g_iCoin = CreateEntityByName("prop_dynamic_override");
  DispatchKeyValue(g_iCoin, "model", MODEL_COIN);
  SetEntProp(g_iCoin, Prop_Send, "m_usSolidFlags", 12);
  SetEntProp(g_iCoin, Prop_Data, "m_nSolidType", 6);
  SetEntProp(g_iCoin, Prop_Send, "m_CollisionGroup", 1);
  SetEntPropFloat(g_iCoin, Prop_Send, "m_flModelScale", 0.5);
  DispatchSpawn(g_iCoin);
  SetVariantString("challenge_coin_idle");
  AcceptEntityInput(g_iCoin, "SetAnimation");
  if(broadcast)
  {
    CPrintToChatAll("[{Lime}Coins{Default}] Mince byla spawnuta");
  }
  TeleportEntity(g_iCoin, cords, NULL_VECTOR, NULL_VECTOR);
  SDKHook(g_iCoin, SDKHook_StartTouch, EventSDK_OnStartTouch);
}
stock int CountPlayer()
{
  int count = 0;
  for(int i = 1; i <= MaxClients; i++)
  {
    if(IsValidClient(i))
    {
      count++;
    }
  }
  return count;
}
