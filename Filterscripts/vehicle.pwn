#include <a_samp>

#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x33AA33AA

new curveh[MAX_PLAYERS];
new curveh2[MAX_PLAYERS];
new Float:x,Float:y,Float:z,Float:a, veh;

public OnFilterScriptInit() {
	print("\n--------------------------------------");
	print(" Pasha has created a car spawn fs");
	print("     ADAPTADO POR BLUPONY");
	print("--------------------------------------\n");
	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
    DestroyVehicle(curveh[playerid]);
	curveh[playerid] = 0;
	curveh2[playerid] = 0;
	return 1;
}

//-------------------------------------------------
public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/v", cmdtext, true, 10) == 0)
	{
	    if(CallRemoteFunction("GetGodmodePlayer", "i", playerid) == 0) return SendClientMessage(playerid, COLOR_RED, "Você só pode spawnar carros no modo pacífico");
		if(IsPlayerInAnyVehicle(playerid)) return GameTextForPlayer(playerid, "~r~Saia do veiculo atual!", 5000, 5);
		
		GetPlayerPos(playerid,x,y,z);
		GetPlayerFacingAngle(playerid,a);
		
		ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Vehicles", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle Remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 2009)
	{
		if(response)
		{
			if(listitem == 0)
				ShowPlayerDialog(playerid, 2011, DIALOG_STYLE_LIST, "Aviões", "Shamal\nNevada\nHydra\nStunt Plane\nAndromada\nAt 400\nBeagle\nCrop Duster\nDo-Do\nRustler\nSkimmer", "..::Ok::..", "..::Retornar::..");
			if(listitem == 1)
				ShowPlayerDialog(playerid, 2012, DIALOG_STYLE_LIST, "Helicopteros", "Cargobob\nSparrow\nLeviathon\nPolice helicopter\nNews helicopter\nMaverick\nHunter\nRaindance\nSea Sparrow", "..::Ok::..", "..::Retornar::..");
			if(listitem == 2)
				ShowPlayerDialog(playerid, 2013, DIALOG_STYLE_LIST, "Motos e bikes", "Bike\nBMX\nMountain Bike\nFaggio\nPizza boy\nBF-400\nNRG-500\nPCJ-600\nFCR-900\nCop bike\nFreeway\nWayfarer\nSanchez\nQuad", "..::Ok::..", "..::Retornar::..");
 			if(listitem == 3)
				ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");
 			if(listitem == 4)
				ShowPlayerDialog(playerid, 2015, DIALOG_STYLE_LIST, "Barcos", "Coast guard\nDingy\nSpeeder\nJetmax\nMarquis\nLaunch\nPolice boat\nReefer\nSquallo\nTropic", "..::Ok::..", "..::Retornar::..");
 			if(listitem == 5)
		 		ShowPlayerDialog(playerid, 2057, DIALOG_STYLE_LIST, "Controle remoto", "Bandit\nBaron\nRaider\nGoblin\nTiger\nCam", "..::Ok::..", "..::Retornar::..");
 		}
		return 1;
	}
	if(dialogid == 2057) //veículos RC
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(441,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1){ //rc baron
				if(CallRemoteFunction("GetAdmin", "i", playerid) < 2)
					return SendClientMessage(playerid,COLOR_RED,"Desculpe, este veículo é exclusivo para administradores");

				else veh = CreateVehicle(464,x+1,y+1,z,a,-1,-1,10000);
			}
			if(listitem == 2) veh = CreateVehicle(465,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(501,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(564,x+1,y+1,z,a,-1,-1,10000);
 			if(listitem == 5) veh = CreateVehicle(594,x+1,y+1,z,a,-1,-1,10000);
 			
 			PutPlayerInVehicle(playerid, veh, 0);
 			
 			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);
 			
			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	
	//------------------------------
	if(dialogid == 2012) //helicopteros
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(548,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(469,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(417,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(497,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(488,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(487,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6){ //hunter
				if(CallRemoteFunction("GetAdmin", "i", playerid) < 2)
					return SendClientMessage(playerid,COLOR_RED,"Desculpe, este veículo é exclusivo para administradores");

				else veh = CreateVehicle(425,x+1,y+1,z,a,-1,-1,10000);
			}
			if(listitem == 7) veh = CreateVehicle(563,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(447,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);
			
			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);
			
			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}
		
		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-----------------------------------
	if(dialogid == 2011) //aviões
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(519,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(553,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2){ //hydra
                if(CallRemoteFunction("GetAdmin", "i", playerid) < 2)
					return SendClientMessage(playerid,COLOR_RED,"Desculpe, este veículo é exclusivo para administradores");
				
				else veh = CreateVehicle(520,x+1,y+1,z,a,-1,-1,10000);
			}
			if(listitem == 3) veh = CreateVehicle(513,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(592,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(577,x+1,y+1,z,a,-1,-1,10000);
 			if(listitem == 6) veh = CreateVehicle(511,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(512,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(593,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9){ //rustler
                if(CallRemoteFunction("GetAdmin", "i", playerid) < 2)
					return SendClientMessage(playerid,COLOR_RED,"Desculpe, este veículo é exclusivo para administradores");
				
				else veh = CreateVehicle(476,x+1,y+1,z,a,-1,-1,10000);
			}
			if(listitem == 10) veh = CreateVehicle(460,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);
			
			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");
		
		return 1;
	}
	//-----------------------------------------------------
	if(dialogid == 2013) //bikes
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(509,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(481,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(510,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(462,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(448,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(581,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(522,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(461,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(521,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(523,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(463,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(586,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(468,x+1,y+1,z,a,-1,-1,10000);
 			if(listitem == 13) veh = CreateVehicle(471,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//------------------------------------------------------------------------
	if(dialogid == 2014) //carros
	{
		if(response)
		{
			if(listitem == 0) ShowPlayerDialog(playerid, 2048, DIALOG_STYLE_LIST, "Conversíveis", "Comet(trans.)\nFeltzer(trans.)\nStallion(trans.)\nWindsor(trans.)", "..::Ok::..", "..::Retornar::..");
			if(listitem == 1) ShowPlayerDialog(playerid, 2049, DIALOG_STYLE_LIST, "Industriais", "Benson\nBobcat(trans.)\nBurrito\nBoxville\nBoxburg\nCement Truck\nDFT-30\nFlatbed\nLinerunner\nMule\nNewsvan\nPacker\nPetrol tanker\nPicador(trans.)\nPony\nRoadtrain\nRumpo\nSadler\nSadler-shit\nTopfun\nTractor\nTrashmaster\nUtility Van\nWalton(trans.)\nYankee\nYosemite", "..::Ok::..", "..::Retornar::..");
			if(listitem == 2) ShowPlayerDialog(playerid, 2050, DIALOG_STYLE_LIST, "Low Riders", "Blade(loco.)\nBroadway(loco.)\nRemington(loco.)\nSavanna(loco.)\nSlamvan(loco.)\nTahoma(trans.)\nTornado(loco.)\nVoodoo(loco.)", "..::Ok::..", "..::Retornar::..");
			if(listitem == 3) ShowPlayerDialog(playerid, 2051, DIALOG_STYLE_LIST, "Off-road", "Bandito\nInjection(trans.)\nDune\nHuntley(trans.)\nLandstalker(trans.)\nMesa(trans.)\nMonster\nMonster A\nMonster B\nPatriot\nRancher(trans.)\nRancher 2(trans.)\nSandking", "..::Ok::..", "..::Retornar::..");
		 	if(listitem == 4) ShowPlayerDialog(playerid, 2052, DIALOG_STYLE_LIST, "Serviços Públicos", "Ambulance\nBarracks\nBus\nCabbie(trans.)\nCouch\nCop Bike\nEnforcer\nRancher\nFBI truck\nFiretruck\nFiretruck 2\nLS Police Car\nLV Police Car\nSF Police Car\nRanger\nRhino\nSWAT\nTaxi(trans.)", "..::Ok::..", "..::Retornar::..");
			if(listitem == 5)
			{
				new dialogbox[3200];
				strcat(dialogbox,"Admiral(trans.)\nBlooding Banger\nBravura(trans.)\nBuccaneer(trans.)\nCadrona(trans.)\nClover(trans.)\nElegant(trans.)\nElegy(arch.)\nEmperror(trans.)\nEsperanto(trans.)\nFortune(trans.)\nGlendale-Shit\nGlendale(trans.)\nGreenwood(trans.)\nHermes(trans.)\nIntruder(trans.)\nMajestic(trans.)\n");
				strcat(dialogbox,"Manana(trans.)\nMerit(trans.)\nNebula(trans.)\nOceanic(trans.)\nPremier(trans.)\nPrevio(trans.)\nPrimo(trans.)\nSentinel(trans.)\nStafford(trans.)\nSultan(arch.)\nSunrise(trans.)\nTampa(trans.)\nVincent(trans.)\nVirgo(trans.)\nWillard(trans.)\nWashington(trans.)");
				ShowPlayerDialog(playerid, 2053, DIALOG_STYLE_LIST, "Saloons", dialogbox, "..::Ok::..", "..::Retornar::..");
			}
			if(listitem == 6) ShowPlayerDialog(playerid, 2054, DIALOG_STYLE_LIST, "Esportes", "Alpha(trans.)\nBanshee(trans.)\nBlista compact(trans.)\nBuffalo(trans.)\nBullet(trans.)\nCheetah(trans.)\nClub(trans.)\nEuros(trans.)\nFlash(arch.)\nHotring 1\nHotring 2\nHotring 3\nInfernus(trans.)\nJester(arch.)\nPhoenix(trans.)\nSabre(trans.)\nSuper GT(trans.)\nTurismo(trans.)\nUranus(arch.)\nZR-350(trans.)", "..::Ok::..", "..::Retornar::..");
			if(listitem == 7) ShowPlayerDialog(playerid, 2055, DIALOG_STYLE_LIST, "Wagons", "Moonbeam(trans.)\nPerenniel(trans.)\nRegina(trans.)\nSolair(trans.)\nStratum(trans.)", "..::Ok::..", "..::Retornar::..");
			if(listitem == 8) ShowPlayerDialog(playerid, 2056, DIALOG_STYLE_LIST, "Unicose", "Baggage\nCaddy\nCamper\nCombine Harvester\nDozer\nDumper\nForklift\nHotknife\nHustler(trans.)\nHotdog\nJourney\nKart\nMower\nMr.Whoopee\nRomero(trans.)\nSecuricar\nStretch(trans.)\nSweeper\nTowtruck\nTug\nVortex", "..::Ok::..", "..::Retornar::..");
		}
		
  		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//----------------------------------------------------------------------
	if(dialogid == 2015) //barcos
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(472,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(473,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(452,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(493,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(484,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(595,x+1,y+1,z,a,-1,-1,10000);
 			if(listitem == 6) veh = CreateVehicle(430,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(453,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(446,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(454,x+1,y+1,z,a,-1,-1,10000);

			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}
		
		else ShowPlayerDialog(playerid, 2009, DIALOG_STYLE_LIST, "Veiculos", "{ff0000}Aviões\n{00ff00}Helicopteros\n{0000ff}Motos e bikes\n{00ffff}Carros\n{ff00ff}Barcos\n{00ff00}Controle remoto", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//----------------------------------------------------------------------
	if(dialogid == 2048) //conversíveis
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(480,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(533,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(439,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3)veh = CreateVehicle(555,x+1,y+1,z,a,-1,-1,10000);

			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

  		return 1;
	}
	//------------------------------------------------------------------------
	if(dialogid == 2049) // industriais
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(499,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(422,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(482,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(498,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(609,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(524,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(579,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(455,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(403,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(414,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(582,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(443,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(514,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 13) veh = CreateVehicle(600,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 14) veh = CreateVehicle(413,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 15) veh = CreateVehicle(515,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 16) veh = CreateVehicle(440,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 17) veh = CreateVehicle(543,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 18) veh = CreateVehicle(605,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 19) veh = CreateVehicle(459,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 20) veh = CreateVehicle(531,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 21) veh = CreateVehicle(408,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 22) veh = CreateVehicle(552,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 23) veh = CreateVehicle(478,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 24) veh = CreateVehicle(456,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 25) veh = CreateVehicle(554,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-------------------------------------------------------------------------
	if(dialogid == 2050) //low riders
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(536,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(575,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(534,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(567,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(535,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(566,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(576,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(412,x+1,y+1,z,a,-1,-1,10000);

			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-------------------------------------------------------------------------
	if(dialogid == 2051)//offroad
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(568,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(424,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(574,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(579,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(400,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(500,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(444,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(556,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(557,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(470,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(489,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(505,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(495,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	
	if(dialogid == 2052)
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(416,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(433,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(431,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(438,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(437,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(523,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(427,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(490,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(528,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(407,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(544,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(596,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(598,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 13) veh = CreateVehicle(597,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 14) veh = CreateVehicle(599,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 15){
				if(CallRemoteFunction("GetAdmin", "i", playerid) < 2)
				return SendClientMessage(playerid,COLOR_RED,"Desculpe, este veículo é exclusivo para administradores");
				else veh = CreateVehicle(432,x+1,y+1,z,a,-1,-1,10000);
			}
			if(listitem == 16) veh = CreateVehicle(601,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 17) veh = CreateVehicle(420,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-----------------------------------------------------------------------
	if(dialogid == 2053) //saloons
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(445,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(504,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(401,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(518,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(527,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(542,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(507,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(562,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(585,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(419,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(526,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(604,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(466,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 13) veh = CreateVehicle(492,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 14) veh = CreateVehicle(474,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 15) veh = CreateVehicle(546,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 16) veh = CreateVehicle(517,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 17) veh = CreateVehicle(410,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 18) veh = CreateVehicle(551,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 19) veh = CreateVehicle(516,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 20) veh = CreateVehicle(467,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 21) veh = CreateVehicle(426,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 22) veh = CreateVehicle(436,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 23) veh = CreateVehicle(547,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 24) veh = CreateVehicle(405,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 25) veh = CreateVehicle(580,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 26) veh = CreateVehicle(560,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 27) veh = CreateVehicle(550,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 28) veh = CreateVehicle(549,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 29) veh = CreateVehicle(540,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 30) veh = CreateVehicle(491,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 31) veh = CreateVehicle(529,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 32) veh = CreateVehicle(421,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-------------------------------------------------------------------------
	if(dialogid == 2054) //esportivos
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(602,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(429,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(496,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(402,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(541,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(415,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(589,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(587,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(565,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(494,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(502,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(503,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(411,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 13) veh = CreateVehicle(559,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 14) veh = CreateVehicle(603,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 15) veh = CreateVehicle(475,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 16) veh = CreateVehicle(506,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 17) veh = CreateVehicle(451,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 18) veh = CreateVehicle(558,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 19) veh = CreateVehicle(477,x+1,y+1,z,a,-1,-1,10000);

			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-----------------------------------------------------------------------
	if(dialogid == 2055) //Station Wagons
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(418,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(404,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(479,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(458,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(561,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
	}
	//-------------------------------------------------------------------------
	if(dialogid == 2056) //únicos
	{
		if(response)
		{
			if(listitem == 0) veh = CreateVehicle(485,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 1) veh = CreateVehicle(457,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 2) veh = CreateVehicle(483,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 3) veh = CreateVehicle(532,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 4) veh = CreateVehicle(486,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 5) veh = CreateVehicle(406,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 6) veh = CreateVehicle(530,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 7) veh = CreateVehicle(434,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 8) veh = CreateVehicle(545,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 9) veh = CreateVehicle(588,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 10) veh = CreateVehicle(508,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 11) veh = CreateVehicle(571,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 12) veh = CreateVehicle(572,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 13) veh = CreateVehicle(423,x+1,y+1,z,a,-1,-1,10000);
 			if(listitem == 14) veh = CreateVehicle(442,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 15) veh = CreateVehicle(428,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 16) veh = CreateVehicle(409,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 17) veh = CreateVehicle(574,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 18) veh = CreateVehicle(525,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 19) veh = CreateVehicle(583,x+1,y+1,z,a,-1,-1,10000);
			if(listitem == 20) veh = CreateVehicle(539,x+1,y+1,z,a,-1,-1,10000);
			
			PutPlayerInVehicle(playerid, veh, 0);

			if((CallRemoteFunction("IsVehicleOwned", "d", curveh[playerid]) == 0)) DestroyVehicle(curveh[playerid]);

			curveh[playerid] = GetPlayerVehicleID(playerid);
			curveh2[playerid] = GetVehicleModel(curveh[playerid]);
		}

		else ShowPlayerDialog(playerid, 2014, DIALOG_STYLE_LIST, "Carros", "{ff0000}Conversiveis\n{00ff00}Industriais\n{0000ff}Low Riders\n{00ffff}Off-Road\n{ff00ff}Serviços Públicos\n{ffff00}Saloons\n{ff0000}Esportivos\n{00ff00}Station Wagons\n{0000ff}Unicos", "..::Ok::..", "..::Retornar::..");

		return 1;
		}
		
	
	return 1;
}
