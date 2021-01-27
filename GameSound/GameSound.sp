#include <sourcemod>
#include <emitsoundany>
#include <cstrike>
#include <clientprefs>
#include <multicolors>

#define MAX_EDICTS		2048

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.1.0"
#define MAX_FILE_LEN 256
#define FILE_PATH "addons/sourcemod/configs/GameSound.cfg"

#define TAG1 "[{lime}GameSound{default}] - "
#define TAG "Právě hraje: {lime}"

Handle g_filehandle;

int SongCount = 0;
float StartAdvertTime;

Handle g_cpRoundEnd;

int g_iSoundEnts[MAX_EDICTS];
int g_iNumSounds;

public Plugin myinfo = {
	name = "CS:GO GameSounds",
	author = "ESK0",
	description = "CS:GO GameSounds",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/esk0"
};

public void OnPluginStart()
{
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	RegConsoleCmd("sm_res", Event_Music);

	g_cpRoundEnd = RegClientCookie("csgoucko_res", "", CookieAccess_Private);

	LoadSongs();
}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
  CreateNative("eRoundEnd_Get", Native_RoundEnd_Get);
  CreateNative("eRoundEnd_Set", Native_RoundEnd_Set);
  RegPluginLibrary("esko");
  return APLRes_Success;
}
public int Native_RoundEnd_Get(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool bReturn;
	char value[12];
	GetClientCookie(client, g_cpRoundEnd, value, sizeof(value));
	if(StrEqual(value, ""))
	{
		bReturn = true;
	}
	else
	{
		bReturn = false;
	}
	return bReturn;
}
public int Native_RoundEnd_Set(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool state = GetNativeCell(2);
	if(state == true)
	{
		SetClientCookie(client, g_cpRoundEnd, "");
	}
	else
	{
		SetClientCookie(client, g_cpRoundEnd, "1");
	}
}
public void OnGameFrame()
{
	float time = 120.0;
	float timeleft = StartAdvertTime - GetGameTime() + time;
	if(timeleft < 0.01)
	{
		StartAdvertTime = GetGameTime();
		CPrintToChatAll("%s Hudbu si lze {Darkred}zap{default}/{Green}vyp{default} příkazem {Purple}!res",TAG1);
	}
}
public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iNumSounds = 0;

	UpdateSounds();
	CreateTimer(0.8, Post_Start);
}
public void UpdateSounds()
{
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	while ((entity = FindEntityByClassname(entity, "ambient_generic")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
		int len = strlen(sSound);
		if (len > 4 && (StrEqual(sSound[len-3], "mp3") || StrEqual(sSound[len-3], "wav")))
		{
			g_iSoundEnts[g_iNumSounds++] = EntIndexToEntRef(entity);
		}
	}
}
public Action Post_Start(Handle timer)
{
	if(GetClientCount() <= 0)
	{
		return Plugin_Continue;
	}
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	for(int i=1;i<=MaxClients;i++)
	{
		if(IsValidClient(i))
		{
			for (int u = 0; u<g_iNumSounds; u++)
			{
				entity = EntRefToEntIndex(g_iSoundEnts[u]);
				if (entity != INVALID_ENT_REFERENCE)
				{
					GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
					Client_StopSound(i, entity, SNDCHAN_STATIC, sSound);
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action Event_Music(int client, int args)
{
	char value[12];
	GetClientCookie(client, g_cpRoundEnd, value, sizeof(value));
	if(StrEqual(value, ""))
	{
		SetClientCookie(client, g_cpRoundEnd, "1");
		CPrintToChat(client,"%s Vypnul sis písničky na konci kola", TAG1);
	}
	else
	{
		SetClientCookie(client, g_cpRoundEnd, "");
		CPrintToChat(client,"%s Zapnul sis písničky na konci kola", TAG1);
	}
}
public void OnMapStart()
{
  StartAdvertTime = GetGameTime();
  SongCount = 0;
  Handle SoundDir = OpenDirectory("sound/esko/res");
  FileType type;
  int namelen;
  char name[64];
  while(ReadDirEntry(SoundDir,name,sizeof(name),type))
  {
  	namelen = strlen(name) - 4;
  	if(StrContains(name,".mp3",false) == namelen)
  	{
  		SongCount++;
  	}
  }
  CloseHandle(SoundDir);
  char win_snd[MAX_FILE_LEN];
  for(int i = 1 ; i <= SongCount; i++)
  {
  	Format(win_snd, sizeof(win_snd), "sound/esko/res//%i.mp3", i);
  	if(FileExists(win_snd))
  	{
  		AddFileToDownloadsTable(win_snd);
  		Format(win_snd, sizeof(win_snd), "esko/res/%i.mp3", i);
  		PrecacheSoundAny(win_snd);
  	}
  }
}
public Action Event_OnRoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	if(winner == CS_TEAM_T || winner == CS_TEAM_CT)
	{
		char s_soundname[512];
		Format(s_soundname, sizeof(s_soundname), "N/A");
		int rnd_sound = GetRandomInt(1, SongCount);
		char s_rnd_sound[256];
		Format(s_rnd_sound, sizeof(s_rnd_sound), "esko/res/%i.mp3", rnd_sound);
		for(int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client))
			{
				char value[12];
				GetClientCookie(client, g_cpRoundEnd, value, sizeof(value));
				if(StrEqual(value, ""))
				{
					char sSound[PLATFORM_MAX_PATH];
					int entity;
					for (int i = 0; i < g_iNumSounds; i++)
					{
						entity = EntRefToEntIndex(g_iSoundEnts[i]);

						if (entity != INVALID_ENT_REFERENCE)
						{
							GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
							Client_StopSound(client, entity, SNDCHAN_STATIC, sSound);
						}
					}
					char songnum[3];
					IntToString(rnd_sound,songnum,sizeof(songnum));
					EmitSoundToClientAny(client,s_rnd_sound,SOUND_FROM_PLAYER,SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.7);
					KvGetString(g_filehandle, songnum, s_soundname, sizeof(s_soundname), "N/A");
					CPrintToChat(client,"%s%s",TAG , s_soundname);
				}
			}
		}
	}
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
public void LoadSongs()
{
	g_filehandle = CreateKeyValues("GameSounds");
	if(!FileExists(FILE_PATH))
	{
		SetFailState("[GameSounds] 'addons/sourcemod/configs/GameSound.cfg' not found!");
		return;
	}
	FileToKeyValues(g_filehandle, FILE_PATH);
	KvJumpToKey(g_filehandle, "RoundEnd");
}
stock void Client_StopSound(int client, int entity, int channel, const char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
}
