public Action Command_CoinAdmin(int client, int args)
{
  if(IsValidClient(client))
  {
    Menu_CoinAdmin(client);
  }
  return Plugin_Handled;
}
