public Action Event_OnPlayerConnectFull(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsValidClient(client))
  {
		if(CountPlayerInTeam(CS_TEAM_T) + CountPlayerInTeam(CS_TEAM_CT) == 0)
		{
			ChangeClientTeam(client, GetRandomInt(2,3));
		}
		else
		{
			if(CountPlayerInTeam(CS_TEAM_T) < CountPlayerInTeam(CS_TEAM_CT))
			{
				ChangeClientTeam(client, CS_TEAM_CT);
			}
			else
			{
				ChangeClientTeam(client, CS_TEAM_T);
			}
		}
  }
	return Plugin_Continue;
}
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontbroadcast)
{
	CreateTeamFlagAtCords(CTF_FLAG_T, flag_t_vecOrgs);
	CreateTeamFlagAtCords(CTF_FLAG_CT, flag_ct_vecOrgs);
}
public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontbroadcast)
{
  int victim = GetClientOfUserId(GetEventInt(event, "userid"));
  if(IsValidClient(victim))
  {
    if(GetClientTeam(victim) == CS_TEAM_T && victim == flag_ct_carrier)
    {
      float vec[3];
      GetClientGroundPosition(victim, vec);
      vec[2] += 20.0;
      RemoveFlag(CTF_FLAG_CT);
      CreateTeamFlagAtCords(CTF_FLAG_CT,vec);
    }
    else if(GetClientTeam(victim) == CS_TEAM_CT && victim == flag_t_carrier)
    {
      float vec[3];
      GetClientGroundPosition(victim, vec);
      vec[2] += 20.0;
      RemoveFlag(CTF_FLAG_T);
      CreateTeamFlagAtCords(CTF_FLAG_T,vec);
    }
  }
}
