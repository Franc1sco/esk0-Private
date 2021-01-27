#define FLAG_MODEL_RED "models/overcore/vlajka/sssr.mdl"
#define FLAG_MODEL_BLUE "models/overcore/vlajka/usa.mdl"
#define FILE_PATH "addons/sourcemod/configs/CaptureTheFlag.cfg"

int CTF_FLAG_CT = 1;
int CTF_FLAG_T = 2;

int flag_ct = -1;
int flag_t = -1;

int flag_ct_carrier = -1;
int flag_t_carrier = -1;

float flag_ct_vecOrgs[3];
float flag_t_vecOrgs[3];

char mapname[64];
