public Action EventSDK_OnStartTouch(int entity,int client)
{
  if(entity != client)
  {
    if(entity == g_iCoin && IsValidClient(client, true))
    {
      SDKUnhook(g_iCoin, SDKHook_StartTouch, EventSDK_OnStartTouch);
      SetVariantString("challenge_coin_collect");
      AcceptEntityInput(g_iCoin, "SetAnimation");
      EmitSoundToAllAny("esko/coin/coin_collect.mp3", g_iCoin, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.4);
      int add = 1;
      if(IsClientVIP(client))
      {
        if(GetRandomInt(1, 100) <= 10)
        {
          add = 2;
        }
      }
      ClientStats.Set(client, ClientStats.Get(client)+add);
      CPrintToChatAll("{Lime}Hráč {Orange}%N {Lime}sebral sběratelskou minci! Celkem %i", client, ClientStats.Get(client));
      CreateTimer(0.3, Timer_RemoveCoin, EntIndexToEntRef(g_iCoin), TIMER_FLAG_NO_MAPCHANGE);
    }
  }
}
public Action Timer_RemoveCoin(Handle timer, int ref)
{
  int entity = EntRefToEntIndex(ref);
  if(IsValidEntity(entity))
  {
    if(g_iCoin == entity)
    {
      AcceptEntityInput(g_iCoin, "kill");
      g_iCoin = -1;
    }
  }
}
