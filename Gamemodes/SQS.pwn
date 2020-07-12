#include <a_samp>
#include <core>
#include <float>
#include <dof2>

#pragma tabsize 0

#define COLOR_GREY 0xAFAFAFAA
#define ROXO 0xd804d8FF
#define COLOR_DGREEN 0x8FBC8FFF
#define COLOR_BLACK 0x000000FF
#define COLOR_BLUE 0x2641FEAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xFF0000FF
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define INACTIVE_PLAYER_ID 255
#define GIVECASH_DELAY 5000
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2

#define VRESPAWN 120
#define ULTRESPAWN 600

#define NUMVALUES 4

forward Givecashdelaytimer(playerid);
forward SendMSG();
forward PayDay();
forward SetPlayerRandomSpawn(playerid);
forward SetupPlayerForClassSelection(playerid);
forward GameModeExitFunc();
forward SendPlayerFormattedText(playerid, const str[], define);
forward public SendAllFormattedText(playerid, const str[], define);

//------------------------------------------------------------------------------------------------------
new RandomMSG[][] =
{
  "[SERVER] Adicione nosso ip aos favoritos: (em breve)",
  "[SERVER] N�o mate membros do seu time.",
  "[SERVER] Use /ajuda para ver alguns comandos",
  "[SERVER] Est� cansado da Deagle? Use /armas",
  "[SERVER] Utilize /mudar para mudar de time!",
  "[SERVER] N�oo fa�a DB (Drive-BY, Atropelar ou matar alguem de dentro do carro) ou ser� punido!",
  "[SERVER] Se voc� est� num veiculo e a vitima estiver em outro, n�o � drive-by!",
  "[SERVER] Se quiser entrar no modo pac�fico use /godmode",
  "[SERVER] Voc� pode ir para a arena minigun usando /minigun",
  "[SERVER] Voc� pode ir para a arena sniper usando /sniperdm"//,
  //"[SERVER] Voc� pode fazer miss�es dentro do matata, mas cuidado para n�o ser morto!"
};

new RandomColors [] =
{
  0xEEDD82 //Azul Piscina
};

new Text:players;
new iSpawnSet[MAX_PLAYERS];
new pClass[MAX_PLAYERS]; // Stores the player's class
new Text:dTextDraw;
new KillingSpree[MAX_PLAYERS];

new Float:gRandomPlayerSpawns[4][3] = {
{413.513,2533.530,18.668}, // Base Terroristas
{-131.450,1229.313,19.469}, // Base Mercenarios
{693.668,1959.560,5.109}, // Base Vingadores
{-548.710,2593.98,53.483} // Base Agentes
};

new Float:gCopPlayerSpawns[2][3] = {
{2297.1064,2452.0115,10.8203},
{2297.0452,2468.6743,10.8203}

};

enum pInfo {
	pKills,
	pDeaths,
	pMoney,
	pScore,
	pAdmin,
	bool: god
};

new ULT[8];
new pUltVeh[MAX_PLAYERS] = false, pUltVehID[MAX_PLAYERS];
new PlayerInfo[MAX_PLAYERS][pInfo];

new gActivePlayers[MAX_PLAYERS];

//------------------------------------------------------------------------------------------------------

main()
{
		print("\n------------------------------------------------");
		print("              Rodando Sol Quadrado GM");
		print("                     Codado Por");
		print("            Bluepony, com ajuda do forum sa-mp");
		print("-------------------------------------------------\n");
}

//----------------------------------------------------------------------------------------------------

public OnPlayerConnect(playerid) {
    new string[128], Player_Name[MAX_PLAYER_NAME];
    new strings[15];
    new file[64];

	//reset de vi�veis
    KillingSpree[playerid] = 0;
    SetPlayerWantedLevel(playerid,0);
    gActivePlayers[playerid]++;
    SetPVarInt(playerid,"TK",0);
    PlayerInfo[playerid][god] = false;
    pUltVeh[playerid] = false;
    
    //contador de usu�rios ativos
	format(strings, 15, "%d Online",GetOnLinePlayers());
	TextDrawSetString(players, strings);
	TextDrawShowForPlayer(playerid, players);
    
    //sauda��es
	GameTextForPlayer(playerid,"Seja bem vindo ao Sol Quadrado Server",5000,5);
	SendPlayerFormattedText(playerid, "Seja bem vindo, utilize /ajuda para ver os comandos.", 0);
	
    GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
    format(string,256,"==> %s [Id:%i] Entrou no servidor",Player_Name,playerid); SendClientMessageToAll(ROXO,string);

    //sistema de contas
    format(file,sizeof(file),"Accs/%s.ini",Player_Name);
    if(DOF2_FileExists(file)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"Seja bem-viado!","{FFFFFF}Digite sua {00FF22}SENHA {FFFFFF}para entrar","Login","Morrer");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Por favor, registre!","{FFFFFF}Digite sua {00FF22}SENHA {FFFFFF}para se cadastrar.","Cadastro","Morrer");
    }
    
	return 1;
}

//------------------------------------------

public OnPlayerDisconnect(playerid) {
    new strings[15];
    new string[128], Player_Name[MAX_PLAYER_NAME];
    new file[64];
    GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
    
    //update usu�rios online
    gActivePlayers[playerid]--;
	format(strings, 15, "%d Online",GetOnLinePlayers()-1);
	TextDrawSetString(players, strings);
	TextDrawShowForPlayer(playerid, players);
	
	//avisos
    format(string,256,"<== %s [Id:%i] Saiu do servidor",Player_Name,playerid); SendClientMessageToAll(ROXO,string);

	//salva status
    format(file,sizeof(file),"Accs/%s.ini",Player_Name);
    DOF2_SetInt(file, "Kills",PlayerInfo[playerid][pKills]);
    DOF2_SetInt(file, "Deaths",PlayerInfo[playerid][pDeaths]);
    DOF2_SetInt(file, "Money",GetPlayerMoney(playerid));
    DOF2_SetInt(file, "Score",GetPlayerScore(playerid));
    DOF2_SetInt(file, "AdminLevel",PlayerInfo[playerid][pAdmin]);

    DOF2_SaveFile();


    return 0;
}

//------------------------------------------------------------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_REGISTER: { //cria arquivo de conta
            if(!response) Kick(playerid);
            if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Por favor, registre!","{FFFFFF}Digite aqui a sua {00FF22}SENHA {FFFFFF}para se cadastrar.","Cadastrar","Morrer");
            if(response) {
                new file[64], Player_Name[MAX_PLAYER_NAME];
                GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
                format(file,sizeof(file),"Accs/%s.ini",Player_Name);
                DOF2_CreateFile(file, inputtext);
                DOF2_SetInt(file, "Kills", 0);
                DOF2_SetInt(file, "Deaths", 0);
                DOF2_SetInt(file, "Money", 1000);
                DOF2_SetInt(file, "Score", 0);
                DOF2_SetInt(file, "AdminLevel", 0);
				GivePlayerMoney(playerid, 1000);
                DOF2_SaveFile();
            }
        }
        case DIALOG_LOGIN: { //carrega arquivo de conta
            if(!response) Kick(playerid);
            if(response) {
                new file[64], Player_Name[MAX_PLAYER_NAME];
                GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
                format(file,sizeof(file),"Accs/%s.ini",Player_Name);
                if(DOF2_FileExists(file)) {
                    if(DOF2_CheckLogin(file,inputtext)) {
                        PlayerInfo[playerid][pKills] = DOF2_GetInt(file,"Kills");
                        PlayerInfo[playerid][pDeaths] = DOF2_GetInt(file,"Deaths");
                        PlayerInfo[playerid][pMoney] = DOF2_GetInt(file,"Money");
                        PlayerInfo[playerid][pScore] = DOF2_GetInt(file,"Score");
                        PlayerInfo[playerid][pAdmin] = DOF2_GetInt(file,"AdminLevel");
                        GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
                        SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
                        return 1;
                    }
                    else
                    {
                        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"SENHA INCORRETA!","{F81414}Voc� digitou a senha errada\n{FFFFFF}Digite sua senha aqui para entrar!","Login","Morrer");
                        return 1;
                    }
                }
            }
        }
    }
    return 1;
}

//----------------------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(GetPVarInt(playerid,"Morto") == 1)
        return SendClientMessage(playerid,COLOR_RED,"Voc� n�o pode utilizar comandos enquanto est� morto!");
	new string[256];
	new playermoney;
	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];
	new giveplayerid, moneys, idx;
	new cmd[256];
	new Player_Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,Player_Name,sizeof(Player_Name)),

	cmd = strtok(cmdtext, idx);

    //-----------------------------------------------------------
	if(strcmp(cmd, "/ajuda", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - Para ver o objetivo do server, utilize /objetivo");
		SendClientMessage(playerid, COLOR_DGREEN, " - Para ver os comandos do server, utilize /comandos");
		SendClientMessage(playerid, COLOR_DGREEN, " - Para ver as regras do server, utilize /regras");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/comandos", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - AJUDA - /ajuda /comandos /armas /objetivo /regras");
		SendClientMessage(playerid, COLOR_DGREEN, " - ARMAS - /m4 /sniper /deagle /shotgun /mp5 /suprema");
		SendClientMessage(playerid, COLOR_DGREEN, " - JOGADOR - /mudar /allahu /godmode /v / nitro");
		SendClientMessage(playerid, COLOR_DGREEN, " - TELEPORTS - /arena /minigun /sniperdm");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/armas", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - 100 balas de Deagle ($1000) /deagle");
		SendClientMessage(playerid, COLOR_DGREEN, " - 25 balas de Sniper ($5000) /sniper");
		SendClientMessage(playerid, COLOR_DGREEN, " - 100 balas de M4 ($3000) /m4");
		SendClientMessage(playerid, COLOR_DGREEN, " - 100 balas de MP5 ($2000) /mp5");
		SendClientMessage(playerid, COLOR_DGREEN, " - 50 balas de Shotgun ($2000) /shotgun");
		SendClientMessage(playerid, COLOR_DGREEN, " - arma suprema ($1) /suprema");
		SendClientMessage(playerid, COLOR_DGREEN, " - Voc� n�o pode comprar armas no modo pac�fico");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/arena", true) == 0) {
		if(GetPVarInt(playerid,"Arena") == 1) return SendClientMessage(playerid,COLOR_RED,"Voc� ja foi pra arena!");
		if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
		
		SetPVarInt(playerid,"Arena",1);
		SetPlayerPos(playerid,2479.7864,2318.5823,91.6300);
		SetPlayerHealth(playerid, 100);
		GameTextForPlayer(playerid,"~g~Mate ~w~e nao ~r~morra!",3000,5);
  		format(string,128,"[ID:%i] %s Foi para a arena (/arena)",playerid,Player_Name),
   		SendClientMessageToAll(COLOR_DGREEN,string);

		return 1;
    }
    //-----------------------------------------------------------
	if(strcmp(cmd, "/deagle", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=1000) {
        	GivePlayerWeapon(playerid,24,100);
        	GivePlayerMoney(playerid,-1000);
        	format(string,128,"[ID:%i] %s comprou uma Deagle (/deagle)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
   		}
    	else return SendClientMessage(playerid,COLOR_GREY, "Voc� n�o tem nem $1000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/sniper", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=5000) {
        	GivePlayerWeapon(playerid,34,100);
        	GivePlayerMoney(playerid,-5000);
        	SendClientMessage(playerid,COLOR_GREY, "Voc� comprou uma sniper com 100 balas por $5000!");
        	format(string,128,"[ID:%i] %s comprou uma Sniper (/sniper)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Voc� n�o tem nem $5000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/m4", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=3000){
        	GivePlayerWeapon(playerid,31,100);
        	GivePlayerMoney(playerid,-3000);
			SendClientMessage(playerid,COLOR_GREY, "Voc� comprou uma m4 com 100 balas por $3000!");
        	format(string,128,"[ID:%i] %s Comprou uma m4 (/m4)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Voc� n�o tem nem $3000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/mp5", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=2000) {
        	GivePlayerWeapon(playerid,29,100);
        	GivePlayerMoney(playerid,-2000);
  			SendClientMessage(playerid,COLOR_GREY, "Voc� comprou uma mp5 com 100 balas por $2000!");
        	format(string,128,"[ID:%i] %s comprou uma MP5 (/mp5)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
		}
    	else return SendClientMessage(playerid,COLOR_GREY, "Voc� n�o tem nem $2000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/shotgun", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=2000) {
        	GivePlayerWeapon(playerid,25,50);
        	GivePlayerMoney(playerid,-2000);
  			SendClientMessage(playerid,COLOR_GREY, "Voc� comprou uma Shotgun com 50 balas por $2000!");
        	format(string,128,"[ID:%i] %s comprou uma Shotgun (/shotgun)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Voc� n�o tem nem $2000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/suprema", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pac�fico primeiro (/godmode)");
        GivePlayerWeapon(playerid,10,1);
        GivePlayerMoney(playerid,-1);
  		SendClientMessage(playerid,COLOR_GREY, "Voc� comprou a suprema ponta dupla por 1 d�lar");
        format(string,128,"[ID:%i] %s comprou a suprema (/suprema)",playerid,Player_Name),
        SendClientMessageToAll(COLOR_DGREEN,string);
        
        return 0x01;
    }
    
    //-----------------------------------------------------------
	if(strcmp(cmd, "/mudar", true) == 0) {
		PlayerInfo[playerid][god] = false;
	    ForceClassSelection(playerid);
	    SetPlayerHealth(playerid,0);
        format(string,128,"[ID:%i] %s Resolveu mudar de time (/mudar)",playerid,Player_Name),
        SendClientMessageToAll(COLOR_DGREEN,string);

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/objetivo", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - Ap�s escolher um time, voc� deve matar os outros jogadores");
		SendClientMessage(playerid, COLOR_DGREEN, " - Quando voc� mata um jogador voc� ganha 1 de score e $1000 para gastar.");
		SendClientMessage(playerid, COLOR_DGREEN, " - Portanto para ter mais poder de fogo, � necess�rio ter dinheiro. (/armas)");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/regras", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido o uso de: Cheats, Mods CLEO, e outros programas/mods ilegais");
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido DB/Spawn Kill/Heli Kill, PROIBIDO SE MATAR NA ARENA (PULAR DO PREDIO)");
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido Team Kill: Matar jogador do mesmo time! (mesma cor de nick)");
		SendClientMessage(playerid, COLOR_DGREEN, " - Obrigat�rio compartilhar a esposa com todos os outros players.");

		return 1;
	}
	//-----------------------------------------------------------
 	if(strcmp(cmdtext, "/allahu", true) == 0) {
		PlayerInfo[playerid][god] = false;
        new Float:Life, Float:X, Float:Y, Float:Z;
        GetPlayerHealth(playerid,Life);
        GetPlayerPos(playerid, X, Y, Z);
        
        if(Life < 80){
	 		SendClientMessage(playerid,COLOR_RED,"Voc� n�o pode cometer suicidio com a vida baixa.");
	 		PlayerInfo[playerid][god] = true;
	 		return 1;
		}
        
        SetPlayerHealth(playerid,0);
        CreateExplosion(X, Y, Z, 0, 15.0);
        format(string,128,"[ID:%i] %s ganhou 70 virgens (/allahu)",playerid,Player_Name),
        SendClientMessageToAll(COLOR_DGREEN,string);
        PlayerInfo[playerid][god] = false;

		return 1;
    }

	if(strcmp(cmdtext, "/godmode", true) == 0) {
		new Float:Life;
        GetPlayerHealth(playerid,Life);
        
	    if(PlayerInfo[playerid][god] == false){
	        if(Life < 100) return SendClientMessage(playerid,COLOR_RED,"Voc� s� pode entrar no moto pac�fico com a vida cheia.");
	        if(CallRemoteFunction("getDM", "i", playerid) == 1) return SendClientMessage(playerid,COLOR_RED,"Voc� n�o pode entrar no modo pac�fico dentro do DM. Aqui � guerra, rap�!");
	        
	        PlayerInfo[playerid][god] = true;
	        SetPlayerHealth(playerid, Float:0x7F800000);
        	SetPlayerArmour(playerid, 999999);
        	ResetPlayerWeapons(playerid);
        	SendClientMessage(playerid,COLOR_GREEN,"Godmode ativo");
	    } else {
	        PlayerInfo[playerid][god] = false;
	        SetPlayerHealth(playerid, 100);
        	SetPlayerArmour(playerid, 0);
        	ResetPlayerWeapons(playerid);
        	SendClientMessage(playerid,COLOR_RED,"Godmode desativado");
        	GivePlayerWeapon(playerid, 4, 1);
			GivePlayerWeapon(playerid, 30, 500);
			GivePlayerWeapon(playerid, 24,500);
    	}
    	
	    return 1;
	}
    //-----------------------------------------------------------
 	if(strcmp(cmd, "/dargrana", true) == 0) {
	    new tmp[256];
		tmp = strtok(cmdtext, idx);

		if(!strlen(tmp)) return SendClientMessage(playerid, COLOR_GREY, "USE: /dargrana [ID] [QUANTIDADE]");

		giveplayerid = strval(tmp);

		tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, COLOR_GREY, "USE: /dargrana [ID] [QUANTIDADE]");

		moneys = strval(tmp);

		//printf("givecash_command: %d %d",giveplayerid,moneys);
		if (IsPlayerConnected(giveplayerid)) {
			GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
			GetPlayerName(playerid, sendername, sizeof(sendername));
			playermoney = GetPlayerMoney(playerid);
			if (moneys > 0 && playermoney >= moneys) {
				GivePlayerMoney(playerid, (0 - moneys));
				GivePlayerMoney(giveplayerid, moneys);
				format(string, sizeof(string), "Voc� enviou para o jogador %s(ID: %d), $%d.", giveplayer,giveplayerid, moneys);
				SendClientMessage(playerid, COLOR_YELLOW, string);
				format(string, sizeof(string), "Voc� recebeu $%d do jogador %s(ID: %d).", moneys, sendername, playerid);
				SendClientMessage(giveplayerid, COLOR_YELLOW, string);
				printf("%s(playerid:%d) has transfered %d to %s(playerid:%d)",sendername, playerid, moneys, giveplayer, giveplayerid);
			}
			else {
				SendClientMessage(playerid, COLOR_YELLOW, "Transa��o inv�lida.");
			}
		}
		else {
				format(string, sizeof(string), "ID: %d n�o est� online.", giveplayerid);
				SendClientMessage(playerid, COLOR_YELLOW, string);
		}
		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/nitro", true) == 0) {
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);

  		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Voc� precisa estar em um carro.");

   		new vehicleid = GetPlayerVehicleID(playerid);
   		AddVehicleComponent(vehicleid, 1010); // x10 nitro

        PlayerPlaySound(playerid, 1133, X, Y, Z);

   		SendClientMessage(playerid, COLOR_GREEN, "Nitro adicionado!");
		return 1;
	}
	//--------------------------------------------------------

	
	//admin commands
	
	if (PlayerInfo[playerid][pAdmin] > 0 || IsPlayerAdmin(playerid)){ //antes de ler o comando, checa se � adm
	                                        //assim um player normal vai receber a mensagem que o comando n�o existe
        //-----------------------------------------------------------
	    if(strcmp(cmd, "/admin", true) == 0) {
	        if (PlayerInfo[playerid][pAdmin] >= 1){
	            SendClientMessage(playerid, ROXO, "/(des)congelar /limpachat");
	            //comandos level 1
	        }
	        if (PlayerInfo[playerid][pAdmin] >= 2){
	            SendClientMessage(playerid, ROXO, "/goto");
	            //comandos level 2
	        }
	        if (PlayerInfo[playerid][pAdmin] >= 3){
	            SendClientMessage(playerid, ROXO, "");
	            //comandos level 3
	        }
	        return 1;
	    }
	    //-----------------------------------------------------------
		if(strcmp(cmd, "/promover", true) == 0) {
		    if (PlayerInfo[playerid][pAdmin] < 3 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");
		
  			new tmp[256], player2, level;
			tmp = strtok(cmdtext, idx);

			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [LEVEL]");
				return 1;
			}
			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador n�o conectado");

			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [LEVEL]");
				return 1;
			}
			level = strval(tmp);
			if (level < 0 || level > 3) return SendClientMessage(playerid, COLOR_YELLOW, "n�vel inv�lido");
			
			PlayerInfo[player2][pAdmin] = level;
			SendClientMessage(playerid, COLOR_YELLOW, "Voc� alterou o status de admin do jogador");
			SendClientMessage(player2, COLOR_YELLOW, "Seu status de administrador foi alterado");
			return 1;
		}
		//-----------------------------------------------------------
		if(strcmp(cmd, "/congelar", true) == 0) {
		    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");
		    
		    new tmp[256], player2;
			tmp = strtok(cmdtext, idx);
		    
		    if(!strlen(tmp)) return SendClientMessage(playerid, COLOR_GREY, "USE: /congelar [ID]");

			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador n�o conectado");
			TogglePlayerControllable(player2, 0);
			format(string, 46, "O admin %s lhe congelou.", GetPlayerNameEx(playerid));
			SendClientMessage(player2, COLOR_RED, string);
			format(string, 46, "Voc� congelou %s.", GetPlayerNameEx(player2));
			SendClientMessage(playerid, COLOR_RED, string);
			
			return 1;
		}
		//-----------------------------------------------------------
		if(strcmp(cmd, "/descongelar", true) == 0) {
		    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");

		    new tmp[256], player2;
			tmp = strtok(cmdtext, idx);

		    if(!strlen(tmp)) return SendClientMessage(playerid, COLOR_GREY, "USE: /congelar [ID]");

			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador n�o conectado");
			TogglePlayerControllable(player2, 1);
			format(string, 46, "O admin %s lhe descongelou.", GetPlayerNameEx(playerid));
			SendClientMessage(player2, COLOR_RED, string);
			format(string, 46, "Voc� descongelou %s.", GetPlayerNameEx(player2));
			SendClientMessage(playerid, COLOR_RED, string);

			return 1;
		}
		//-----------------------------------------------------------
		if(strcmp(cmd, "/limpachat", true) == 0) {
		    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");
		    
		    for(new i; i < 500; i++)
			{
        		SendClientMessageToAll(-1, "");
    		}
    		SendClientMessageToAll(ROXO, "!!CHAT LIMPO POR UM ADMINISTRADOR!!");
    		
    		return 1;
		}
		//-----------------------------------------------------------
		if(strcmp(cmd, "/goto", true) == 0) {
		    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");
		    
		    new tmp[256], player2;
			tmp = strtok(cmdtext, idx);

		    if(!strlen(tmp)) return SendClientMessage(playerid, COLOR_GREY, "USE: /goto [ID]");

			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador n�o conectado");
			new Float: pX, Float: pY, Float: pZ;
			
			if(IsPlayerInAnyVehicle(playerid))
			{
        		format(string, sizeof(string), "Voc� foi at� %s.", GetPlayerNameEx(player2));
        		SendClientMessage(playerid, COLOR_YELLOW, string);
        		GetPlayerPos(player2, pX, pY, pZ);
        		SetVehiclePos(GetPlayerVehicleID(playerid), pX+1, pY+1, pZ);
        		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(player2));
    		}
    		else {
    		    format(string, sizeof(string), "Voc� foi at� %s", GetPlayerNameEx(player2));
        		SendClientMessage(playerid, COLOR_YELLOW, string);
        		GetPlayerPos(player2, pX, pY, pZ);
        		SetPlayerPos(playerid, pX+1, pY+1, pZ);
        		SetPlayerInterior(playerid, GetPlayerInterior(player2));
    			}
			return 1;
		}
		//-----------------------------------------------------------
	} //fim dos comandos de ADM

	

	return SendClientMessage(playerid,COLOR_YELLOW,"Comando inexistente. Use /ajuda");
}

//------------------------------------------------------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	TogglePlayerClock(playerid,0);
	SetPVarInt(playerid,"Arena",0);
	SetPVarInt(playerid,"Morto",0);
	//SetPVarInt(playerid,"TK",0);

	if(CallRemoteFunction("getDM", "i", playerid) != 1){
	    SetPlayerInterior(playerid,0);
		SetPlayerRandomSpawn(playerid);
		GivePlayerWeapon(playerid, 4, 1);
		GivePlayerWeapon(playerid, 30, 500);
		GivePlayerWeapon(playerid, 24,500);
	
	    switch(pClass[playerid])
	    {
	        //time vermelho
	        case 0: spawnVermelho(playerid);
	        case 1: spawnPolicia(playerid);
	        case 2: spawnPolicia(playerid);
	        case 3: spawnPolicia(playerid);
	        //time azul
	        case 4: spawnAzul(playerid);
	        case 5: spawnPolicia(playerid);
	        case 6: spawnPolicia(playerid);
	        case 7: spawnPolicia(playerid);
	        // time policiais
	        case 8: spawnPolicia(playerid);
	        case 9: spawnPolicia(playerid);
	        case 10: spawnPolicia(playerid);
	        case 11: spawnPolicia(playerid);
	        //time roxo
	        case 12: spawnRoxo(playerid);
	        case 13: spawnRoxo(playerid);
	        case 14: spawnRoxo(playerid);
	        case 15: spawnRoxo(playerid);
        }
	}
	
	//update na per�cia das armas
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 999);
	
	return 1;
}

stock spawnVermelho(playerid){
    SetPlayerColor(playerid, 0xFF0000AA);
    SetPlayerPos(playerid, 693.668,1959.560,5.109);
	SetPlayerFacingAngle(playerid, 180.0);
	
	return 1;
}

stock spawnAzul(playerid){
    SetPlayerColor(playerid, 0x2641FEAA);
	SetPlayerPos(playerid, -131.450,1229.313,19.469);
 	SetPlayerFacingAngle(playerid, 180.0);
 	
	return 1;
}

stock spawnPolicia(playerid){
    SetPlayerColor(playerid, 0xAFAFAFAA);
    SetPlayerPos(playerid, -548.710,2593.98,53.483);
    SetPlayerFacingAngle(playerid, 180.0);
    
	return 1;
}

stock spawnRoxo(playerid){
    SetPlayerColor(playerid, ROXO);
    SetPlayerPos(playerid, 413.513,2533.530,18.668);
    SetPlayerFacingAngle(playerid, 90.0);

	return 1;
}

public SetPlayerRandomSpawn(playerid)
{
	if (iSpawnSet[playerid] == 1)
	{
		new rand = random(sizeof(gCopPlayerSpawns));
		SetPlayerPos(playerid, gCopPlayerSpawns[rand][0], gCopPlayerSpawns[rand][1], gCopPlayerSpawns[rand][2]); // Warp the player
		SetPlayerFacingAngle(playerid, 270.0);
    }
    else if (iSpawnSet[playerid] == 0)
    {
		new rand = random(sizeof(gRandomPlayerSpawns));
		SetPlayerPos(playerid, gRandomPlayerSpawns[rand][0], gRandomPlayerSpawns[rand][1], gRandomPlayerSpawns[rand][2]); // Warp the player
	}
	return 1;
}

//------------------------------------------------------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
    new Player_Name[MAX_PLAYER_NAME], Player_Name2[MAX_PLAYER_NAME];
    new string[64];
    new veiculo, especial = false;
    GetPlayerName(killerid,Player_Name,sizeof(Player_Name));
    GetPlayerName(playerid,Player_Name2,sizeof(Player_Name2));
    
    //Sistema carro ult
    if(pUltVeh[playerid]){
        for(new i = 0; i < 8; i++){
	    	if(pUltVehID[playerid] == ULT[i]){
				veiculo = i;
				especial = true;
				pUltVeh[playerid] = false;
			}
		}
		if(especial){
			SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", veiculo);
    		DestroyVehicle(pUltVehID[playerid]);
		}
	} //precisa ficar no topo pois deve ser processado muito r�pido (antes do client retornar que o jogador morreu)
    
	//reset de vari�veis
	SetPVarInt(playerid,"Morto",1);
    SetPlayerWantedLevel(playerid, 0);
    PlayerInfo[playerid][god] = false;
    
    //update de status
    SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
    PlayerInfo[killerid][pKills]++;
	KillingSpree[killerid]++;
    PlayerInfo[playerid][pDeaths]++;
    GivePlayerMoney(killerid,2000);
    
    //mensagens
	GameTextForPlayer(killerid,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Levou um pra ~p~cova!",5000,3);
	GameTextForPlayer(playerid,"~w~Voce foi pra ~p~cova!",5000,3);
	SendDeathMessage(killerid, playerid, reason);
	new Float:Health;
	GetPlayerHealth(killerid, Health);
	if(Health <= 80 && !PlayerInfo[playerid][god])
	{
    	SetPlayerHealth(killerid, Health + 20);
    	SendClientMessage(killerid,COLOR_WHITE,"Voc� tinha menos que 80 de vida, e ganhou 20!");
	}
	
	//team killing
	if(CallRemoteFunction("getDM", "i", playerid) == 0 && GetPlayerColor(playerid) == GetPlayerColor(killerid)) {
		new Float:x, Float:y, Float:z;
        GetPlayerPos(killerid, x, y, z);
        SetPlayerPos(killerid, x, y, z+200);
        SendClientMessage(killerid, COLOR_RED, "TEAM KILLING � PROIBIDO, MAKAKO.");
        
        if(GetPVarInt(killerid,"TK") == 0) {
            SendClientMessage(killerid, COLOR_RED, "PUNI��O: -$1000 e -5 SCORES");
            SetPlayerScore(killerid,GetPlayerScore(killerid) - 5);
            GivePlayerMoney(killerid,-1000);
        }
        
        if(GetPVarInt(killerid,"TK") == 1) {
            SendClientMessage(killerid, COLOR_RED, "PUNI��O: -200000 -50 SCORES");
            SetPlayerScore(killerid,GetPlayerScore(killerid) - 50);
            GivePlayerMoney(killerid,-200000);
        }
        
        if(GetPVarInt(killerid,"TK") > 1) {
            SendClientMessage(killerid, COLOR_RED,"Voc� foi kikado por cometer Team-Kill 3 vezes.");
            SendClientMessageToAll(COLOR_RED,"O jogador abaixo foi kickado por matar jogadores do mesmo time");
			Kick(killerid);
        }
        
        KillingSpree[killerid] = 0;
        SetPlayerWantedLevel(killerid,0);
        SetPVarInt(killerid,"TK",GetPVarInt(killerid,"TK") + 1);
    }
    
    //killing spree
    if(KillingSpree[killerid] == 3){
		SetPlayerWantedLevel(killerid,1);
		GivePlayerMoney(killerid,500);
		SetPlayerScore(killerid, GetPlayerScore(killerid) + 3);
    	format(string,256,"Killing Spree de %s (ID: %i) (3 kills consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
    }
    if(KillingSpree[killerid] == 5){
        SetPlayerWantedLevel(killerid,2);
        GivePlayerMoney(killerid,1000);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 5);
    	format(string,256,"%s (ID: %i) est� detonando (5 kills consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 7){
        SetPlayerWantedLevel(killerid,3);
        GivePlayerMoney(killerid,1700);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 7);
    	format(string,256,"%s (ID: %i) EST� IMPAR�VEL! (7 kill consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 10){
        SetPlayerWantedLevel(killerid,4);
        GivePlayerMoney(killerid,2500);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 10);
    	format(string,256,"%s (ID: %i) EST� DE HACK?!?!?! (10 KILLS CONSECUTIVAS)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 15){
        SetPlayerWantedLevel(killerid,5);
        GivePlayerMoney(killerid,5000);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 20);
    	format(string,256,"Algu�m reporta o %s (ID: %i). ta cheatado, essa porra. (15 kills consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 20){
        SetPlayerWantedLevel(killerid,6);
        GivePlayerMoney(killerid,10000);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 50);
    	format(string,256,"%s (ID: %i) chegou a 20 kills consecutivas. Quem matar ele ganha $1 milh�o.",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	
   	//recompensa por matar player em killing spree
   	if(KillingSpree[playerid] < 3){}
   	else if(KillingSpree[playerid] < 5) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($2000 + 2 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,2000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 2);
   	}
   	else if(KillingSpree[playerid] < 7) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($3000 + 4 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,3000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 4);
   	}
   	else if(KillingSpree[playerid] < 10) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($5000 + 6 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,5000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 6);
   	}
   	else if(KillingSpree[playerid] < 15) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($10000 + 10 score).",Player_Name2,playerid,Player_Name,killerid);
   		SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,10000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 10);
   	}
   	else if(KillingSpree[playerid] < 20) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($20000 + 20 score).",Player_Name2,playerid,Player_Name,killerid);
   		SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,20000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 20);
   	}
   	else if(KillingSpree[playerid] >= 20) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($1000000 + 100 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,1000000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 100);
   	}
    KillingSpree[playerid] = 0; //n�o ta no reset pq se ficasse no topo ia zuar o sistema de recompensa =C
	
    return 1;

}

//------------------------------------------------------------------------------------------------------

public OnPlayerRequestClass(playerid, classid)
{
	iSpawnSet[playerid] = 0;
	SetupPlayerForClassSelection(playerid);
 	pClass[playerid] = classid;
	TextDrawShowForPlayer(playerid,dTextDraw);
	if(classid == 0) GameTextForPlayer(playerid,"~w~Time ~r~Vermelho",5000,3);
    if(classid == 1) GameTextForPlayer(playerid,"~w~Time ~r~Vermelho",5000,3);
    if(classid == 2) GameTextForPlayer(playerid,"~w~Time ~r~Vermelho",5000,3);
    if(classid == 3) GameTextForPlayer(playerid,"~w~Time ~r~Vermelho",5000,3);
   	if(classid == 4) GameTextForPlayer(playerid,"~w~Time ~b~Azul",5000,3);
   	if(classid == 5) GameTextForPlayer(playerid,"~w~Time ~b~Azul",5000,3);
   	if(classid == 6) GameTextForPlayer(playerid,"~w~Time ~b~Azul",5000,3);
   	if(classid == 7) GameTextForPlayer(playerid,"~w~Time ~b~Azul",50000,3);
   	if(classid == 8) GameTextForPlayer(playerid,"~w~Time dos ~g~Policiais",5000,3);
   	if(classid == 9) GameTextForPlayer(playerid,"~w~Time dos ~g~Policiais",5000,3);
   	if(classid == 10) GameTextForPlayer(playerid,"~w~Time dos ~g~Policiais",5000,3);
   	if(classid == 11) GameTextForPlayer(playerid,"~w~Time dos ~g~Policiais",5000,3);
   	if(classid == 12) GameTextForPlayer(playerid,"~w~Time ~p~Roxo",5000,3);
   	if(classid == 13) GameTextForPlayer(playerid,"~w~Time ~p~Roxo",5000,3);
	if(classid == 14) GameTextForPlayer(playerid,"~w~Time ~p~Roxo",5000,3);
	if(classid == 15) GameTextForPlayer(playerid,"~w~Time ~p~Roxo",5000,3);
	
    return 1;
}

//------------------------------------------------------------------------------------------------------

public SetupPlayerForClassSelection(playerid)
{
 	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,-371.5435,2134.4326,133.1797);
	SetPlayerFacingAngle(playerid, 179.0);
	SetPlayerCameraPos(playerid,-371.5435,2127.4326,140.1797);
	SetPlayerCameraLookAt(playerid,-371.5435,2134.4326,133.1797);
}

public GameModeExitFunc()
{
	GameModeExit();

	TextDrawHideForAll(players);
	TextDrawDestroy(players);

    DOF2_Exit();
	return 1;
}

public OnGameModeInit()
{
	//jogadores online na tela
	players = TextDrawCreate(54.000000, 326.000000, "_");
	TextDrawBackgroundColor(players, 255);
	TextDrawFont(players, 2);
	TextDrawLetterSize(players, 0.500000, 1.000000);
	TextDrawColor(players, -65281);
	TextDrawSetOutline(players, 1);
	TextDrawSetProportional(players, 1);

	for(new i; i < MAX_PLAYERS; i ++)
	{
		if(IsPlayerConnected(i))
		{
			TextDrawShowForPlayer(i, players);
		}
	}
	SetGameModeText("SQS2");
	SetTimer("SendMSG", 60000, true);
	SetTimer("PayDay", 600000, true); // 11 minutos
	SendRconCommand("mapname San Andreas");

	ShowPlayerMarkers(1);
	UsePlayerPedAnims();
	ShowNameTags(1);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);

	// Player Class's
	AddPlayerClass(19,2512.8611,-1673.2799,13.5104,87.7485,0,0,0,0,0,0); // Class 0 Vermelho
    AddPlayerClass(40,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 1 Vermelho
    AddPlayerClass(170,2512.8611,-1673.2799,13.5104,87.7485,0,0,0,0,0,0); // Class 2 Vermelho
    AddPlayerClass(190,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 3 Vermelho
    AddPlayerClass(69,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 4 Azul
    AddPlayerClass(84,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 5 Azul
    AddPlayerClass(177,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 6 Azul
    AddPlayerClass(41,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 7 Azul
    AddPlayerClass(285,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 8 Pol�cia
    AddPlayerClass(284,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 9 Pol�cia
    AddPlayerClass(280,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 10 Pol�cia
    AddPlayerClass(287,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 11 Pol�cia
    AddPlayerClass(228,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 12 Roxo
    AddPlayerClass(217,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 13 Roxo
    AddPlayerClass(211,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 14 Roxo
    AddPlayerClass(169,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 15 Roxo

	// Base roxa

	AddStaticVehicleEx(411,390.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,385.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,380.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,375.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,370.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,365.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,360.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,355.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,350.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(411,345.748,2541.178,16.059,180.000,211,149,VRESPAWN);
	AddStaticVehicleEx(487,365.059,2466.570,16.211,0.000,211,1,VRESPAWN);
	AddStaticVehicleEx(487,340.059,2466.570,16.211,0.000,211,1,VRESPAWN);
	AddStaticVehicleEx(522,418.189,2531.904,16.319,180.000,211,1,VRESPAWN);
	AddStaticVehicleEx(522,420.189,2531.904,16.319,180.000,211,1,VRESPAWN);
	AddStaticVehicleEx(522,422.189,2531.904,16.319,180.000,211,1,VRESPAWN);
	AddStaticVehicleEx(522,424.189,2531.904,16.319,180.000,211,1,VRESPAWN);
	AddStaticVehicleEx(522,426.189,2531.904,16.319,180.000,211,1,VRESPAWN);


	// Base azul

	AddStaticVehicleEx(522,-177.707,1225.307,19.469,270.000,79,79,VRESPAWN);
	AddStaticVehicleEx(522,-177.707,1222.307,19.469,270.000,79,79,VRESPAWN);
	AddStaticVehicleEx(522,-177.707,1219.307,19.469,270.000,79,79,VRESPAWN);
	AddStaticVehicleEx(522,-177.707,1216.307,19.469,270.000,79,79,VRESPAWN);
	AddStaticVehicleEx(522,-177.707,1213.307,19.469,270.000,79,79,VRESPAWN);
	AddStaticVehicleEx(402,-158.171,1229.100,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(415,-163.171,1229.100,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(424,-168.171,1229.100,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(429,-134.379,1217.458,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(439,-139.379,1217.458,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(451,-144.379,1217.458,19.469,180.000,79,79,VRESPAWN);
	AddStaticVehicleEx(477,-149.379,1217.458,19.469,180.000,79,79,VRESPAWN);

	// Base vermelha

	AddStaticVehicleEx(522,730.545,1949.693,5.103,180.000,1,3,VRESPAWN);
	AddStaticVehicleEx(522,726.545,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(402,721.664,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(415,716.230,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(424,711.663,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(429,706.816,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(522,701.105,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(522,696.453,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(439,691.637,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(451,686.793,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(477,681.548,1949.693,5.103,180.000,3,3,VRESPAWN);
	AddStaticVehicleEx(522,676.445,1949.693,5.103,180.000,3,3,VRESPAWN);

	// Base policia

	AddStaticVehicleEx(523,-527.113,2579.040,52.984,90.000,11,11,VRESPAWN); // HPV 1000
	AddStaticVehicleEx(523,-527.113,581.454,52.984,90.000,11,11,VRESPAWN); // HPV 1000
	AddStaticVehicleEx(523,-527.113,2576.397,52.984,90.000,11,11,VRESPAWN); // HPV 1000
	AddStaticVehicleEx(523,-527.113,2573.866,52.984,90.000,11,11,VRESPAWN); // HPV 1000
	AddStaticVehicleEx(523,-527.113,2571.356,52.984,90.000,11,11,VRESPAWN); // HPV 1000
	AddStaticVehicleEx(598,-529.922,2563.687,52.979,90.000,11,11,VRESPAWN); // LVPD
	AddStaticVehicleEx(598,-529.992,2558.218,52.979,90.000,11,11,VRESPAWN); // LVPD
	AddStaticVehicleEx(598,-521.068,2559.008,52.978,270.000,11,11,VRESPAWN); // LVPD
	AddStaticVehicleEx(598,-521.068,2564.219,52.979,270.000,11,11,VRESPAWN); // LVPD
	AddStaticVehicleEx(598,-521.068,2569.458,52.979,270.000,11,11,VRESPAWN); // LVPD
	AddStaticVehicleEx(528,-519.800,2577.061,52.985,270.000,11,11,VRESPAWN); // FBI
	AddStaticVehicleEx(528,-519.800,2582.120,52.985,270.000,11,11,VRESPAWN); // FBI
	AddStaticVehicleEx(470,-538.258,2603.697,52.980,270.000,11,11,VRESPAWN); // Patriot
	AddStaticVehicleEx(470,-538.258,2608.662,52.980,270.000,11,11,VRESPAWN); // Patriot
	AddStaticVehicleEx(470,-538.258,2613.509,52.980,270.000,11,11,VRESPAWN); // Patriot
	AddStaticVehicleEx(470,-538.258,2618.340,52.980,270.000,11,11,VRESPAWN); // Patriot
	AddStaticVehicleEx(470,-538.258,2623.540,52.980,270.000,11,11,VRESPAWN); // Patriot
	AddStaticVehicleEx(497,-510.126,2632.243,52.979,90.000,11,11,VRESPAWN); // Heli
	AddStaticVehicleEx(497,-511.969,2605.545,52.980,90.000,11,11,VRESPAWN); // Heli

	// Carros espalhados

    AddStaticVehicleEx(568,9.2662,1231.0234,18.9078,89.6072,1,1,VRESPAWN); //
	AddStaticVehicleEx(424,16.2422,1166.0085,19.1346,0.1662,2,2,VRESPAWN); //
	AddStaticVehicleEx(495,18.4716,1353.1819,8.7386,23.3455,3,3,VRESPAWN); //
	AddStaticVehicleEx(505,-34.4963,1377.6820,8.8819,141.9388,4,4,VRESPAWN); //
	AddStaticVehicleEx(403,-100.1622,1380.6021,9.8428,105.4320,5,5,VRESPAWN); //
	AddStaticVehicleEx(413,-89.2076,1535.0980,16.1564,35.0308,6,6,VRESPAWN); //
	AddStaticVehicleEx(421,-165.2876,1676.9580,14.3540,19.4646,7,7,VRESPAWN); //
	AddStaticVehicleEx(422,-57.6921,1841.9924,17.1237,74.9541,8,8,VRESPAWN); //
	AddStaticVehicleEx(426,-231.4026,2042.8424,28.7066,347.3830,9,9,VRESPAWN); //
	AddStaticVehicleEx(434,-38.0279,2236.6855,37.8787,309.6378,10,10,VRESPAWN); //
	AddStaticVehicleEx(463,-22.2527,2333.0918,23.7102,5.7975,11,11,VRESPAWN); //
	AddStaticVehicleEx(471,-241.0324,2595.2539,62.2753,358.2202,12,12,VRESPAWN); //
	AddStaticVehicleEx(568,-204.4339,2595.8342,62.2612,358.0206,13,13,VRESPAWN); //
	AddStaticVehicleEx(424,-223.0472,2770.4795,62.2559,179.0655,14,14,VRESPAWN); //
	AddStaticVehicleEx(495,-275.9200,2718.8606,62.1983,6.1004,15,15,VRESPAWN); //
	AddStaticVehicleEx(505,-600.7001,2701.3452,71.8574,115.1483,16,16,VRESPAWN); //
	AddStaticVehicleEx(413,-682.1919,2705.9470,69.1983,147.5775,17,17,VRESPAWN); //
	AddStaticVehicleEx(403,-767.0948,2760.2974,45.3398,180.6232,18,18,VRESPAWN); //
	AddStaticVehicleEx(421,-840.2679,2742.2256,45.3325,183.0326,19,19,VRESPAWN); //
	AddStaticVehicleEx(422,-1316.2272,2696.1790,49.6391,118.6256,20,20,VRESPAWN); //
	AddStaticVehicleEx(426,-1399.9670,2640.6926,55.2526,85.5841,21,21,VRESPAWN); //
	AddStaticVehicleEx(434,-1401.2579,2656.4988,55.2537,86.8121,22,22,VRESPAWN); //
	AddStaticVehicleEx(463,-1506.9604,2525.9380,55.2563,0.3813,23,23,VRESPAWN); //
	AddStaticVehicleEx(471,-1526.2809,2638.7605,55.3870,96.9867,24,24,VRESPAWN); //

	//ve�culos ultimate
	ULT[0] = CreateVehicle(520,713.718,1914.857,6.257,180.343,0,0,ULTRESPAWN);
	ULT[1] = CreateVehicle(432,678.759,1934.412,5.555,270.479,0,0,ULTRESPAWN);
	ULT[2] = CreateVehicle(520,-145.799,1181.259,20.474,90.328,0,0,ULTRESPAWN);
	ULT[3] = CreateVehicle(432,-145.360,1205.197,19.668,268.878,43,0,ULTRESPAWN);
	ULT[4] = CreateVehicle(520,-501.372,2579.333,54.282,357.486,0,0,ULTRESPAWN);
	ULT[5] = CreateVehicle(432,-501.697,2604.585,53.632,177.447,43,0,ULTRESPAWN);
	ULT[6] = CreateVehicle(520,325.099,2538.880,17.527,178.709,0,0,ULTRESPAWN);
	ULT[7] = CreateVehicle(432,291.4309,2539.1721,16.8295,180.2851,43,0,ULTRESPAWN);

	return 1;
}

public SendMSG()
{
	new random2 = random(sizeof(RandomColors));
 	new randMSG = random(sizeof(RandomMSG));
 	SendClientMessageToAll(RandomColors[random2], RandomMSG[randMSG]);
}

public PayDay()
{
	for(new i=0; i<=MAX_PLAYERS; i++) GivePlayerMoney(i, 10000);
	SendClientMessageToAll(COLOR_RED, "B�nus por ficar online: $10000");
}

public SendPlayerFormattedText(playerid, const str[], define)
{
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessage(playerid, 0xFF004040, tmpbuf);
}

public SendAllFormattedText(playerid, const str[], define)
{
	new tmpbuf[256];
	format(tmpbuf, sizeof(tmpbuf), str, define);
	SendClientMessageToAll(0xFFFF00AA, tmpbuf);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new caradress;
	new especial = false;
	for(new i = 0; i < 8; i++){
	    if(vehicleid == ULT[i]){
			caradress = i;
            pUltVeh[playerid] = true;
            pUltVehID[playerid] = vehicleid;
            especial = true;
		}
	}
	if(especial){
		if(caradress == 0 || caradress == 1){
		    if(GetPlayerColor(playerid) != 0xFF0000AA){
		        SendClientMessageToAll(COLOR_RED,"Um ve�culo ultimate da equipe VERMELHA foi destru�do por um jogador rival");
		        SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", caradress);
	    		DestroyVehicle(vehicleid);
	    		pUltVeh[playerid] = false;
		    }
		}
		else if(caradress == 2 || caradress == 3){
	 	   if(GetPlayerColor(playerid) != 0x2641FEAA){
		        SendClientMessageToAll(COLOR_BLUE,"Um ve�culo ultimate da equipe AZUL foi destru�do por um jogador rival");
		        SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", caradress);
	    		DestroyVehicle(vehicleid);
	    		pUltVeh[playerid] = false;
		    }
		}
	    else if(caradress == 4 || caradress == 5){
	 	   if(GetPlayerColor(playerid) != 0xAFAFAFAA){
		        SendClientMessageToAll(COLOR_GREEN,"Um ve�culo ultimate dos  POLICIAIS foi destru�do por um jogador rival");
		        SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", caradress);
	    		DestroyVehicle(vehicleid);
	    		pUltVeh[playerid] = false;
		    }
		}
	    else if(caradress == 6 || caradress == 7){
	 	   if(GetPlayerColor(playerid) != ROXO){
		        SendClientMessageToAll(ROXO,"Um ve�culo ultimate da equipe ROXA foi destru�do por um jogador rival");
		        SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", caradress);
	    		DestroyVehicle(vehicleid);
	    		pUltVeh[playerid] = false;
		    }
		}
	}
	
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	new veiculo;
	new especial = false;
	
	if(pUltVeh[playerid]){
		for(new i = 0; i < 8; i++){
	    	if(vehicleid == ULT[i]){
				veiculo = i;
				especial = true;
			}
		}
	}
	
	if(!especial) return 1;

    SetTimerEx("vehicleRespawn", ULTRESPAWN*1000, false, "i", veiculo);
    DestroyVehicle(vehicleid);
    pUltVeh[playerid] = false;
    
    return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
 	new especial = false, veiculo;
 	
 	if(hittype == 2){
 	    for(new i = 0; i < 8; i++){
 	        if(hitid == ULT[i]){
 	            especial = true;
 	            veiculo = ULT[i];
 	        }
 	    }
 	}
 	
	if(especial && weaponid == 34){
	    new Float:x, Float:y, Float:z;
	    GetVehiclePos(veiculo, x, y, z);
    	CreateExplosion(x, y, z, 0, 10.1);
    }

    return 1;
}

public OnPlayerText(playerid, text[])
{
    new pText[144];
    new pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

	format(pText, sizeof(pText), "{%06x}%s(id: %i): {FFFFFF}%s", GetPlayerColor(playerid) >>> 8, pName, playerid, text);
    SendClientMessageToAll(-1, pText);

    return 0;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart) {

    if(issuerid != INVALID_PLAYER_ID && weaponid == 34 && bodypart == 9){
		SetPlayerHealth(playerid, 0.0);
		SendClientMessage(issuerid, COLOR_RED, "[HEADSHOT] +5 scores");
		SetPlayerScore(issuerid, GetPlayerScore(issuerid) + 4);
	}
    return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}


stock GetOnLinePlayers()
{
	new OnLine;
	for(new i, g = GetMaxPlayers(); i < g; i++)
		if(IsPlayerConnected(i))
			OnLine++;
	return OnLine;
}

stock GetPlayerNameEx(playerid)
{
	new Naome[24];
	GetPlayerName(playerid, Naome, 24);
	return Naome;
}

forward GetAdmin(playerid);
public GetAdmin(playerid) return PlayerInfo[playerid][pAdmin];

forward GetGodmodePlayer(playerid);
public GetGodmodePlayer(playerid) return PlayerInfo[playerid][god];

forward vehicleRespawn(veiculo);
public vehicleRespawn(veiculo)
{
	if(veiculo == 0){ //hydra vermelho
		ULT[0] = CreateVehicle(520,713.718,1914.857,6.257,180.343,0,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_RED,"Hydra da equipe vermelha renasceu");
	}
	else if(veiculo == 1){ //rhino vermelho
		ULT[1] = CreateVehicle(432,678.759,1934.412,5.555,270.479,0,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_RED,"Rhino da equipe vermelha renasceu");
	}
	else if(veiculo == 2){ //hydra azul
		ULT[2] = CreateVehicle(520,-145.799,1181.259,20.474,90.328,0,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_BLUE,"Hydra da equipe azul renasceu");
	}
	else if(veiculo == 3){ //rhino azul
		ULT[3] = CreateVehicle(432,-145.360,1205.197,19.668,268.878,43,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_BLUE,"Rhino da equipe azul renasceu");
	}
	else if(veiculo == 4){ //hydra policia
		ULT[4] = CreateVehicle(520,-501.372,2579.333,54.282,357.486,0,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_GREEN,"Hydra dos policiais renasceu");
	}
	else if(veiculo == 5){ //rhino policia
		ULT[5] = CreateVehicle(432,-501.697,2604.585,53.632,177.447,43,0,ULTRESPAWN);
		SendClientMessageToAll(COLOR_GREEN,"Rhino dos policiais renasceu");
	}
	else if(veiculo == 6){ //hydra roxo
		ULT[6] = CreateVehicle(520,325.099,2538.880,17.527,178.709,0,0,ULTRESPAWN);
		SendClientMessageToAll(ROXO,"Hydra da equipe roxa renasceu");
	}
	else if(veiculo == 7){
		ULT[7] = CreateVehicle(432,291.4309,2539.1721,16.8295,180.2851,43,0,ULTRESPAWN);
		SendClientMessageToAll(ROXO,"Rhino da equipe roxa renasceu");
	}
	
    return 1;
}
