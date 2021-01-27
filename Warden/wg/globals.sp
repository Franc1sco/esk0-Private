int warden = -1;
int tempwarden[MAXPLAYERS+1] = {0,...};

bool Pause = false;
float f_Pause;

Handle WardenColorFix = INVALID_HANDLE;
Handle WardenVIPColorFix = INVALID_HANDLE;

bool Noblock = false;
int NoBlockOffSet;

bool Grab[MAXPLAYERS+1] = {false,...};
bool GrabNew[MAXPLAYERS+1] = {false,...};
bool GrabCanMove[MAXPLAYERS+1] = {false,...};
float GrabDistance[MAXPLAYERS+1];
int GrabTarget[MAXPLAYERS+1] = {-1,...};

char s_frindlyfire_cvars[][] =
{
	"ff_damage_reduction_bullets","ff_damage_reduction_grenade","ff_damage_reduction_grenade_self","ff_damage_reduction_other","mp_friendlyfire"
};

char s_allweaponslist[][] =
{
	"weapon_m4a1","weapon_m4a1_silencer","weapon_ak47","weapon_aug","weapon_awp","weapon_bizon","weapon_deagle",
	"weapon_elite","weapon_famas","weapon_fiveseven","weapon_g3sg1","weapon_galilar","weapon_glock","weapon_hkp2000",
	"weapon_usp_silencer","weapon_m249","weapon_mac10","weapon_mag7","weapon_mp7","weapon_mp9","weapon_negev","weapon_nova","weapon_p90","weapon_p250",
	"weapon_cz75a","weapon_sawedoff","weapon_scar20","weapon_sg556","weapon_ssg08","weapon_tec9","weapon_ump45","weapon_xm1014"
};
char s_allweaponslist_names[][] =
{
	"M4A4","M4A1-S","AK47","AUG","AWP","PP-Bizon","Desert Eagle",
	"Dual Berettas","Famas","Five-Seven","G3SG1","Galil","Glock-18","P2000",
	"USP-S","M249","Mac10","Mag-7","MP7","MP9","Negev","Nova","P90","P250",
	"CZ75a","Sawedoff","Scar20","SG556","SSG08","Tec-9","UMP-45","XM-1014"
};
int g_offsNextPrimaryAttack;
int g_offsNextSecondaryAttack;
UserMsg g_UserMsgFade;

int color_r[] = {255, 255, 255, 0  , 0  , 160, 0, 255, 255};
int color_g[] = {255, 0  , 255, 0  , 255, 82 , 0, 0  , 165};
int color_b[] = {255, 0  , 0  , 255, 0  , 45 , 0, 255, 0  };
char color_s[][] = {"Odstranit","Červená","Žlutá","Modrá","Zelená","Hnědá","Černá","Růžová","Oranžová"};

bool Stopky = false;
float f_Stopky;
float Stopky_timeleft;

bool g_teamgames = false;
bool g_teamgames_start = false;
float f_teamgames_start;
bool tg_random = false;
bool tg_knifedmg = false;
float tg_weapon_damage = 1.0;
float tg_he_damage = 1.0;
char tg_weapon[32];
char tg_weapon_classname[32];
int tg_team[MAXPLAYERS+1] = {0,...};
char tg_teams[][] = {"Žádný","ČERVENÝ","MODRÝ","ZELENÝ","ČERNÝ","ŽLUTÝ"};

char tg_selectedtype[32];
bool tg_weapons = false;
bool tg_knife = false;
bool tg_vybijena = false;
bool tg_granatovana = false;

bool tg_knifeonehit = false;
bool tg_knifeleftattack = true;
bool tg_kniferightattack = true;

bool b_gm_prestrelka_active = false;

int tg_color_r[] = {255, 255, 0  , 0  , 0  , 255};
int tg_color_g[] = {255, 0  , 0  , 255, 0  , 255};
int tg_color_b[] = {255, 0  , 255, 0  , 0  , 0  };
#define TG_TEAM_RED 1
#define TG_TEAM_BLUE 2
#define TG_TEAM_GREEN 3
#define TG_TEAM_BLACK 4
#define TG_TEAM_YELLOW 5

bool g_gamemodes = false;
int gm_lms = 0;
bool b_gm_lms = false;
bool b_gm_lms_pre = false;
float f_gm_lms;

bool b_gm_prestrelka = false;
float f_gm_prestrelka;

bool b_gm_schovka = false;
bool b_gm_schovka_pre = false;
float f_gm_schovka;

bool b_gm_tagday = false;
bool b_gm_tagday_tagged[MAXPLAYERS+1] = {false,...};
Handle h_gm_tagday = INVALID_HANDLE;

bool b_gm_zombieday = false;
bool b_gm_zombieday_pre = false;
float f_gm_zombieday;

bool b_gm_lovecky = false;
bool b_gm_lovecky_played = false;
bool b_gm_lovecky_pre = false;
float f_gm_lovecky;

bool b_gm_freeday = false;
int i_gm_freeday_count;
float f_gm_freeday_wep[MAXPLAYERS+1];
bool b_gm_freeday_wep[MAXPLAYERS+1] = {false,...};
bool b_gm_freeday_rebel[MAXPLAYERS+1] = {false,...};
char s_gm_freeday_wep[][] =
{
	"weapon_m4a1","weapon_m4a1_silencer","weapon_ak47","weapon_aug","weapon_awp","weapon_bizon",
	"weapon_famas","weapon_G3SG1","weapon_galilar","weapon_m249","weapon_mac10","weapon_mag7","weapon_mp7","weapon_mp9","weapon_negev","weapon_nova","weapon_p90","weapon_p250",
	"weapon_sawedoff","weapon_scar20","weapon_sg556","weapon_ssg08","weapon_tec9","weapon_ump45","weapon_xm1014"
};
bool b_gm_s4s = false;
int i_gm_s4s_team[MAXPLAYERS+1];
int i_gm_s4s_iteam = 0;
int i_gm_s4s_weaponi[MAXPLAYERS+1];
char s_gm_s4s_weapon[32];
int g_OffsClip1;

Handle g_clientcookie;
int g_spriteHalo;
int g_sprite;
#define MODEL_LASERBEAM "materials/sprites/laserbeam.vmt"
#define MODEL_LASER_GLOW "materials/sprites/glow01.vmt"
char s_lasershot_list[][] =
{
	"Modrá 23 76 191",
	"Fialová 125 12 204",
	"Zelená 101 204 12",
	"Červená 255 31 31",
	"Oranžová 203 66 12",
	"Růžová 255 66 200",
	"Žlutá 255 255 10",
	"Tyrkysová 10 255 255",
	"Tmavě_zelená 10 90 20",
	"Random"
};

bool b_box = false;
bool b_box_pre = false;
float f_g_box;
bool b_hungergames = false;
bool b_hungergames_pre = false;
float f_g_hungergames;

bool b_gm_prestrelka_played = false;
bool b_gm_schovka_played = false;
bool b_gm_zombieday_played = false;
bool b_gm_tagday_played = false;
bool b_gm_lms_played = false;

bool b_gm_race = false;
bool b_gm_race_pre = false;
float f_gm_race;
bool b_Racers[MAXPLAYERS+1];
bool b_Racers_Winners[MAXPLAYERS+1];
float f_race_start[3];
float f_race_konec[3];
bool b_race_start = false;
bool b_race_konec = false;
int i_race_stayalive;
int i_race_winners;

float f_g_timer;
bool b_g_timer = false;
bool b_g_disabled = false;

bool b_no_warden = false;
float f_no_warden;

float f_g_Marker[3];
bool b_g_Marker = false;

#define HIDE_RADAR 1<<12
