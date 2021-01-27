public Action EventSDK_OnStartTouch(int entity,int client)
{
  if(entity != client)
  {
    if(IsEntityFlag(entity) && IsValidClient(client, true))
    {
      if(GetClientTeam(client) == CS_TEAM_CT && flag_t_carrier == -1 && entity == flag_t)
      {
        PrintToChatAll("Hráč: %N sebral nepřátelskou teroristickou vlajku", client);
        RemoveFlag(CTF_FLAG_T);
        CreateParentFlag(client);
      }
      else if(GetClientTeam(client) == CS_TEAM_T && flag_ct_carrier == -1 && entity == flag_ct)
      {
        PrintToChatAll("Hráč: %N sebral nepřátelskou counter-teroristickou vlajku", client);
        RemoveFlag(CTF_FLAG_CT);
        CreateParentFlag(client);
      }
      if(GetClientTeam(client) == CS_TEAM_CT && IsClientFlagCarrier(client, 2) && entity == flag_ct && flag_ct_carrier == -1)
      {
        PrintToChatAll("Hráč: %N přinesl nepřátelskou vlajku", client);
        RemoveFlag(CTF_FLAG_T);
        CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
        flag_t_carrier = -1;
      }
      else if(GetClientTeam(client) == CS_TEAM_T && IsClientFlagCarrier(client, 1) && entity == flag_t && flag_t_carrier == -1)
      {
        PrintToChatAll("Hráč: %N přinesl nepřátelskou vlajku", client);
        RemoveFlag(CTF_FLAG_CT);
        CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
        flag_ct_carrier = -1;
      }
      float position[3];
      GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
      if(GetClientTeam(client) == CS_TEAM_CT && flag_ct_carrier == -1 && entity == flag_ct && !FloatEqual(position, flag_ct_vecOrgs))
      {
        RemoveFlag(CTF_FLAG_CT);
        CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
      }
      else if(GetClientTeam(client) == CS_TEAM_T && flag_t_carrier == -1 && entity == flag_t && !FloatEqual(position, flag_t_vecOrgs))
      {
        RemoveFlag(CTF_FLAG_T);
        CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
      }
    }
  }
}
public void EventSDK_OnClientThink(int client)
{
  if(IsValidClient(client, true))
  {
    if(client == flag_ct_carrier || client == flag_t_carrier)
    {
      SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.8);
    }
    else
    {
      SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
    }
  }
}
