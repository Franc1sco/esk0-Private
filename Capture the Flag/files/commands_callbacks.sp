public Action Command_LAW(int client, const char[] command,int argc)
{
  if(IsValidClient(client, true))
  {
    if(client == flag_ct_carrier || client == flag_t_carrier)
    {
      RemoveFlag(GetClientFlag(client));
      float vec[3];
      GetClientGroundPosition(client, vec);
      vec[2] += 20.0;
      CreateTeamFlagAtCords(GetClientFlag(client), vec);
    }
  }
  return Plugin_Handled;
}
