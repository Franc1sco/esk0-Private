stock bool IsEntSpotted(int client, int entity)
{
  float fEyePos[3];
  float fEntPos[3];
  float fVec[3];
  float fAngle[3];
    GetClientEyePosition(client,fEyePos);
    GetEntityAbsOrigin(entity, fEntPos);

    MakeVectorFromPoints(fEyePos, fEntPos, fVec);

    GetVectorAngles(fVec, fAngle);

    Handle hTraceRay = TR_TraceRayFilterEx(fEyePos, fAngle, MASK_SHOT, RayType_Infinite, TraceRayDontHitSelf, client);

    if(TR_DidHit(hTraceRay))
    {
        float fEndPos[3];
        TR_GetEndPosition(fEndPos, hTraceRay); // retrieve our trace endpoint

        if ((GetVectorDistance(fEyePos, fEndPos, false) + TRACE_TOLERANCE) >= GetVectorDistance(fEyePos, fEntPos))
        {
            return true;
        }
    }
    CloseHandle(hTraceRay);
    return false;
}

public bool TraceRayDontHitSelf(entity, contentsMask)
{
    if (entity <= CLIENT_VALID_LAST || !IsValidEntity(entity)) // dont let WORLD, players, or invalid entities be hit
    {
        return false;
    }
    decl String:class[128];
    GetEdictClassname(entity, class, sizeof(class)); // also not zombies or witches, as unlikely that may be, or physobjects (= windows)
    if (StrEqual(class, CLASSNAME_INFECTED, .caseSensitive = false)
    || StrEqual(class, CLASSNAME_WITCH, .caseSensitive = false)
    || StrEqual(class, CLASSNAME_PHYSPROPS, .caseSensitive = false))
    {
        return false;
    }

    return true;
}
