Handle db;
char db_error[512];
char db_query[512];

int g_iCoin;

ArrayList MapPos;
ArrayList ClientStats;

bool sAdmin = false;
Handle hAdmin;
char sMapName[64];

float g_fPauzaTime;

int g_sprite = -1;
int g_spriteHalo = -1;

#define MODEL_COIN "models/custom_props/coin/coin.mdl"
#define MODEL_LASERBEAM "materials/sprites/laserbeam.vmt"
#define MODEL_LASER_GLOW "materials/sprites/glow01.vmt"
