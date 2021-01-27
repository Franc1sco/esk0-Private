stock void Particle_Create(int client,  const char[] aName)
{
  if(IsValidEdict(i_cParticle[client]))
  {
    AcceptEntityInput(i_cParticle[client], "Stop");
    AcceptEntityInput(i_cParticle[client], "Kill");
    i_cParticle[client] = -1;
  }
  int particle = CreateEntityByName("info_particle_system");
  if(IsValidEdict(particle))
  {
    float f_pPos[3];
    GetClientAbsOrigin(client, f_pPos);
    f_pPos[2] += 3.0;
    TeleportEntity(particle, f_pPos, NULL_VECTOR, NULL_VECTOR);
    DispatchKeyValue(particle, "effect_name", aName);
    SetVariantString("!activator");
    AcceptEntityInput(particle, "SetParent", client, particle, 0);
    if(aName[0] == 'T')
    {
      SetVariantString("defusekit");
      AcceptEntityInput(particle, "SetParentAttachment");
    }
    DispatchKeyValue(particle, "targetname", "present");
    DispatchSpawn(particle);
    ActivateEntity(particle);
    AcceptEntityInput(particle, "Start");
    i_cParticle[client] = particle;
  }
}
stock void Particle_Remove(int client)
{
  if(IsValidEdict(i_cParticle[client]))
  {
    AcceptEntityInput(i_cParticle[client], "Stop");
    AcceptEntityInput(i_cParticle[client], "Kill");
    i_cParticle[client] = -1;
  }
}
stock void PrecacheEffect(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
	}
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
stock void PrecacheParticleEffect(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("ParticleEffectNames");
	}
	bool save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}
stock void PrecacheAuras()
{
  for(int i; i < sizeof(s_aTrails); i++)
  {
    PrecacheEffect(s_aTrails[i]);
  }
  for(int x; x < sizeof(s_aAuras); x++)
  {
    PrecacheEffect(s_aAuras[x]);
  }
}
