/*
*						,---.     ,--.      ,---.
*						|---',   .|   |,---.|---'
*						|  \ |   ||   ||---'|  \
*						`   ``---|`--' `---'`   `
*						     `---'
*                       --------------------------
*   					Release: RyDeR's Speedometer v2.0
*						Don't delete credits please
*                       --------------------------
*/
//====================//
#include <a_samp>
//====================//
#define GREEN 				0x21DD00FF
#define RED 				0xE60000FF
#define ADMIN_RED 			0xFB0000FF
#define YELLOW 				0xFFFF00FF
#define ORANGE 				0xF97804FF
#define LIGHTRED 			0xFF8080FF
#define LIGHTBLUE 			0x00C2ECFF
#define PURPLE 				0xB360FDFF
#define BLUE 				0x1229FAFF
#define LIGHTGREEN 			0x38FF06FF
#define DARKPINK 			0xE100E1FF
#define NICESKY 			0x99FFFFAA
#define GRAY 				0xCECECEFF
//====================//
forward GostergeYenile();
//====================//
new HGS;
new Gosterge[MAX_PLAYERS];

new Text: GostergeYazi[MAX_PLAYERS];
new Text: Hizg[MAX_PLAYERS];
new Text: Cang[MAX_PLAYERS];
new Text: Cizgi;
new Text: ArkaPlan0;
new Text: ArkaPlan1;
new Text: ArkaPlan2;
new Text: ArkaPlan3;
new Text: ArkaPlan4;
new Text: ArkaPlan5;
new Text: ArkaPlan6;

new Float: KMH;
new Float: Yukseklik;
new Float: Xa;
new Float: Ya;
new Float: Za;
new Float: Xb[MAX_PLAYERS];
new Float: Yb[MAX_PLAYERS];
new Float: Zb[MAX_PLAYERS];

new ArIsim[][] = // Not made by me
{
    	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
        "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
        "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
        "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
        "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
        "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
        "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
        "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
        "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
        "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
        "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
        "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
        "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
        "Blista Compact", "Police Maverick", "Boxvillde", "Benson", "Mesa", "RC Goblin",
        "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
        "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
        "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
        "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
        "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
        "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
		"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
        "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
        "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
        "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
        "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
        "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
        "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
        "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
        "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
        "Tiller", "Utility Trailer"
};
//====================//
public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Speedometer by [WsR]RyDeR - Loaded -");
	print("--------------------------------------\n");
	
	HGS = SetTimer("GostergeYenile",300,1);

	ArkaPlan0 = TextDrawCreate(611.000000,377.000000,"_");
	TextDrawUseBox(ArkaPlan0,1);
	TextDrawBoxColor(ArkaPlan0,0x00000033);
	TextDrawTextSize(ArkaPlan0,529.000000,0.000000);
	TextDrawAlignment(ArkaPlan0,0);
	TextDrawBackgroundColor(ArkaPlan0,0x000000ff);
	TextDrawFont(ArkaPlan0,1);
	TextDrawLetterSize(ArkaPlan0,-3.700000,5.100007);
	TextDrawColor(ArkaPlan0,0xffffffff);
	TextDrawSetProportional(ArkaPlan0,1);
	TextDrawSetShadow(ArkaPlan0,1);
	
	ArkaPlan1 = TextDrawCreate(611.000000,375.000000,"_");
	TextDrawUseBox(ArkaPlan1,1);
	TextDrawBoxColor(ArkaPlan1,0x000000ff);
	TextDrawTextSize(ArkaPlan1,530.000000,185.000000);
	TextDrawAlignment(ArkaPlan1,0);
	TextDrawBackgroundColor(ArkaPlan1,0x000000ff);
	TextDrawFont(ArkaPlan1,3);
	TextDrawLetterSize(ArkaPlan1,2.799999,-0.200000);
	TextDrawColor(ArkaPlan1,0xffffffff);
	TextDrawSetOutline(ArkaPlan1,1);
	TextDrawSetProportional(ArkaPlan1,1);
	TextDrawSetShadow(ArkaPlan1,1);
	
	ArkaPlan2 = TextDrawCreate(532.000000,375.000000,"_");
	TextDrawUseBox(ArkaPlan2,1);
	TextDrawBoxColor(ArkaPlan2,0x000000ff);
	TextDrawTextSize(ArkaPlan2,530.000000,32.000000);
	TextDrawAlignment(ArkaPlan2,0);
	TextDrawBackgroundColor(ArkaPlan2,0x000000ff);
	TextDrawFont(ArkaPlan2,3);
	TextDrawLetterSize(ArkaPlan2,1.000000,5.299999);
	TextDrawColor(ArkaPlan2,0xffffffff);
	TextDrawSetOutline(ArkaPlan2,1);
	TextDrawSetProportional(ArkaPlan2,1);
	TextDrawSetShadow(ArkaPlan2,1);

	ArkaPlan3 = TextDrawCreate(532.000000,426.000000,"_");
	TextDrawUseBox(ArkaPlan3,1);
	TextDrawBoxColor(ArkaPlan3,0x000000ff);
	TextDrawTextSize(ArkaPlan3,609.000000,82.000000);
	TextDrawAlignment(ArkaPlan3,0);
	TextDrawBackgroundColor(ArkaPlan3,0x000000ff);
	TextDrawFont(ArkaPlan3,3);
	TextDrawLetterSize(ArkaPlan3,1.500000,-0.200000);
	TextDrawColor(ArkaPlan3,0xffffffff);
	TextDrawSetOutline(ArkaPlan3,1);
	TextDrawSetProportional(ArkaPlan3,1);
	TextDrawSetShadow(ArkaPlan3,1);
	
	ArkaPlan4 = TextDrawCreate(613.000000,375.000000,"_");
	TextDrawUseBox(ArkaPlan4,1);
	TextDrawBoxColor(ArkaPlan4,0x000000ff);
	TextDrawTextSize(ArkaPlan4,607.000000,-1.000000);
	TextDrawAlignment(ArkaPlan4,0);
	TextDrawBackgroundColor(ArkaPlan4,0x000000ff);
	TextDrawLetterSize(ArkaPlan4,0.199999,5.399997);
	TextDrawFont(ArkaPlan4,3);
	TextDrawColor(ArkaPlan4,0xffffffff);
	TextDrawSetOutline(ArkaPlan4,1);
	TextDrawSetProportional(ArkaPlan4,1);
	TextDrawSetShadow(ArkaPlan4,1);
	
	ArkaPlan5 = TextDrawCreate(538.000000,397.000000,"_");
	TextDrawUseBox(ArkaPlan5,1);
	TextDrawBoxColor(ArkaPlan5,0x00ff0033);
	TextDrawTextSize(ArkaPlan5,603.000000,64.000000);
	TextDrawAlignment(ArkaPlan5,0);
	TextDrawBackgroundColor(ArkaPlan5,0x000000ff);
	TextDrawFont(ArkaPlan5,3);
	TextDrawLetterSize(ArkaPlan5,1.000000,-0.000000);
	TextDrawColor(ArkaPlan5,0xffffffff);
	TextDrawSetOutline(ArkaPlan5,1);
	TextDrawSetProportional(ArkaPlan5,1);
	TextDrawSetShadow(ArkaPlan5,1);

	ArkaPlan6 = TextDrawCreate(607.000000,420.000000,"_");
	TextDrawUseBox(ArkaPlan6,1);
	TextDrawBoxColor(ArkaPlan6,0xff000033);
	TextDrawTextSize(ArkaPlan6,534.000000,0.000000);
	TextDrawAlignment(ArkaPlan6,0);
	TextDrawBackgroundColor(ArkaPlan6,0x000000ff);
	TextDrawFont(ArkaPlan6,3);
	TextDrawLetterSize(ArkaPlan6,1.000000,-0.000000);
	TextDrawColor(ArkaPlan6,0xffffffff);
	TextDrawSetOutline(ArkaPlan6,1);
	TextDrawSetProportional(ArkaPlan6,1);
	TextDrawSetShadow(ArkaPlan6,1);

	Cizgi = TextDrawCreate(556.000000,420.000000,"_");
	TextDrawUseBox(Cizgi,1);
	TextDrawBoxColor(Cizgi,0xffffffff);
	TextDrawTextSize(Cizgi,551.000000,0.000000);
	TextDrawAlignment(Cizgi,0);
	TextDrawBackgroundColor(Cizgi,0x000000ff);
	TextDrawFont(Cizgi,3);
	TextDrawLetterSize(Cizgi,0.199999,-0.000000);
	TextDrawColor(Cizgi,0xffffffff);
	TextDrawSetOutline(Cizgi,1);
	TextDrawSetProportional(Cizgi,1);
	TextDrawSetShadow(Cizgi,1);
	
	for(new i=0; i<GetMaxPlayers(); i++)
	{
		Gosterge[i] = 1;
  		GostergeYazi[i] = TextDrawCreate(535.000000,376.000000, " ");
    	TextDrawAlignment(GostergeYazi[i],0);
     	TextDrawBackgroundColor(GostergeYazi[i],0x000000ff);
      	TextDrawFont(GostergeYazi[i],1);
		TextDrawLetterSize(GostergeYazi[i],0.199999,0.899999);
  		TextDrawSetProportional(GostergeYazi[i],1);
    	TextDrawSetShadow(GostergeYazi[i],1);
     	TextDrawColor(GostergeYazi[i],0xffff00ff);

		Hizg[i] = TextDrawCreate(538.000000,397.000000,"_");
		TextDrawUseBox(Hizg[i],1);
		TextDrawBoxColor(Hizg[i],0x00ff0066);
		TextDrawAlignment(Hizg[i],0);
		TextDrawBackgroundColor(Hizg[i],0x000000ff);
		TextDrawFont(Hizg[i],3);
		TextDrawLetterSize(Hizg[i],9.100000,-0.000000);
		TextDrawColor(Hizg[i],0xffffffff);
		TextDrawSetOutline(Hizg[i],1);
		TextDrawSetProportional(Hizg[i],1);
		TextDrawSetShadow(Hizg[i],1);

		Cang[i] = TextDrawCreate(538.000000,420.000000,"_");
		TextDrawUseBox(Cang[i],1);
		TextDrawBoxColor(Cang[i],0xff000066);
		TextDrawAlignment(Cang[i],0);
		TextDrawBackgroundColor(Cang[i],0x000000ff);
		TextDrawFont(Cang[i],3);
		TextDrawLetterSize(Cang[i],1.000000,-0.000000);
		TextDrawColor(Cang[i],0xffffffff);
		TextDrawSetOutline(Cang[i],1);
		TextDrawSetProportional(Cang[i],1);
		TextDrawSetShadow(Cang[i],1);

	}
	return 1;
}
//====================//
public OnFilterScriptExit()
{
	print("\n--------------------------------------");
	print(" Speedometer by [WsR]RyDeR - Unloaded -");
	print("--------------------------------------\n");
	KillTimer(HGS);

 	TextDrawDestroy(Text:ArkaPlan0);
    TextDrawDestroy(Text:ArkaPlan1);
    TextDrawDestroy(Text:ArkaPlan2);
    TextDrawDestroy(Text:ArkaPlan3);
    TextDrawDestroy(Text:ArkaPlan4);
    TextDrawDestroy(Text:ArkaPlan5);
    TextDrawDestroy(Text:ArkaPlan6);
    TextDrawDestroy(Text:Cizgi);
    
   	for(new i=0; i<GetMaxPlayers(); i++)
	{
		TextDrawDestroy(GostergeYazi[i]);
		TextDrawDestroy(Hizg[i]);
		TextDrawDestroy(Cang[i]);
	}
	return 1;
}
//====================//
public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/velo", cmdtext, true, 10) == 0)
	{
	    if(Gosterge[playerid] == 1)
	    {
	        Gosterge[playerid] = 0;
	        SendClientMessage(playerid,ADMIN_RED,"<< Velocimetro desabilitado.");
	    }
	    else if(Gosterge[playerid] == 0)
	    {
	        Gosterge[playerid] = 1;
	        SendClientMessage(playerid,LIGHTGREEN,">> Velocimetro habilitado.");
	    }
		return 1;
	}
	return 0;
}
//====================//
public GostergeYenile()
{
	for(new i=0; i<GetMaxPlayers(); i++)
	{
		if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i) && Gosterge[i] == 1)
		{
		    if(!CallRemoteFunction("IsPlayerInRace", "i", i)){
				TextDrawShowForPlayer(i, Text:ArkaPlan0);
				TextDrawShowForPlayer(i, Text:ArkaPlan1);
				TextDrawShowForPlayer(i, Text:ArkaPlan2);
				TextDrawShowForPlayer(i, Text:ArkaPlan3);
				TextDrawShowForPlayer(i, Text:ArkaPlan4);
				TextDrawShowForPlayer(i, Text:ArkaPlan5);
				TextDrawShowForPlayer(i, Text:ArkaPlan6);

				new HGG[265]; new Float:Can;
				GetVehicleHealth(GetPlayerVehicleID(i), Can);
	   			GetPlayerPos(i,Xa,Ya,Za);
	   			KMH = floatsqroot(floatpower(floatabs(floatsub(Xa,Xb[i])),2)+floatpower(floatabs(floatsub(Ya,Yb[i])),2)+floatpower(floatabs(floatsub(Za,Zb[i])),2));
				KMH *= 14.2;
	   			Yukseklik = Za;
				format(HGG, sizeof(HGG), "~b~~h~~h~Modelo: ~w~%s~n~~g~~h~Velocidade: ~w~%0.0f km/h~n~~n~~y~~h~Nivel do mar: ~w~%.1f m~n~~r~~h~Vida: ~w~%.2f", ArIsim[GetVehicleModel(GetPlayerVehicleID(i))-400], KMH, Yukseklik, Can);
				TextDrawSetString(Text:GostergeYazi[i], HGG);
	            TextDrawShowForPlayer(i, GostergeYazi[i]);

				if(KMH >= 250)
				{
					TextDrawTextSize(Hizg[i],603.000000,0.000000);
				}
				else
				{
					TextDrawTextSize(Hizg[i], floatadd(534.0, floatdiv(KMH, 3.900000)),0.000000);
				}
				TextDrawShowForPlayer(i, Hizg[i]);

				if(Can < 0)
				{
					TextDrawTextSize(Cang[i],538.000000,0.000000);
				}
				else if(Can >= 1000)
				{
					TextDrawTextSize(Cang[i],603.000000,0.000000);
				}
				else
				{
					TextDrawTextSize(Cang[i],floatadd(534.0, floatdiv(Can, 14.6000000)),0.000000);
				}
	  			TextDrawShowForPlayer(i, Cang[i]);
	  			TextDrawShowForPlayer(i, Cizgi);
			}
		}
		else
		{
			TextDrawHideForPlayer(i, Text:GostergeYazi[i]);
			TextDrawHideForPlayer(i, Text:Hizg[i]);
			TextDrawHideForPlayer(i, Text:Cang[i]);
			TextDrawHideForPlayer(i, Text:ArkaPlan0);
			TextDrawHideForPlayer(i, Text:ArkaPlan1);
			TextDrawHideForPlayer(i, Text:ArkaPlan2);
			TextDrawHideForPlayer(i, Text:ArkaPlan3);
			TextDrawHideForPlayer(i, Text:ArkaPlan4);
			TextDrawHideForPlayer(i, Text:ArkaPlan5);
			TextDrawHideForPlayer(i, Text:ArkaPlan6);
			TextDrawHideForPlayer(i, Text:Cizgi);
		}	GetPlayerPos(i,Xb[i],Yb[i],Zb[i]), Xb[i] = Xa; Yb[i] = Ya; Zb[i] = Za;
	}
}
//=================================END========================================//
