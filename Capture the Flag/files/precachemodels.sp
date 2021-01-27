public void PrecacheModels()
{
  // Blue Flag
  AddFileToDownloadsTable("materials/models/overcore/vlajka/usa.vmt");
  AddFileToDownloadsTable("materials/models/overcore/vlajka/usa.vtf");
  AddFileToDownloadsTable("models/overcore/vlajka/usa.dx90.vtx");
  AddFileToDownloadsTable("models/overcore/vlajka/usa.mdl");
  AddFileToDownloadsTable("models/overcore/vlajka/usa.phy");
  AddFileToDownloadsTable("models/overcore/vlajka/usa.vvd");
  PrecacheModel("models/overcore/vlajka/usa.mdl");
  // Red Flag
  AddFileToDownloadsTable("materials/models/overcore/vlajka/sssr.vmt");
  AddFileToDownloadsTable("materials/models/overcore/vlajka/sssr.vtf");
  AddFileToDownloadsTable("models/overcore/vlajka/sssr.dx90.vtx");
  AddFileToDownloadsTable("models/overcore/vlajka/sssr.mdl");
  AddFileToDownloadsTable("models/overcore/vlajka/sssr.phy");
  AddFileToDownloadsTable("models/overcore/vlajka/sssr.vvd");
  PrecacheModel("models/overcore/vlajka/sssr.mdl");

}
