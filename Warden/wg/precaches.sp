public void SoundPrecache()
{
	AddFileToDownloadsTable("sound/esko/warden/teamgames/1.mp3");
	AddFileToDownloadsTable("sound/esko/warden/teamgames/2.mp3");
	AddFileToDownloadsTable("sound/esko/warden/teamgames/3.mp3");
	PrecacheSoundAny("esko/warden/teamgames/1.mp3");
	PrecacheSoundAny("esko/warden/teamgames/2.mp3");
	PrecacheSoundAny("esko/warden/teamgames/3.mp3");
}

public void ModelPrecache()
{
	AddFileToDownloadsTable("models/player/custom_player/legacy/zombie/zombie_v3.mdl");
	AddFileToDownloadsTable("models/player/custom_player/legacy/zombie/zombie_v3.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/legacy/zombie/zombie_v3.phy");
	AddFileToDownloadsTable("models/player/custom_player/legacy/zombie/zombie_v3.vvd");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0247_1.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0247_1.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0247_3.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0248_1.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0248_1.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/legacy/zombie/Tex_0248_1_NRM.vtf");

	PrecacheModel("models/player/custom_player/legacy/zombie/zombie_v3.mdl");
}
