#include <a_samp>
#include <streamer>

#define FILTERSCRIPT

#define COLOR_GREEN 		0xB1FB44FF
#define COLOR_RED 			0xFF444499
#define COLOR_YELLOW 		0xFFFF00AA

#define DM_WORLD 3

// Variáveis globais
new szString[256];
new minigun[MAX_PLAYERS];
new sniperdm[MAX_PLAYERS];
new granadadm[MAX_PLAYERS];
new minigun2[MAX_PLAYERS];
new arenasf[MAX_PLAYERS];
new InDM[MAX_PLAYERS];
new InVDM[MAX_PLAYERS];
new kartdm[MAX_PLAYERS];
new VDMid[MAX_PLAYERS];

//spawns minigun dm--------------------------------------
new Float:MDMSpawns[6][3] = {
	{2205.4531,1613.0443,999.9776},
	{2218.2949,1613.3134,999.9827},
	{2193.5117,1625.7844,999.9706},
	{2181.9653,1577.2335,999.9650},
	{2228.2803,1594.2496,999.9643},
	{2220.1484,1554.7620,1004.7244}
};

//spawn sniper dm-----------------------------------------
new Float:SniperSpawns[11][3] = {
    {-2530.9412,-523.9818,265.7876},
    {-2589.7305,-567.3199,257.5419},
    {-2601.6638,-725.5169,228.8935},
    {-2568.8789,-798.1446,228.8935},
    {-2440.2124,-747.8601,238.1947},
    {-2480.8142,-732.1995,236.2781},
    {-2421.2671,-710.6873,228.8935},
    {-2455.8738,-649.9435,229.0099},
    {-2487.1726,-680.4384,236.0682},
    {-2463.8572,-651.2489,242.6882},
    {-2514.3594,-616.0865,250.2327}
};

//spawns minigun2 -----------------------------------------
new Float:Minigun2Spawns[4][3] = {
	{2092.7363, 2414.1123,74.5786},
	{2069.7498,2370.1726,60.8169},
	{2069.4414,2430.6626,60.8169},
	{2190.3743,2422.5168,73.0313}
};

//spawns arenasf ------------------------------------------
new Float:ArenaSFSpawns[6][3] = {
	{-2103.0073,-88.0013,51.2981},
	{-2188.9685,-253.7428,40.7195},
    {-2081.6448,-258.9894,35.3203},
    {-2074.9548,-112.8710,35.3276},
    {-2191.2454,-205.6593,35.3203},
    {-2018.2070,-275.1939,51.3654}
};

//spawns bate bate -----------------------------------------
new Float:ArenaBateBate[3][3] = {
	{274.3046,1474.3593,10.5859},
	{174.0273,1346.7734,40.4194},
	{282.4561,1400.0699,10.6211}
};

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("       arenas DM by Pony");
	print("--------------------------------------\n");
	
	loadSniperMap();
	loadsfmap();
	loadkartmap();
	
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else
#endif

public OnPlayerConnect(playerid)
{
    InDM[playerid] = 0;
    InVDM[playerid] = 0;
    minigun[playerid] = 0;
    sniperdm[playerid] = 0;
    granadadm[playerid] = 0;
    minigun2[playerid] = 0;
	arenasf[playerid] = 0;
	kartdm[playerid] = 0;
	VDMid[playerid] = -1;
    
    deleteObjects(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(InVDM[playerid] == 1) DestroyVehicle(VDMid[playerid]);
    
	return 1;
}

public OnPlayerSpawn(playerid) //configurações de spawn
{

	if(InDM[playerid] == 1){
	    ResetPlayerWeapons(playerid);
	    //minigun DM
		if(minigun[playerid] == 1) minigunSpawn(playerid);

		//sniper DM
		else if(sniperdm[playerid] == 1) sniperdmSpawn(playerid);
		
		//granada DM
		else if(granadadm[playerid] == 1) granadadmSpawn(playerid);
		
		//minigun2 DM
		else if(minigun2[playerid] == 1) minigun2Spawn(playerid);
		
		//arenasf DM
		else if(arenasf[playerid] == 1) arenasfSpawn(playerid);
		
		
		//DMs com veículo ----------------------------------------
		if(InVDM[playerid] == 1){
		    DestroyVehicle(VDMid[playerid]);
		    //KartDM
		    if(kartdm[playerid] == 1) kartdmSpawn(playerid);
		}
		
		return 1;
 	}
	
	//nenhum DM
	else for(new i = GetPlayerPoolSize(); i != -1; --i) ShowPlayerNameTagForPlayer(playerid, i, true);
	
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new PlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	
	
	//MINIGUN DM ----------------------------------------------
	if (strcmp("/minigun", cmdtext, true, 4) == 0)
	{
	    if(minigun[playerid] == 0 && InDM[playerid] == 0) { //entrada
	        ResetPlayerWeapons(playerid);
	        minigun[playerid] = 1;
			InDM[playerid] = 1;

			SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena minigun. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /minigun novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena minigun (/minigun).", PlayerName, playerid);
	  		SendClientMessageToAll(COLOR_YELLOW, szString);
	  		
	  		minigunSpawn(playerid);
	  		FreezeLoadObjects(playerid); //trava o player enquanto o cenário carrega
		}

		else if(minigun[playerid] == 0 && InDM[playerid] == 1) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena minigun");

		else { //saída
		    minigun[playerid] = 0;
		    exitDM(playerid);
		    
		    SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena minigun.");
		    format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena minigun (/minigun).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
		}
		return 1;
 	}
 	//-------------------------------------------------------------------------------
 	
	//SNIPER DM --------------------------------------------------------------------
	if(!strcmp("/sniperdm", cmdtext, true))
    {
        if(InDM[playerid] == 0 && sniperdm[playerid] == 0){ //entrada
        	ResetPlayerWeapons(playerid);
            InDM[playerid] = 1;
            sniperdm[playerid] = 1;
            
            sniperdmSpawn(playerid);
            FreezeLoadObjects(playerid); //trava o player enquanto o cenário carrega
        	
        	SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena sniper. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /sniperdm novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena sniper (/sniperdm).", PlayerName, playerid);
			
			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
			
        }

		else if(InDM[playerid] == 1 && sniperdm[playerid] == 0) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena sniper");

		else { //saida
            sniperdm[playerid] = 0;
            exitDM(playerid);
            
            SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena sniper.");
            format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena sniper (/sniperdm).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
		}
        return 1;
    }
    //----------------------------------------------------------------------------------------
    
    //GRANADA DM -----------------------------------------------------------------------------
    if(!strcmp("/granadadm", cmdtext, true))
    {
        if(InDM[playerid] == 0 && granadadm[playerid] == 0){ //entrada
            ResetPlayerWeapons(playerid);
            InDM[playerid] = 1;
            granadadm[playerid] = 1;
            
            granadadmSpawn(playerid);
            
            SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena granada. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /granadadm novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena granada (/granadadm).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
   		}
   		
   		else if(InDM[playerid] == 1 && granadadm[playerid] == 0) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena granada");
   		
   		else { //saida
   		    granadadm[playerid] = 0;
            exitDM(playerid);

            SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena granada.");
            format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena granada (/granadadm).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
   		}
		return 1;
    }
    //-----------------------------------------------------------------------------
    
    //MINIGUN2 DM------------------------------------------------------------------
    if(!strcmp("/2minigun", cmdtext, true))
    {
        if(InDM[playerid] == 0 && minigun2[playerid] == 0){ //entrada
        	ResetPlayerWeapons(playerid);
            minigun2[playerid] = 1;

            minigun2Spawn(playerid);
            FreezeLoadObjects(playerid); //trava o player enquanto o cenário carrega

        	SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena minigun 2. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /2minigun novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena minigun 2 (/2minigun).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);

        }

		else if(InDM[playerid] == 1 && minigun2[playerid] == 0) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena minigun2");

		else { //saida
            minigun2[playerid] = 0;
            exitDM(playerid);

            SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena minigun 2.");
            format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena minigun 2 (/2minigun).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
		}
        return 1;
    }
    //-------------------------------------------------------------------------------------------
    //Arena SF ----------------------------------------------------------------------------------
    if(!strcmp("/arenasf", cmdtext, true))
    {
        if(InDM[playerid] == 0 && arenasf[playerid] == 0){ //entrada
        	ResetPlayerWeapons(playerid);
            InDM[playerid] = 1;
            arenasf[playerid] = 1;

            arenasfSpawn(playerid);
            FreezeLoadObjects(playerid); //trava o player enquanto o cenário carrega

        	SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena de San Fierro. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /arenasf novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena de San Fierro (/arenasf).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);

        }

		else if(InDM[playerid] == 1 && arenasf[playerid] == 0) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena de San Fierro");

		else { //saida
            arenasf[playerid] = 0;
            exitDM(playerid);

            SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena de San Fierro.");
            format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena de San Fierro (/arenasf).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
		}
        return 1;
    }
    //-------------------------------------------------------------------------------------------
    //KART DM ----------------------------------------------------------------------------------
    if(!strcmp("/batebate", cmdtext, true))
    {
        if(InDM[playerid] == 0 && kartdm[playerid] == 0){ //entrada
        	ResetPlayerWeapons(playerid);
            InDM[playerid] = 1;
            InVDM[playerid] = 1;
            kartdm[playerid] = 1;

            kartdmSpawn(playerid);
            FreezeLoadObjects(playerid); //trava o player enquanto o cenário carrega

        	SendClientMessage(playerid, COLOR_GREEN, "* Você entrou na arena de kart. Você voltará automaticamente sempre que morrer.");
			SendClientMessage(playerid, COLOR_GREEN, "* Para sair, digite /batebate novamente.");
			format(szString, sizeof(szString), "[DM] %s (ID:%d) foi para a arena de kart (/batebate).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);

        }

		else if(InDM[playerid] == 1 && kartdm[playerid] == 0) SendClientMessage(playerid, COLOR_RED, "Saia do DM atual para entrar na arena dekart");

		else { //saida
            kartdm[playerid] = 0;
            exitDM(playerid);

            SendClientMessage(playerid, COLOR_GREEN, "* Você saiu da arena de kart.");
            format(szString, sizeof(szString), "[DM] %s (ID:%d) saiu da arena de kart (/batebate).", PlayerName, playerid);

			for(new i = 0; i < MAX_PLAYERS; i++)
			    if(IsPlayerConnected(i) && i != playerid) SendClientMessage(i, COLOR_YELLOW, szString);
		}
        return 1;
    }
    //------------------------------------------------------------------------------------------------------------------
	return 0;
}

public OnPlayerUpdate(playerid)
{
    if(InDM[playerid] == 1){
		for(new i = GetPlayerPoolSize(); i != -1; --i){
			SetPlayerMarkerForPlayer(i,playerid,00);
			ShowPlayerNameTagForPlayer(playerid, i, false);
		}
    }
    
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(InVDM[playerid] == 1){
	
	    new Float:X, Float:Y, Float:Z;
	    GetPlayerPos(playerid, X, Y, Z);
	    SetPlayerPos(playerid, X, Y, Z+1);
	    PutPlayerInVehicle(playerid, VDMid[playerid], 0);
	    GameTextForPlayer(playerid, "~r~VOCE NAO PODE SAIR DO VEICULO", 1000, 3);
	    return 1;
	}

	return 0;
}

stock exitDM(playerid){
    InDM[playerid] = 0;
    if(InVDM[playerid] == 1) DestroyVehicle(VDMid[playerid]), VDMid[playerid] = -1;
    
    SetPlayerHealth(playerid, 100);
    SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	SpawnPlayer(playerid);
	ResetPlayerWeapons(playerid);
    
    InVDM[playerid] = 0;
    
	return 1;
}

stock minigunSpawn(playerid){
    SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
    SetPlayerInterior(playerid, 1);
	SetPlayerVirtualWorld(playerid, DM_WORLD);
	new rand = random(sizeof(MDMSpawns));
	SetPlayerPos(playerid, MDMSpawns[rand][0], MDMSpawns[rand][1], MDMSpawns[rand][2]);
	GivePlayerWeapon(playerid, 38, 9999);
	
	return 1;
}

stock sniperdmSpawn(playerid){
	SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
	SetPlayerInterior(playerid, 0);
   	SetPlayerVirtualWorld(playerid, DM_WORLD);
    new rand = random(sizeof(SniperSpawns));
   	SetPlayerPos(playerid, SniperSpawns[rand][0], SniperSpawns[rand][1],SniperSpawns[rand][2]);
   	GivePlayerWeapon(playerid, 34, 9999);
   	
   	return 1;
}

stock granadadmSpawn(playerid){
    SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, DM_WORLD);
	SetPlayerPos(playerid,2479.7864,2318.5823,91.6300);
	GivePlayerWeapon(playerid, 16, 9999);
	
	return 1;
}

stock minigun2Spawn(playerid){
	SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
	SetPlayerInterior(playerid, 0);
   	SetPlayerVirtualWorld(playerid, DM_WORLD);
    new rand = random(sizeof(Minigun2Spawns));
   	SetPlayerPos(playerid, Minigun2Spawns[rand][0], Minigun2Spawns[rand][1], Minigun2Spawns[rand][2]);
   	GivePlayerWeapon(playerid, 38, 9999);

   	return 1;
}

stock arenasfSpawn(playerid){
    SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
	SetPlayerInterior(playerid, 0);
   	SetPlayerVirtualWorld(playerid, DM_WORLD);
    new rand = random(sizeof(ArenaSFSpawns));
   	SetPlayerPos(playerid, ArenaSFSpawns[rand][0], ArenaSFSpawns[rand][1], ArenaSFSpawns[rand][2]);
   	GivePlayerWeapon(playerid, 30, 99999);
   	GivePlayerWeapon(playerid, 34, 99999);
   	GivePlayerWeapon(playerid, 28, 99999);
   	
   	return 1;
}

stock kartdmSpawn(playerid){
    SetPlayerHealth(playerid, 100);
   	SetPlayerArmour(playerid, 100);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, DM_WORLD);
	new rand = random(sizeof(ArenaBateBate));
	SetPlayerPos(playerid,ArenaBateBate[rand][0],ArenaBateBate[rand][1],ArenaBateBate[rand][2]);
	VDMid[playerid] = CreateVehicle(571, ArenaBateBate[rand][0],ArenaBateBate[rand][1],ArenaBateBate[rand][2], 82.2873, -1, -1, 60);
	SetVehicleVirtualWorld(VDMid[playerid], DM_WORLD);
	PutPlayerInVehicle(playerid, VDMid[playerid], 0);

	return 1;
}

stock loadSniperMap(){

	CreateDynamicObject(4867,-2520.92285200,-730.55767800,227.89349400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(4867,-2522.59350600,-567.60510300,235.44043000,5.15662016,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1553,-2510.55957000,-693.44458000,279.78216600,0.00000000,0.00000000,-89.38141604, DM_WORLD);
	CreateDynamicObject(1553,-2510.60937500,-703.66064500,279.77569600,0.00000000,0.00000000,-91.95972612, DM_WORLD);
	CreateDynamicObject(7939,-2464.27929700,-821.65722700,229.44627400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(7939,-2414.82470700,-771.97546400,229.44627400,0.00000000,0.00000000,90.24085273, DM_WORLD);
	CreateDynamicObject(7939,-2415.21484400,-672.67480500,229.44627400,0.00000000,0.00000000,90.24085273, DM_WORLD);
	CreateDynamicObject(5131,-2466.30395500,-661.56518600,234.02446000,0.00000000,0.00000000,-88.52197935, DM_WORLD);
	CreateDynamicObject(5137,-2438.67041000,-683.00311300,232.98397800,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(5137,-2464.53393600,-720.48120100,232.95929000,0.00000000,0.00000000,-180.48176276, DM_WORLD);
	CreateDynamicObject(5309,-2467.85888700,-752.73852500,232.68693500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(5309,-2529.42211900,-714.65936300,232.76191700,0.00000000,0.00000000,-63.59831526, DM_WORLD);
	CreateDynamicObject(5313,-2526.10400400,-625.92901600,240.27156100,0.00000000,0.00000000,270.72261550, DM_WORLD);
	CreateDynamicObject(3399,-2505.60644500,-709.84814500,230.78746000,1.71887339,-20.62648062,0.00000000, DM_WORLD);
	CreateDynamicObject(3399,-2492.84497100,-704.78088400,237.87213100,1.71887339,-20.62648062,111.72677005, DM_WORLD);
	CreateDynamicObject(3399,-2496.07812500,-697.76257300,244.91790800,1.71887339,-20.62648062,125.47781443, DM_WORLD);
	CreateDynamicObject(3399,-2500.84277300,-691.73321500,251.82748400,1.71887339,-20.62648062,139.22891610, DM_WORLD);
	CreateDynamicObject(3399,-2506.44384800,-687.35406500,258.50750700,1.71887339,-20.62648062,148.68277702, DM_WORLD);
	CreateDynamicObject(3399,-2512.81665000,-683.91064500,265.28421000,1.71887339,-20.62648062,163.29331539, DM_WORLD);
	CreateDynamicObject(3399,-2518.35986300,-687.31732200,271.92883300,-4.29718346,-6.87549354,251.81546662, DM_WORLD);
	CreateDynamicObject(3399,-2516.63305700,-693.75500500,275.62838700,-4.29718346,-6.87549354,333.46172325, DM_WORLD);
	CreateDynamicObject(3399,-2514.25317400,-723.68377700,230.48753400,1.71887339,-3.43774677,111.72677005, DM_WORLD);
	CreateDynamicObject(3399,-2518.55175800,-714.54870600,235.13145400,1.71887339,-3.43774677,115.16434493, DM_WORLD);
	CreateDynamicObject(1225,-2485.71142600,-717.63861100,235.68383800,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2447.10498000,-699.14611800,229.42099000,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2456.59960900,-696.93713400,229.42099000,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2456.65600600,-654.90832500,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2442.01684600,-643.10040300,228.89784200,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2438.59033200,-654.50769000,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2514.51001000,-678.17199700,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2535.80200200,-672.54412800,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2520.91406300,-661.52813700,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2505.76123000,-659.22430400,228.29925500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(1225,-2559.24096700,-630.78222700,230.00947600,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2562.99609400,-669.42852800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2569.98730500,-657.83404500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2573.93627900,-650.52600100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2577.38842800,-645.46691900,228.27236900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2577.55615200,-640.71203600,228.70144700,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2581.32275400,-617.05432100,230.83641100,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2572.58544900,-614.64929200,231.05345200,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2560.10595700,-681.69287100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2561.27978500,-702.11914100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2555.24316400,-712.27410900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2548.95288100,-723.06713900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2544.81787100,-734.36334200,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2530.79687500,-751.63446000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2499.16650400,-789.16589400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2505.72631800,-759.72595200,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2460.91162100,-780.81158400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2451.07592800,-803.89147900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2470.13330100,-806.85766600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2507.11035200,-797.94592300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2520.04003900,-773.56073000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2550.39184600,-761.76074200,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2585.89355500,-765.61022900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2580.22729500,-785.81488000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2596.24609400,-802.02807600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2572.84033200,-796.70501700,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2555.71752900,-764.07061800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2587.95361300,-726.39886500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2616.99389600,-716.70990000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2589.11425800,-683.03137200,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2600.44873000,-622.69543500,230.32733200,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2611.98999000,-654.88354500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2586.92089800,-644.16137700,228.39016700,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2575.68774400,-679.38244600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2581.49560500,-689.68463100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2572.23632800,-740.54675300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2567.89868200,-700.68560800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2574.27148400,-708.23559600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2593.31958000,-720.36126700,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2605.39086900,-696.65387000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2603.83520500,-675.86486800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2588.73364300,-661.96637000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2581.95190400,-656.33880600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2593.88916000,-656.00939900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2608.48559600,-669.16961700,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2575.26660200,-664.16656500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2559.56616200,-665.73486300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2559.85180700,-758.08447300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2541.27392600,-756.75116000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2530.49853500,-775.81616200,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2544.69775400,-759.46106000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2565.56567400,-768.27264400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2602.30249000,-784.92675800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2584.75293000,-748.31652800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2579.06005900,-749.75274700,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2581.80542000,-781.16687000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2575.94360400,-781.60022000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2596.77490200,-750.16760300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2601.51220700,-746.17370600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2605.92919900,-740.95092800,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2600.51171900,-722.24829100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2587.97290000,-731.26239000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2582.09277300,-731.72113000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2604.46313500,-773.89740000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2591.46191400,-753.35577400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2529.85986300,-797.03717000,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2531.61425800,-780.94720500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2535.09570300,-818.93078600,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2547.75952100,-776.05743400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2538.85083000,-792.38403300,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2556.17504900,-770.97222900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2560.89086900,-720.29394500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2557.65600600,-729.52130100,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2511.51196300,-671.80511500,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2525.69311500,-669.45013400,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(616,-2520.44848600,-682.10546900,227.88732900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(617,-2447.18823200,-701.91729700,229.00906400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(18228,-2597.92309600,-577.34564200,239.46517900,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(18228,-2528.61401400,-525.30633500,243.06131000,0.00000000,0.00000000,-53.28507495, DM_WORLD);
	CreateDynamicObject(744,-2531.27783200,-760.03454600,227.10444600,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(744,-2566.47460900,-795.84491000,227.07939100,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(744,-2598.79174800,-728.33996600,227.42942800,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(18273,-2489.34912100,-525.70196500,248.22279400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(18273,-2548.58618200,-542.42767300,241.74829100,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(18268,-2592.84985400,-510.24939000,261.04763800,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(16061,-2621.70043900,-797.80688500,226.95585600,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(791,-2449.92919900,-597.70355200,230.79394500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(791,-2441.02832000,-549.31616200,234.55023200,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(791,-2601.14379900,-535.08227500,236.58476300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(791,-2430.91308600,-785.56683300,224.89349400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2451.37207000,-650.37817400,227.98750300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2455.32153300,-643.22021500,228.49809300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2455.36914100,-643.02569600,228.51565600,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2465.29736300,-646.96435500,228.16021700,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2465.70068400,-651.23565700,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2461.81005900,-658.03515600,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2459.91284200,-660.87066700,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2457.71460000,-659.54687500,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2455.45410200,-656.88201900,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2452.63574200,-651.82568400,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2452.44946300,-644.61822500,228.37193300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2453.96728500,-639.90771500,228.79702800,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2459.92822300,-640.54522700,228.73950200,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2466.25317400,-642.51983600,228.56131000,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2467.92334000,-645.38928200,228.30235300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2468.24047900,-648.43927000,228.02711500,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(782,-2467.66333000,-652.77240000,227.91032400,0.00000000,0.00000000,0.00000000, DM_WORLD);
	CreateDynamicObject(17876,-2431.50341800,-640.13586400,236.65434300,0.00000000,0.00000000,0.00000000, DM_WORLD);
	
	return 1;
}

stock loadsfmap()
{
	CreateDynamicObject(944, -2182.66235, -236.74489, 36.31840,   356.85840, 0.00000, -86.85841, DM_WORLD);
	CreateDynamicObject(944, -2142.49414, -234.16611, 36.39840,   356.85840, 0.00000, -267.90521, DM_WORLD);
	CreateDynamicObject(944, -2188.23340, -229.35110, 36.35840,   356.85840, 0.00000, -353.07831, DM_WORLD);
	CreateDynamicObject(3279, -2102.04883, -275.66681, 34.26770,   0.00000, 0.00000, -182.21980, DM_WORLD);
	CreateDynamicObject(3279, -2150.28711, -86.22898, 34.30000,   0.00000, 0.00000, -1.44000, DM_WORLD);
	CreateDynamicObject(3279, -2102.42041, -87.54330, 34.22000,   0.00000, 0.00000, 195.72000, DM_WORLD);
	CreateDynamicObject(936, -2308.29761, -132.81602, 34.78000,   0.00000, 0.00000, 88.62001, DM_WORLD);
	CreateDynamicObject(8613, -2091.84424, -192.66850, 37.35930,   0.00000, 0.00000, 89.34000, DM_WORLD);
	CreateDynamicObject(8613, -2101.06934, -186.13890, 37.35930,   0.00000, 0.00000, 269.34003, DM_WORLD);
	CreateDynamicObject(3279, -2051.36914, -201.01100, 34.17460,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2985, -2102.32983, -87.32280, 50.27360,   0.00000, 0.00000, -279.66000, DM_WORLD);
	CreateDynamicObject(2985, -2150.32886, -86.64310, 50.34920,   0.00000, 0.00000, 130.86000, DM_WORLD);
	CreateDynamicObject(2985, -2102.17603, -275.82541, 50.31610,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3279, -2018.66101, -274.37418, 34.28725,   0.00000, 0.00000, -198.29996, DM_WORLD);
	CreateDynamicObject(2990, -2052.10132, -103.00500, 37.98290,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2990, -2042.13025, -103.03010, 37.98290,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2990, -2032.20752, -103.14384, 37.98290,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2990, -2024.34753, -103.20370, 37.98290,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2990, -2127.23755, -80.98974, 38.04850,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2131.73657, -81.16730, 34.21860,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2122.69214, -81.03471, 34.21860,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3279, -2089.65405, -109.92960, 34.18000,   0.00000, 0.00000, 3.84000, DM_WORLD);
	CreateDynamicObject(3279, -2018.00769, -115.13090, 34.16000,   0.00000, 0.00000, -150.66000, DM_WORLD);
	CreateDynamicObject(19943, -2019.43213, -103.23540, 33.79960,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2029.29565, -103.09045, 33.79960,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2037.20105, -103.01472, 33.79960,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2047.08667, -103.06007, 33.79960,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19943, -2057.26953, -103.05640, 33.89960,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2934, -2033.40149, -120.83533, 35.62420,   0.00000, 0.00000, 43.98000, DM_WORLD);
	CreateDynamicObject(2935, -2029.89673, -110.12618, 35.50420,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3630, -2042.56262, -168.42340, 35.79350,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3630, -2023.40137, -182.76779, 35.79350,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3796, -2058.92603, -170.59770, 34.28000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3796, -2031.94775, -195.06979, 34.30000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3630, -2075.16113, -115.28035, 35.79350,   0.00000, 0.00000, 21.48000, DM_WORLD);
	CreateDynamicObject(3630, -2079.07373, -126.61171, 35.79350,   0.00000, 0.00000, 55.20000, DM_WORLD);
	CreateDynamicObject(2932, -2025.84143, -128.70270, 35.54860,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(2985, -2089.33447, -109.94880, 50.25360,   0.00000, 0.00000, -279.66000, DM_WORLD);
	CreateDynamicObject(2985, -2017.93848, -115.01140, 50.23360,   0.00000, 0.00000, -279.66000, DM_WORLD);
	CreateDynamicObject(3630, -2073.04053, -222.07744, 35.79350,   0.00000, 0.00000, -179.75999, DM_WORLD);
	CreateDynamicObject(3630, -2042.56958, -223.72279, 35.79350,   0.00000, 0.00000, -167.03998, DM_WORLD);
	CreateDynamicObject(3630, -2020.47766, -241.68385, 35.79350,   0.00000, 0.00000, -180.06001, DM_WORLD);
	CreateDynamicObject(3630, -2081.10132, -256.47537, 35.79350,   0.00000, 0.00000, -176.34000, DM_WORLD);
	CreateDynamicObject(2934, -2080.75000, -165.60043, 35.62420,   0.00000, 0.00000, 43.98000, DM_WORLD);
	CreateDynamicObject(2932, -2049.90283, -136.33560, 35.62860,   0.00000, 0.00000, -35.28000, DM_WORLD);
	CreateDynamicObject(2935, -2023.89575, -156.70914, 35.50420,   0.00000, 0.00000, -44.10000, DM_WORLD);
	CreateDynamicObject(3796, -2085.45117, -214.96898, 34.28000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3796, -2061.47827, -220.15384, 34.28000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3796, -2026.75098, -223.75992, 34.28000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3796, -2050.85962, -253.56972, 34.28000,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2095.44360, -244.77190, 34.43310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2095.42554, -245.22801, 34.43310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2095.48682, -245.70932, 34.43310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2085.72559, -254.94841, 34.43310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2085.15942, -254.92250, 34.43310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3014, -2085.43042, -254.40126, 34.51100,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3014, -2094.89941, -244.85670, 34.51100,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3014, -2094.93945, -245.49631, 34.51100,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19589, -2144.54785, -123.45910, 34.27330,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19589, -2140.29004, -107.23771, 34.27330,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19589, -2151.67065, -97.02589, 34.27330,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2147.58325, -112.21288, 34.19480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2143.75146, -112.30330, 34.19480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2151.48389, -111.95705, 34.19480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2149.55127, -111.84100, 36.37480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2145.52100, -112.19910, 36.37480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3799, -2147.59814, -111.99400, 38.53480,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3633, -2124.32495, -113.72360, 34.78930,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3633, -2120.24243, -108.48454, 34.78930,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3633, -2121.54297, -108.57013, 34.78930,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3633, -2125.60767, -113.63956, 34.78930,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3052, -2112.00342, -107.69370, 34.43370,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3052, -2111.99707, -108.20982, 34.43370,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3052, -2111.24316, -107.68271, 34.43370,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3015, -2111.44067, -108.14391, 34.43640,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3014, -2110.88892, -108.17670, 34.48770,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3014, -2111.58691, -108.69470, 34.48770,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3255, -2147.63281, -143.05641, 34.30632,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3255, -2119.04224, -237.93178, 34.30632,   0.00000, 0.00000, 77.69999, DM_WORLD);
	CreateDynamicObject(3630, -2171.06592, -201.14246, 35.74530,   0.00000, 0.00000, 125.63991, DM_WORLD);
	CreateDynamicObject(3630, -2163.30322, -214.94652, 35.74530,   0.00000, 0.00000, -212.57997, DM_WORLD);
	CreateDynamicObject(3630, -2157.89746, -203.76329, 35.74530,   0.00000, 0.00000, 125.63991, DM_WORLD);
	CreateDynamicObject(3630, -2145.78076, -206.80978, 35.74530,   0.00000, 0.00000, 125.63991, DM_WORLD);
	CreateDynamicObject(3630, -2160.71338, -190.53339, 35.74530,   0.00000, 0.00000, 152.15994, DM_WORLD);
	CreateDynamicObject(3630, -2146.66357, -191.51355, 35.74530,   0.00000, 0.00000, 152.15994, DM_WORLD);
	CreateDynamicObject(3415, -2146.85498, -180.18845, 34.32520,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3415, -2130.38110, -189.29712, 34.32520,   0.00000, 0.00000, -60.36000, DM_WORLD);
	CreateDynamicObject(3415, -2127.40674, -208.42392, 34.32520,   0.00000, 0.00000, -60.36000, DM_WORLD);
	CreateDynamicObject(2934, -2105.63770, -103.17157, 35.62420,   0.00000, 0.00000, 62.51998, DM_WORLD);
	CreateDynamicObject(2935, -2111.58765, -91.53039, 35.50420,   0.00000, 0.00000, 58.14002, DM_WORLD);
	CreateDynamicObject(2932, -2118.00830, -102.34780, 35.68860,   0.00000, 0.00000, -106.92000, DM_WORLD);
	CreateDynamicObject(2932, -2123.52954, -133.56570, 35.68860,   0.00000, 0.00000, -106.92000, DM_WORLD);
	CreateDynamicObject(2935, -2104.56958, -129.15021, 35.50420,   0.00000, 0.00000, 58.14002, DM_WORLD);
	CreateDynamicObject(2934, -2110.56201, -138.65739, 35.58420,   0.00000, 0.00000, 62.52000, DM_WORLD);
	CreateDynamicObject(3574, -2128.91113, -153.98430, 36.98730,   0.00000, 0.00000, 100.50000, DM_WORLD);
	CreateDynamicObject(3574, -2118.82275, -261.63254, 36.98730,   0.00000, 0.00000, 100.50000, DM_WORLD);

	return 1;
}

stock loadkartmap()
{
	CreateDynamicObject(19635, 210.09244, 1405.57007, 9.50310,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3578, 123.65516, 1346.20081, 10.31410,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3578, 118.84950, 1351.60718, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.83490, 1361.87488, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 133.88150, 1346.19800, 10.31410,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3578, 144.06894, 1346.17969, 10.31410,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3578, 154.23460, 1346.17627, 10.31410,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(3578, 159.93373, 1351.04419, 10.31410,   0.00000, 0.00000, -93.42001, DM_WORLD);
	CreateDynamicObject(3578, 160.56630, 1361.22461, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 145.67889, 1357.18225, 10.31410,   0.00000, 0.00000, -180.95990, DM_WORLD);
	CreateDynamicObject(3578, 136.15550, 1357.36646, 10.31410,   0.00000, 0.00000, -180.95990, DM_WORLD);
	CreateDynamicObject(3578, 130.90669, 1362.35791, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 131.21159, 1372.65234, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 161.09309, 1370.14661, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 161.69051, 1379.85291, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 162.30090, 1389.94531, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 162.92560, 1400.19006, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 163.56990, 1410.47925, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 164.16830, 1420.71484, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 131.50830, 1382.86255, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 131.77730, 1393.15955, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 132.05910, 1403.43591, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 148.39960, 1376.93506, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 148.70610, 1387.21655, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 149.00540, 1397.51208, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 149.31509, 1407.79419, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 149.59766, 1418.08923, 10.31410,   0.00000, 0.00000, -271.62000, DM_WORLD);
	CreateDynamicObject(3578, 144.51044, 1423.04639, 10.31410,   0.00000, 0.00000, -178.86014, DM_WORLD);
	CreateDynamicObject(3578, 118.83975, 1372.12585, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.83225, 1382.45801, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.82549, 1392.69385, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.81775, 1402.88831, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.81491, 1413.15527, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.79408, 1423.46338, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.79628, 1433.66980, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 118.80259, 1443.81702, 10.31410,   0.00000, 0.00000, -89.88000, DM_WORLD);
	CreateDynamicObject(3578, 120.39395, 1461.14465, 10.31410,   0.00000, 0.00000, -171.59995, DM_WORLD);
	CreateDynamicObject(3578, 130.55461, 1462.67664, 10.31410,   0.00000, 0.00000, -171.59995, DM_WORLD);
	CreateDynamicObject(3578, 140.75569, 1464.20850, 10.31410,   0.00000, 0.00000, -171.59995, DM_WORLD);
	CreateDynamicObject(3578, 150.95732, 1465.57983, 10.31410,   0.00000, 0.00000, -172.49991, DM_WORLD);
	CreateDynamicObject(3578, 115.63820, 1460.41455, 10.31410,   0.00000, 0.00000, -171.59990, DM_WORLD);
	CreateDynamicObject(3578, 164.78130, 1430.99976, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 165.38091, 1441.29541, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 166.00050, 1451.54517, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 166.60240, 1461.79395, 10.31410,   0.00000, 0.00000, -93.42000, DM_WORLD);
	CreateDynamicObject(3578, 161.17880, 1466.26013, 10.31410,   0.00000, 0.00000, -179.70007, DM_WORLD);
	CreateDynamicObject(3578, 144.33723, 1445.93115, 10.31410,   0.00000, 0.00000, -178.86014, DM_WORLD);
	CreateDynamicObject(3578, 135.23248, 1445.86523, 10.31410,   0.00000, 0.00000, -178.86014, DM_WORLD);
	CreateDynamicObject(3578, 130.07248, 1450.72046, 10.31410,   0.00000, 0.00000, -267.96030, DM_WORLD);
	CreateDynamicObject(3578, 135.23248, 1445.86523, 10.31410,   0.00000, 0.00000, -178.86014, DM_WORLD);
	CreateDynamicObject(3578, 149.65489, 1441.31458, 10.31410,   0.00000, 0.00000, -267.96030, DM_WORLD);
	CreateDynamicObject(3578, 148.00755, 1456.90125, 10.31410,   0.00000, 0.00000, -377.46024, DM_WORLD);
	CreateDynamicObject(3578, 129.84131, 1430.09570, 10.31410,   0.00000, 0.00000, -354.06036, DM_WORLD);
	CreateDynamicObject(3578, 158.67636, 1439.29639, 10.31410,   0.00000, 0.00000, -423.06027, DM_WORLD);
	CreateDynamicObject(3578, 139.97112, 1389.99878, 10.31410,   0.00000, 0.00000, -482.58026, DM_WORLD);
	CreateDynamicObject(3578, 125.14186, 1371.22729, 10.31410,   0.00000, 0.00000, -628.67999, DM_WORLD);
	CreateDynamicObject(3578, 158.69662, 1392.19287, 10.31410,   0.00000, 0.00000, -671.52020, DM_WORLD);
	CreateDynamicObject(13593, 152.30438, 1401.25806, 10.25760,   0.00000, 0.00000, -9.12000, DM_WORLD);
	CreateDynamicObject(13593, 137.40161, 1405.95801, 10.25760,   0.00000, 0.00000, -180.53998, DM_WORLD);
	CreateDynamicObject(13593, 129.60114, 1422.52429, 10.25760,   0.00000, 0.00000, -227.39999, DM_WORLD);
	CreateDynamicObject(13593, 122.94340, 1387.68640, 10.25760,   0.00000, 0.00000, -13.19995, DM_WORLD);
	CreateDynamicObject(13593, 145.23865, 1442.14490, 10.25760,   0.00000, 0.00000, -92.21996, DM_WORLD);
	CreateDynamicObject(13593, 153.52966, 1449.70081, 10.25760,   0.00000, 0.00000, 207.35994, DM_WORLD);
	CreateDynamicObject(13604, 258.25229, 1453.12268, 11.20230,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19129, 149.10263, 1344.80701, 9.54770,   0.00000, 0.00000, -2.52000, DM_WORLD);
	CreateDynamicObject(19129, 129.29919, 1345.54358, 9.54770,   0.00000, 0.00000, -1.80000, DM_WORLD);
	CreateDynamicObject(19129, 127.80188, 1359.58777, 9.54770,   0.00000, 0.00000, -1.80000, DM_WORLD);
	CreateDynamicObject(19129, 150.26064, 1364.36938, 9.54770,   0.00000, 0.00000, -3.60000, DM_WORLD);
	CreateDynamicObject(19129, 141.30540, 1364.17041, 9.54770,   0.00000, 0.00000, -3.60000, DM_WORLD);
	CreateDynamicObject(19129, 129.26738, 1370.64063, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(19129, 140.31522, 1382.44202, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(19129, 150.72565, 1383.38269, 9.54770,   0.00000, 0.00000, -4.02000, DM_WORLD);
	CreateDynamicObject(19129, 152.01210, 1384.17590, 9.54770,   0.00000, 0.00000, -4.02000, DM_WORLD);
	CreateDynamicObject(19129, 153.50246, 1403.74878, 9.54770,   0.00000, 0.00000, -4.02000, DM_WORLD);
	CreateDynamicObject(19129, 154.57715, 1421.45227, 9.54770,   0.00000, 0.00000, -4.02000, DM_WORLD);
	CreateDynamicObject(19129, 155.80638, 1440.35950, 9.54770,   0.00000, 0.00000, -4.02000, DM_WORLD);
	CreateDynamicObject(19129, 156.25374, 1455.66785, 9.54770,   0.00000, 0.00000, 0.12001, DM_WORLD);
	CreateDynamicObject(19129, 140.36755, 1453.57593, 9.54770,   0.00000, 0.00000, 8.34000, DM_WORLD);
	CreateDynamicObject(19129, 120.77040, 1450.62915, 9.56770,   0.00000, 0.00000, 7.98000, DM_WORLD);
	CreateDynamicObject(19129, 114.53892, 1444.50403, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 116.73235, 1425.19556, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 120.83425, 1406.55261, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 121.35706, 1386.75586, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 121.61871, 1368.03638, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 121.63941, 1348.18188, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 121.13026, 1345.73804, 9.56770,   0.00000, 0.00000, 0.36000, DM_WORLD);
	CreateDynamicObject(19129, 136.55092, 1401.58984, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(19129, 135.47824, 1420.10181, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(19129, 137.30586, 1435.08850, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(19129, 128.78093, 1435.65308, 9.54770,   0.00000, 0.00000, -0.30000, DM_WORLD);
	CreateDynamicObject(18750, 211.88150, 1408.99622, 40.44450,   88.00000, 0.00000, 180.17999, DM_WORLD);
	CreateDynamicObject(18750, 209.84116, 1406.73840, 40.44450,   88.00000, 0.00000, -2.03999, DM_WORLD);
	CreateDynamicObject(1225, 231.34070, 1461.99475, 1.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 254.46230, 1450.60986, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 254.49428, 1449.64905, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 253.73994, 1450.07971, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 260.23956, 1450.79309, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 260.17844, 1449.79492, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 260.95773, 1450.28357, 9.96790,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(18779, 191.93268, 1340.67017, 19.42720,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(18779, 240.63319, 1352.52576, 19.42720,   0.00000, 0.00000, -180.41980, DM_WORLD);
	CreateDynamicObject(19128, 212.99202, 1343.66675, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 216.97853, 1343.65369, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 219.54919, 1343.66479, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 219.53833, 1347.62598, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 213.03688, 1347.53943, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 213.01448, 1349.69946, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 219.66129, 1349.65051, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 216.51839, 1349.67151, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(19128, 216.32066, 1346.46057, 9.52760,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 146.89221, 1336.47168, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 149.32285, 1339.73523, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 157.20224, 1336.53943, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 153.46899, 1338.71155, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.31796, 1343.44116, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 147.08415, 1342.37061, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 145.07312, 1339.00562, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 141.78178, 1343.26221, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 141.34952, 1339.51831, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.44901, 1338.47205, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.66771, 1342.21741, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 117.89726, 1345.63928, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 117.09482, 1345.26453, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.01437, 1343.62842, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.75243, 1343.92761, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 113.56803, 1344.16125, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.33610, 1344.83362, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 117.87100, 1359.19653, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.98199, 1359.22742, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 115.99757, 1359.25549, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 115.07735, 1359.25378, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.31709, 1366.42017, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 113.41664, 1366.38245, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 114.51681, 1366.38440, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 115.69801, 1366.44580, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 117.85446, 1372.44995, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.72815, 1372.37573, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 115.61943, 1372.26160, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 114.63522, 1372.21912, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 115.00259, 1382.20703, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.39338, 1389.49512, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.97046, 1393.92249, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.09871, 1398.12488, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 113.35244, 1401.02112, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.62213, 1404.51257, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 113.04604, 1407.81055, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.51851, 1412.29126, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.35210, 1413.42859, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 116.68775, 1418.09949, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 112.34662, 1420.23193, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 125.81795, 1419.55652, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 126.92321, 1418.84363, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 127.04688, 1419.90063, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.36066, 1443.17932, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.78230, 1442.01880, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.53241, 1443.80420, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.70917, 1441.83850, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.93573, 1440.76257, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.93573, 1440.76257, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 154.39691, 1446.43542, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 155.01266, 1447.23718, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 155.93420, 1447.67456, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 155.39107, 1446.48657, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.85960, 1404.67004, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 153.50368, 1404.41138, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 152.78882, 1405.45435, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 152.62286, 1403.72217, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 143.94994, 1394.63708, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 143.78798, 1393.66724, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 143.67201, 1395.86511, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 154.52074, 1387.88525, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 154.86374, 1386.99951, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 153.74910, 1387.28955, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 138.39018, 1400.72144, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 136.32422, 1401.73291, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.32005, 1401.97400, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.04956, 1399.27515, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 136.20354, 1385.91357, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.57458, 1384.55737, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 136.71564, 1384.89624, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 123.22099, 1390.91394, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 122.48587, 1390.37573, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.46901, 1389.98853, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 123.65262, 1390.12708, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 148.21729, 1371.09143, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 149.53664, 1371.13757, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 148.83879, 1370.28198, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.65843, 1357.60803, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.68449, 1358.26013, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.20531, 1356.33704, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 129.65512, 1357.33521, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 130.52325, 1356.69165, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 129.67511, 1356.30396, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.80283, 1378.61829, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.11855, 1377.68958, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 125.67655, 1378.03772, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.21017, 1365.97290, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 125.25159, 1365.12317, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 126.18116, 1366.16040, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 138.11021, 1423.46973, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 138.72829, 1422.09180, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 137.83611, 1422.40027, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.52605, 1431.03186, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 123.92945, 1429.26746, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 124.59093, 1428.27551, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 135.61594, 1430.04956, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 136.17081, 1431.22266, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 135.08244, 1431.74902, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 148.87051, 1435.25317, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 159.45172, 1433.85315, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 162.08498, 1435.04419, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 161.54065, 1435.95752, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 159.91757, 1434.68591, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 161.36687, 1433.74426, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.74292, 1435.26343, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 149.84007, 1434.30481, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 150.02798, 1424.45215, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.31079, 1423.85657, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(1225, 151.43324, 1425.04041, 9.96910,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(18983, 282.44229, 1408.37512, 14.59510,   0.00000, 0.00000, 0.84000, DM_WORLD);
	CreateDynamicObject(19633, 216.69460, 1458.53821, 9.56710,   0.00000, 0.00000, 0.00000, DM_WORLD);
	CreateDynamicObject(18778, 121.59277, 1473.68384, 11.05440,   0.00000, 0.00000, -89.04000, DM_WORLD);
	CreateDynamicObject(18778, 129.62109, 1473.74548, 11.05440,   0.00000, 0.00000, -268.98010, DM_WORLD);
	CreateDynamicObject(13593, 145.95979, 1469.89685, 10.20330,   0.00000, 0.00000, -89.52000, DM_WORLD);
	CreateDynamicObject(13593, 163.55869, 1470.60876, 10.20330,   0.00000, 0.00000, -89.52000, DM_WORLD);
	CreateDynamicObject(13593, 163.29358, 1480.31287, 10.20330,   0.00000, 0.00000, -89.52000, DM_WORLD);
	CreateDynamicObject(13593, 154.24365, 1475.62671, 10.20330,   0.00000, 0.00000, -89.52000, DM_WORLD);
	CreateDynamicObject(13593, 145.68034, 1480.59619, 10.20330,   0.00000, 0.00000, -89.52000, DM_WORLD);

	return 1;
}

stock deleteObjects(playerid){
	//arena sf
    RemoveBuildingForPlayer(playerid, 11010, -2113.3203, -186.7969, 40.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 11048, -2113.3203, -186.7969, 40.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 11091, -2133.5547, -132.7031, 36.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 11271, -2127.5469, -269.9609, 41.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 11371, -2028.1328, -111.2734, 36.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 11372, -2076.4375, -107.9297, 36.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 11376, -2144.3516, -132.9609, 38.3359, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -2126.0859, -279.8203, 48.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 11081, -2127.5469, -269.9609, 41.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -2094.3438, -237.4609, 48.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -2097.6797, -178.2344, 48.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 11011, -2144.3516, -132.9609, 38.3359, 0.25);
	RemoveBuildingForPlayer(playerid, 11009, -2128.5391, -142.8438, 39.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -2094.3438, -143.1953, 48.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -2137.6172, -110.9375, 48.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1497, -2029.0156, -120.0625, 34.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 11015, -2028.1328, -111.2734, 36.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 11014, -2076.4375, -107.9297, 36.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1532, -2025.8281, -102.4688, 34.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 1441, -2184.6484, -226.8750, 36.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1449, -2160.6406, -226.3516, 36.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 918, -2182.4453, -237.6953, 35.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 939, -2179.3359, -239.0859, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 942, -2159.0625, -239.0625, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 943, -2156.0703, -227.7500, 36.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 944, -2188.5234, -236.8047, 36.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 942, -2174.8281, -235.5625, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 942, -2140.3359, -229.1484, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 939, -2140.2266, -237.5078, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 944, -2171.1016, -235.7031, 36.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 944, -2145.1641, -234.1719, 36.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 944, -2149.8750, -229.7188, 36.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 942, -2164.2031, -236.0234, 37.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, -2164.2188, -231.1563, 35.5078, 0.25);
	RemoveBuildingForPlayer(playerid, 918, -2148.4922, -230.8047, 35.8750, 0.25);
	RemoveBuildingForPlayer(playerid, 918, -2143.4688, -230.3438, 35.8750, 0.25);
	
	//kartDm
	RemoveBuildingForPlayer(playerid, 3682, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 190.9141, 1371.7734, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 190.9141, 1371.7734, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1392.1563, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1390.5703, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1387.8516, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 203.9531, 1409.9141, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 199.3828, 1407.1172, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 204.6406, 1409.8516, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1404.2344, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1400.6563, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1409.0000, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 16086, 232.2891, 1434.4844, 13.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 183.0391, 1455.7500, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 198.0000, 1462.0156, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.2422, 1460.3203, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.3047, 1461.0078, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 199.5859, 1463.7266, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 181.1563, 1463.7266, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 185.9219, 1462.8750, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 202.3047, 1462.8750, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 189.5000, 1462.8750, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1451.8281, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1454.5469, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1456.1328, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1468.2109, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1464.6328, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 247.5547, 1471.0938, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1472.9766, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.8125, 1473.8281, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.1250, 1473.8906, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 16089, 342.1250, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16090, 315.7734, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16091, 289.7422, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16087, 358.6797, 1430.4531, 11.6172, 0.25);
	RemoveBuildingForPlayer(playerid, 16088, 368.4297, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16092, 394.1563, 1431.0938, 5.2734, 0.25);
	
	return 1;
}

forward FreezeLoadObjects(playerid);
public FreezeLoadObjects(playerid)
{
    TogglePlayerControllable(playerid,0);
    SetTimerEx("UnFreezeLoadObjects",3000,0,"i",playerid);
    GameTextForPlayer(playerid,"~r~CARREGANDO CENARIO",4900,3);
}
forward UnFreezeLoadObjects(playerid);
public UnFreezeLoadObjects(playerid)
{
    TogglePlayerControllable(playerid,1);
    GameTextForPlayer(playerid,"~g~CARREGADO",1000,3);
}

forward getDM(playerid);
public getDM(playerid) return InDM[playerid];
