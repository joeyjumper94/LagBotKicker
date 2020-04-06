#include <sourcemod>
#include <system2>
public void HttpResponseCallback(bool success, const char[] error, System2HTTPRequest request, System2HTTPResponse response, HTTPRequestMethod method) {
    if(success){
        char content[512];
        response.GetContent(content, response.ContentLength + 1);
		for(int found=0;found<response.ContentLength;){
			found+=response.GetContent(content,512,found,"\n");
			if(StrContains(content,"This user has not yet set up their Steam Community profile.<br />If you know them, encourage him/her to set up their profile and join in on the gaming!")>0){
				//possible lagbot detected
				char sUrl[128];
				request.GetURL(sUrl,128);
				char sBuffers[2][64];
				ExplodeString(sUrl,"steamcommunity.com/profiles/",sBuffers,2,64,false);
				for(int iPlayer=1;iPlayer<=MaxClients;iPlayer++){
					if(IsClientConnected(iPlayer)){
						char sId[64];
						GetClientAuthId(iPlayer,AuthId_SteamID64,sId,64);
						if(StrEqual(sId,sBuffers[1])){
							KickClientEx(iPlayer);
						}
					}
				}
			}
		}
    }
}
void check_bot(int iPlayer){
	char sId[64];
	GetClientAuthId(iPlayer,AuthId_SteamID64,sId,64);
	char sUrl[512];
	Format(sUrl,512,"https://steamcommunity.com/profiles/%s",sId);
	System2HTTPRequest httpRequest = new System2HTTPRequest(HttpResponseCallback,sUrl);
	httpRequest.SetURL(sUrl);
	httpRequest.GET();
	// Requests have to be deleted, until then they can be used more then once
	delete httpRequest;
}
public OnClientAuthorized(int iPlayer){
	check_bot(iPlayer);
}
public OnClientPostAdminCheck(int iPlayer){
	check_bot(iPlayer);
}
public OnPluginStart(){
	if(!LibraryExists("System2")){
		LogMessage("System2 extension is not running")
		LogMessage("Get System2 here https://forums.alliedmods.net/showthread.php?t=146019")
		SetFailState("until system2 is running, lagbot kicker cannot work")
	}
}

