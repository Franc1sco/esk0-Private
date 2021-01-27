#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <clientprefs>
#include <sdkhooks>
#include <emitsoundany>
#include <multicolors>

#define s_Tag "[{Lightblue}PlaySounds{default}]"

char SongList[1024];
int i_songCount = 0;
int i_DisabledSound[MAXPLAYERS+1] = 1;
float f_soundTimeLeft;
float f_soundStart;
bool b_soundEnable = true;


Handle g_clientcookie;

public Plugin myinfo =
{
    name = "PlaySound",
    author = "ESK0",
    description = "",
    version = "1.0",
};
public OnPluginStart()
{
  g_clientcookie = RegClientCookie("ePlaySound", "", CookieAccess_Private);
  RegConsoleCmd("say", Event_ChatMessage);
  RegConsoleCmd("sm_song", Event_Song);
  RegConsoleCmd("sm_disablesong", Event_DisableSong);
  CreateTimer(45.0, Timer_Advert,_,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
  for(int x = 0; x <= MaxClients;x++)
  {
    if(IsValidClient(x))
    {
      OnClientCookiesCached(x);
    }
  }
}
public OnClientCookiesCached(client)
{
	char value[12];
	GetClientCookie(client, g_clientcookie, value, sizeof(value));
	i_DisabledSound[client] = StringToInt(value);
}
public Action Event_DisableSong(client, args)
{
  if(IsValidClient(client))
  {
    char value[12];
    GetClientCookie(client, g_clientcookie, value, sizeof(value));
    i_DisabledSound[client] = StringToInt(value);
    if(i_DisabledSound[client] == 0)
    {
      SetClientCookie(client, g_clientcookie, "1");
      i_DisabledSound[client] = 1;
      CPrintToChat(client,"%s Disabled",s_Tag);
    }
    else if(i_DisabledSound[client] == 1)
    {
      SetClientCookie(client, g_clientcookie, "0");
      i_DisabledSound[client] = 0;
      CPrintToChat(client,"%s Enabled",s_Tag);
    }
  }
}
public Action Timer_Advert(Handle timer)
{
  CPrintToChatAll("%s Sounds list can be found here {Lime}/song",s_Tag);
}
public Action Event_Song(client, args)
{
  if(IsValidClient(client))
  {
    ShowMOTDPanel(client, "www.GameSites.cz", "http://fastdl.gamesites.cz/global/motd/songs.html", MOTDPANEL_TYPE_URL);
  }
}
public OnGameFrame()
{
  f_soundTimeLeft = f_soundStart - GetGameTime() + 45.0;
  if(f_soundTimeLeft < 0.01)
  {
    b_soundEnable = true;
  }
}
public OnMapStart()
{
  LoadSongs();
  b_soundEnable = true;
}
public Action Event_ChatMessage(client,args)
{
  if(IsValidClient(client))
  {
    char arg[32];
    new String: Songs[100][32];
    GetCmdArg(1, arg,sizeof(arg));
    if(arg[0] != 0 && arg[0] != '@' && arg[0] != '/')
    {
      ExplodeString(SongList, "|", Songs, sizeof(Songs), sizeof(Songs[]));
      for(int i = 0; i <= i_songCount;i++)
      {
        if(StrEqual(Songs[i], arg))
        {
          if(i_DisabledSound[client] == 0)
          {
            if(b_soundEnable)
            {
              char buffer[64];
              Format(buffer, sizeof(buffer), "playsound/%s.mp3", arg);
              for(int x = 0; x <= MaxClients;x++)
              {
                if(i_DisabledSound[x] == 0 && IsValidClient(x))
                {
                  EmitSoundToClientAny(x,buffer,SOUND_FROM_PLAYER,SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.33);
                  CPrintToChat(x,"%s Player {Lime}%N {default}play sound {Purple}%s.",s_Tag, client,arg);
                }
              }
              b_soundEnable = false;
              f_soundStart = GetGameTime();
            }
            else CPrintToChat(client, "%s Next song will be able play in {Lime}%0.01fs{default}.",s_Tag, f_soundTimeLeft);
            return Plugin_Handled;
          }
          else CPrintToChat(client, "%s you have to first enable sounds {Lime}!disablesong",s_Tag);
        }
      }
    }
  }
  return Plugin_Continue;
}
public LoadSongs()
{
  Handle SoundDir = OpenDirectory("sound/playsound/");
  new FileType:type;
  int namelen;
  char name[64];
  char buffer[64];
  i_songCount = 0;
  while(ReadDirEntry(SoundDir,name,sizeof(name),type))
  {
    namelen = strlen(name) - 4;
    if(StrContains(name,".mp3",false) == namelen)
    {
      Format(buffer, sizeof(buffer), "sound/playsound/%s", name);
      AddFileToDownloadsTable(buffer);
      Format(buffer, sizeof(buffer), "playsound/%s", name);
      PrecacheSoundAny(buffer);
      ReplaceString(name,sizeof(name), ".mp3", "",false);
      if(SongList[0] == 0) Format(SongList,sizeof(SongList),"%s",name);
      else Format(SongList,sizeof(SongList),"%s|%s",SongList,name);
      i_songCount++;
    }
  }
  CloseHandle(SoundDir);
}
stock bool IsValidClient(client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	return false;
}
