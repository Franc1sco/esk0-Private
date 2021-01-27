public int Native_IsClientWarden(Handle plugin, int numParams)
{
  int client = GetNativeCell(1);
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      return true;
    }
  }
  return false;
}
