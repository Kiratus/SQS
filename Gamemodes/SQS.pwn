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
  "[SERVER] Não mate membros do seu time.",
  "[SERVER] Use /ajuda para ver alguns comandos",
  "[SERVER] Está cansado da Deagle? Use /armas",
  "[SERVER] Utilize /mudar para mudar de time!",
  "[SERVER] Não faça DB (Drive-BY, Atropelar ou matar alguem de dentro do carro) ou será punido!",
  "[SERVER] Se você está num veiculo e a vitima estiver em outro, não é drive-by!",
  "[SERVER] Se quiser entrar no modo pacífico use /godmode" /*,
  "[SERVER] Você pode fazer missões dentro do matata, mas cuidado para não ser morto!"*/
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
	pVip,
	bool: god
};

new PlayerInfo[MAX_PLAYERS][pInfo];

/* //Round code stolen from mike's Manhunt :P
new gRoundTime = 3600000;                   // Round time - 1 hour
new gRoundTime = 1200000;					// Round time - 20 mins
new gRoundTime = 900000;					// Round time - 15 mins
new gRoundTime = 600000;					// Round time - 10 mins
new gRoundTime = 300000;					// Round time - 5 mins
new gRoundTime = 120000;					// Round time - 2 mins
new gRoundTime = 60000;					// Round time - 1 min */

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

	//reset de variáveis
    KillingSpree[playerid] = 0;
    SetPlayerWantedLevel(playerid,0);
    gActivePlayers[playerid]++;
    SetPVarInt(playerid,"TK",0);
    PlayerInfo[playerid][god] = false;
    
    //contador de usuários ativos
	format(strings, 15, "%d Online",GetOnLinePlayers());
	TextDrawSetString(players, strings);
	TextDrawShowForPlayer(playerid, players);
    
    //saudações
	GameTextForPlayer(playerid,"Seja bem vindo ao Sol Quadrado Server",5000,5);
	SendPlayerFormattedText(playerid, "Seja bem vindo, utilize /ajuda para ver os comandos.", 0);
	
    GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
    format(string,256,"==> %s [Id:%i] Entrou no servidor",Player_Name,playerid); SendClientMessageToAll(ROXO,string);
    
    //sistema de contas
    format(Player_Name,sizeof(Player_Name),DOF2_File(Player_Name));
    if(DOF2_FileExists(Player_Name)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"Seja bem-viado!","{FFFFFF}Digite sua {00FF22}SENHA {FFFFFF}para entrar","Login","Morrer");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Por favor, registre!","{FFFFFF}Digite sua {00FF22}SENHA {FFFFFF}para se cadastrar.","Cadastro","Morrer");
    }
    
	return 1;
}

//------------------------------------------

public OnPlayerDisconnect(playerid) {
    new strings[15];
    new file[64];
    new string[128], Player_Name[MAX_PLAYER_NAME];
    
    //update usuários online
	format(strings, 15, "%d Online",GetOnLinePlayers());
	TextDrawSetString(players, strings);
	TextDrawShowForPlayer(playerid, players);
	gActivePlayers[playerid]--;
	
	//avisos
    GetPlayerName(playerid,Player_Name,sizeof(Player_Name));
    format(string,256,"==> %s [Id:%i] Saiu do servidor",Player_Name,playerid); SendClientMessageToAll(ROXO,string);

	//salva status
    GetPlayerName(playerid,file,sizeof(file));
    format(file,sizeof(file),DOF2_File(file));
    DOF2_SetInt(file, "Kills",PlayerInfo[playerid][pKills]);
    DOF2_SetInt(file, "Deaths",PlayerInfo[playerid][pDeaths]);
    DOF2_SetInt(file, "Money",GetPlayerMoney(playerid));
    DOF2_SetInt(file, "Score",GetPlayerScore(playerid));
    DOF2_SetInt(file, "AdminLevel",PlayerInfo[playerid][pAdmin]);
    DOF2_SetInt(file, "VipLevel",PlayerInfo[playerid][pVip]);


    return 1;
}

//------------------------------------------------------------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_REGISTER: { //cria arquivo de conta
            if(!response) Kick(playerid);
            if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Por favor, registre!","{FFFFFF}Digite aqui a sua {00FF22}SENHA {FFFFFF}para se cadastrar.","Cadastrar","Morrer");
            if(response) {
                new file[64];
                GetPlayerName(playerid,file,sizeof(file));
                format(file,sizeof(file),DOF2_File(file));
                DOF2_CreateFile(file, inputtext);
                DOF2_SetInt(file, "Kills", 0);
                DOF2_SetInt(file, "Deaths", 0); 
                DOF2_SetInt(file, "Money", 1000); 
                DOF2_SetInt(file, "Score", 0);
                DOF2_SetInt(file, "AdminLevel", 0);
				DOF2_SetInt(file, "VipLevel", 0);
                DOF2_SaveFile(); 
            }
        }
        case DIALOG_LOGIN: { //carrega arquivo de conta
            if(!response) Kick(playerid);
            if(response) {
                new file[64];
                GetPlayerName(playerid,file,sizeof(file));
                format(file,sizeof(file),DOF2_File(file));
                if(DOF2_FileExists(file)) {
                    if(DOF2_CheckLogin(file,inputtext)) {
                        PlayerInfo[playerid][pKills] = DOF2_GetInt(file,"Kills");
                        PlayerInfo[playerid][pDeaths] = DOF2_GetInt(file,"Deaths");
                        PlayerInfo[playerid][pMoney] = DOF2_GetInt(file,"Money");
                        PlayerInfo[playerid][pScore] = DOF2_GetInt(file,"Score");
                        PlayerInfo[playerid][pAdmin] = DOF2_GetInt(file,"AdminLevel");
                        PlayerInfo[playerid][pVip] = DOF2_GetInt(file,"VipLevel");
                        GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
                        SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);
                        return 1;
                    }
                    else
                    {
                        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"SENHA INCORRETA!","{F81414}Você digitou a senha errada\n{FFFFFF}Digite sua senha aqui para entrar!","Login","Morrer");
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
        return SendClientMessage(playerid,COLOR_RED,"Você não pode utilizar comandos enquanto está morto!");
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
		SendClientMessage(playerid, COLOR_DGREEN, " - Para ver as informações do server, utilize /info");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/comandos", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - AJUDA - /ajuda /info /comandos /armas /objetivo /regras");
		SendClientMessage(playerid, COLOR_DGREEN, " - ARMAS - /m4 /sniper /deagle /shotgun /mp5");
		SendClientMessage(playerid, COLOR_DGREEN, " - JOGADOR - /mudar /kill /godmode /v");
		SendClientMessage(playerid, COLOR_DGREEN, " - TELEPORTS - /arena");

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
		SendClientMessage(playerid, COLOR_DGREEN, " - Você não pode comprar armas no modo pacífico");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/arena", true) == 0) {
		if(GetPVarInt(playerid,"Arena") == 1) return SendClientMessage(playerid,COLOR_RED,"Você ja foi pra arena!");
		if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
		
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
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=1000) {
        	GivePlayerWeapon(playerid,24,100);
        	GivePlayerMoney(playerid,-1000);
        	format(string,128,"[ID:%i] %s comprou uma Deagle (/deagle)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
   		}
    	else return SendClientMessage(playerid,COLOR_GREY, "Você não tem nem $1000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/sniper", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=5000) {
        	GivePlayerWeapon(playerid,34,100);
        	GivePlayerMoney(playerid,-5000);
        	SendClientMessage(playerid,COLOR_GREY, "Você comprou uma sniper com 100 balas por $5000!");
        	format(string,128,"[ID:%i] %s comprou uma Sniper (/sniper)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Você não tem nem $5000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/m4", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=3000){
        	GivePlayerWeapon(playerid,31,100);
        	GivePlayerMoney(playerid,-3000);
			SendClientMessage(playerid,COLOR_GREY, "Você comprou uma m4 com 100 balas por $3000!");
        	format(string,128,"[ID:%i] %s Comprou uma m4 (/m4)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Você não tem nem $3000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/mp5", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=2000) {
        	GivePlayerWeapon(playerid,29,100);
        	GivePlayerMoney(playerid,-2000);
  			SendClientMessage(playerid,COLOR_GREY, "Você comprou uma mp5 com 100 balas por $2000!");
        	format(string,128,"[ID:%i] %s comprou uma MP5 (/mp5)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
		}
    	else return SendClientMessage(playerid,COLOR_GREY, "Você não tem nem $2000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/shotgun", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
    	if(GetPlayerMoney(playerid)>=2000) {
        	GivePlayerWeapon(playerid,25,50);
        	GivePlayerMoney(playerid,-2000);
  			SendClientMessage(playerid,COLOR_GREY, "Você comprou uma Shotgun com 50 balas por $2000!");
        	format(string,128,"[ID:%i] %s comprou uma Shotgun (/shotgun)",playerid,Player_Name),
        	SendClientMessageToAll(COLOR_DGREEN,string);
    	}
    	else return SendClientMessage(playerid,COLOR_GREY, "Você não tem nem $2000!");

		return 0x01;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/suprema", true) == 0) {
	    if(PlayerInfo[playerid][god] == true) return SendClientMessage(playerid,COLOR_RED,"Desabilite o modo pacífico primeiro (/godmode)");
        GivePlayerWeapon(playerid,10,1);
        GivePlayerMoney(playerid,-1);
  		SendClientMessage(playerid,COLOR_GREY, "Você comprou a suprema ponta dupla por 1 dólar");
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
		SendClientMessage(playerid, COLOR_DGREEN, " - Após escolher um time, você deve matar os outros jogadores");
		SendClientMessage(playerid, COLOR_DGREEN, " - Quando você mata um jogador você ganha um de score e $1000 para gastar.");
		SendClientMessage(playerid, COLOR_DGREEN, " - Portanto para ter mais poder de fogo, é necessário ter dinheiro. (/armas)");

		return 1;
	}
	//-----------------------------------------------------------
	if(strcmp(cmd, "/regras", true) == 0) {
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido o uso de: Cheats, Mods CLEO, e outros programas/mods ilegais");
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido DB/Spawn Kill/Heli Kill, PROIBIDO SE MATAR NA ARENA (PULAR DO PREDIO)");
		SendClientMessage(playerid, COLOR_DGREEN, " - Proibido Team Kill: Matar jogador do mesmo time! (mesma cor de nick)");
		SendClientMessage(playerid, COLOR_DGREEN, " - O descumprimento das regras acima causará ban/kick/cadeia");

		return 1;
	}
	//-----------------------------------------------------------
 	if(strcmp(cmdtext, "/kill", true) == 0) {
		PlayerInfo[playerid][god] = false;
        new Float:Life;
        GetPlayerHealth(playerid,Life);
        
        if(Life < 80) return SendClientMessage(playerid,COLOR_RED,"Você não pode cometer suicidio com a vida baixa.");
        
        SetPlayerHealth(playerid,0);
        format(string,128,"[ID:%i] %s Se matou (/kill)",playerid,Player_Name),
        SendClientMessageToAll(COLOR_DGREEN,string);

		return 1;
    }

	if(strcmp(cmdtext, "/godmode", true) == 0) {
		new Float:Life;
        GetPlayerHealth(playerid,Life);
        
	    if(PlayerInfo[playerid][god] == false){
	        if(Life < 100) return SendClientMessage(playerid,COLOR_RED,"Você só pode entrar no moto pacífico com a vida cheia.");
	        
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
        	GivePlayerWeapon(playerid,24,500);
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
				format(string, sizeof(string), "Você enviou para o jogador %s(ID: %d), $%d.", giveplayer,giveplayerid, moneys);
				SendClientMessage(playerid, COLOR_YELLOW, string);
				format(string, sizeof(string), "Você recebeu $%d do jogador %s(ID: %d).", moneys, sendername, playerid);
				SendClientMessage(giveplayerid, COLOR_YELLOW, string);
				printf("%s(playerid:%d) has transfered %d to %s(playerid:%d)",sendername, playerid, moneys, giveplayer, giveplayerid);
			}
			else {
				SendClientMessage(playerid, COLOR_YELLOW, "Transação inválida..");
			}
		}
		else {
				format(string, sizeof(string), "ID: %d não está online.", giveplayerid);
				SendClientMessage(playerid, COLOR_YELLOW, string);
		}
		return 1;
	}
	//-----------------------------------------------------------

	
	//admin commands
	
	if (PlayerInfo[playerid][pAdmin] > 0 || IsPlayerAdmin(playerid)){ //antes de ler o comando, checa se é adm
	                                        //assim um player normal vai receber a mensagem que o comando não existe
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
		    if (PlayerInfo[playerid][pAdmin] < 3 || !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");
		
  			new tmp[256], player2, level;
			tmp = strtok(cmdtext, idx);

			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [LEVEL]");
				return 1;
			}
			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador não conectado");

			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [LEVEL]");
				return 1;
			}
			level = strval(tmp);
			if (level < 0 || level > 3) return SendClientMessage(playerid, COLOR_YELLOW, "nível inválido");
			
			PlayerInfo[player2][pAdmin] = level;
			SendClientMessage(playerid, COLOR_YELLOW, "Você alterou o status de admin do jogador");
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
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador não conectado");
			TogglePlayerControllable(player2, 0);
			format(string, 46, "O admin %s lhe congelou.", GetPlayerNameEx(playerid));
			SendClientMessage(player2, COLOR_RED, string);
			format(string, 46, "Você congelou %s.", GetPlayerNameEx(player2));
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
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador não conectado");
			TogglePlayerControllable(player2, 1);
			format(string, 46, "O admin %s lhe descongelou.", GetPlayerNameEx(playerid));
			SendClientMessage(player2, COLOR_RED, string);
			format(string, 46, "Você descongelou %s.", GetPlayerNameEx(player2));
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
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador não conectado");
			new Float: pX, Float: pY, Float: pZ;
			
			if(IsPlayerInAnyVehicle(playerid))
			{
        		format(string, sizeof(string), "Você foi até %s.", GetPlayerNameEx(player2));
        		SendClientMessage(playerid, COLOR_YELLOW, string);
        		GetPlayerPos(player2, pX, pY, pZ);
        		SetVehiclePos(GetPlayerVehicleID(playerid), pX+1, pY+1, pZ);
        		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(player2));
    		}
    		else {
    		    format(string, sizeof(string), "Você foi até %s", GetPlayerNameEx(player2));
        		SendClientMessage(playerid, COLOR_YELLOW, string);
        		GetPlayerPos(player2, pX, pY, pZ);
        		SetPlayerPos(player2, pX+1, pY+1, pZ);
        		SetPlayerInterior(playerid, GetPlayerInterior(player2));
    			}
			return 1;
		}
		//-----------------------------------------------------------
	} //fim dos comandos de ADM
	
	if(PlayerInfo[playerid][pVip] == 1 || PlayerInfo[playerid][pAdmin] >= 3) { //comandos VIP
	
        if(strcmp(cmd, "/vip", true) == 0) {
		    if (PlayerInfo[playerid][pAdmin] < 5 || !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "NO ENOUGH LEVEL, STRANGER!");

  			new tmp[256], player2, level;
			tmp = strtok(cmdtext, idx);

			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [0 - NÃO / 1 - SIM]");
				return 1;
			}
			player2 = strval(tmp);
			if(!IsPlayerConnected(player2)) return SendClientMessage(playerid, COLOR_YELLOW, "Jogador não conectado");

			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, COLOR_GREY, "USE: /promover [ID] [0 - NÃO / 1 - SIM]");
				return 1;
			}
			level = strval(tmp);
			if (level < 0 || level > 1) return SendClientMessage(playerid, COLOR_YELLOW, "nível inválido");

			PlayerInfo[player2][pVip] = level;
			SendClientMessage(playerid, COLOR_YELLOW, "Você alterou o status de vip do jogador");
			SendClientMessage(player2, COLOR_YELLOW, "Seu status de vip foi alterado");
			return 1;
		}



		if(strcmp(cmd, "/nitro", true) == 0) {
		    new Float:X, Float:Y, Float:Z;
			GetPlayerPos(playerid, X, Y, Z);
		    
		    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Você precisa estar em um carro.");
		    
   			new vehicleid = GetPlayerVehicleID(playerid);
   			AddVehicleComponent(vehicleid, 1010); // x10 nitro
   			
            PlayerPlaySound(playerid, 1133, X, Y, Z);
   			
   			SendClientMessage(playerid, COLOR_GREEN, "Nitro adicionado!");
		    return 1;
		}
	}

	return SendClientMessage(playerid,COLOR_YELLOW,"Comando inexistente. Use /ajuda");
}

//------------------------------------------------------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid,0);
	SetPlayerRandomSpawn(playerid);
	TogglePlayerClock(playerid,0);
	SetPVarInt(playerid,"Arena",0);
	SetPVarInt(playerid,"Morto",0);
	SetPVarInt(playerid,"TK",0);
	GivePlayerWeapon(playerid,24,500);

    switch(pClass[playerid])
    {
        //time vermelho
        case 0:
        {
            SetPlayerColor(playerid, 0xFF0000AA);
            SetPlayerPos(playerid, 693.668,1959.560,5.109);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 1:
        {
            SetPlayerColor(playerid, 0xFF0000AA);
            SetPlayerPos(playerid, 693.668,1959.560,5.109);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 2:
        {
            SetPlayerColor(playerid, 0xFF0000AA);
            SetPlayerPos(playerid, 693.668,1959.560,5.109);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 3:
        {
            SetPlayerColor(playerid, 0xFF0000AA);
            SetPlayerPos(playerid, 693.668,1959.560,5.109);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        //time azul
        case 4:
        {
            SetPlayerColor(playerid, 0x2641FEAA);
            SetPlayerPos(playerid, -131.450,1229.313,19.469);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 5:
        {
            SetPlayerColor(playerid, 0x2641FEAA);
            SetPlayerPos(playerid, -131.450,1229.313,19.469);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 6:
        {
            SetPlayerColor(playerid, 0x2641FEAA);
            SetPlayerPos(playerid, -131.450,1229.313,19.469);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 7:
        {
            SetPlayerColor(playerid, 0x2641FEAA);
            SetPlayerPos(playerid, -131.450,1229.313,19.469);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        // time policiais
        case 8:
        {
            SetPlayerColor(playerid, 0xAFAFAFAA); 
            SetPlayerPos(playerid, -548.710,2593.98,53.483);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 9:
        {
            SetPlayerColor(playerid, 0xAFAFAFAA);
            SetPlayerPos(playerid, -548.710,2593.98,53.483);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 10:
        {
            SetPlayerColor(playerid, 0xAFAFAFAA);
            SetPlayerPos(playerid, -548.710,2593.98,53.483);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        case 11:
        {
            SetPlayerColor(playerid, 0xAFAFAFAA);
            SetPlayerPos(playerid, -548.710,2593.98,53.483);
            SetPlayerFacingAngle(playerid, 180.0);
        }
        //time roxo
        case 12:
        {
            SetPlayerColor(playerid, ROXO);
            SetPlayerPos(playerid, 413.513,2533.530,18.668);
            SetPlayerFacingAngle(playerid, 90.0);
        }
        case 13:
        {
            SetPlayerColor(playerid, ROXO);
            SetPlayerPos(playerid, 413.513,2533.530,18.668);
            SetPlayerFacingAngle(playerid, 90.0);
        }
        case 14:
        {
            SetPlayerColor(playerid, ROXO);
            SetPlayerPos(playerid, 413.513,2533.530,18.668);
            SetPlayerFacingAngle(playerid, 90.0);
        }
        case 15:
        {
            SetPlayerColor(playerid, ROXO);
            SetPlayerPos(playerid, 413.513,2533.530,18.668);
            SetPlayerFacingAngle(playerid, 90.0);
        }
    }
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
    GetPlayerName(killerid,Player_Name,sizeof(Player_Name));
    GetPlayerName(playerid,Player_Name2,sizeof(Player_Name2));
    
	//reset de variáveis
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
	if(Health <= 80)
	{
    	SetPlayerHealth(killerid, Health + 20);
    	SendClientMessage(killerid,COLOR_WHITE,"Você tinha menos que 80 de vida, e ganhou 20!");
	}
	
	//team killing
	if(GetPlayerColor(playerid) == GetPlayerColor(killerid)) {
    if(GetPVarInt(killerid,"TK") <= 1) {
		new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerPos(killerid, x, y, z+200);
        SendClientMessage(killerid, COLOR_RED, "TEAM KILLING É PROIBIDO, MAKAKO.");
        if(GetPVarInt(killerid,"TK") == 0) {
            SendClientMessage(killerid, COLOR_RED, "PUNIÇÃO: -$1000 e -5 SCORES");
            SetPlayerScore(killerid,GetPlayerScore(killerid) - 5);
            GivePlayerMoney(killerid,-1000);
        }
        if(GetPVarInt(killerid,"TK") == 1) {
            SendClientMessage(killerid, COLOR_RED, "PUNIÇÃO: -200000 -50 SCORES");
            SetPlayerScore(killerid,GetPlayerScore(killerid) - 50);
            GivePlayerMoney(killerid,-200000);
        }
        KillingSpree[playerid] = 0;
        SetPlayerWantedLevel(killerid,0);
        SetPVarInt(killerid,"TK",1);
        } else if (GetPVarInt(killerid,"TK") > 1) {
			SendClientMessage(killerid, COLOR_RED,"Você foi kikado por cometer Team-Kill 3 vezes.");
			Kick(killerid);
		}
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
    	format(string,256,"%s (ID: %i) está detonando (5 kills consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 7){
        SetPlayerWantedLevel(killerid,3);
        GivePlayerMoney(killerid,1700);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 7);
    	format(string,256,"%s (ID: %i) ESTÁ IMPARÁVEL! (7 kill consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 10){
        SetPlayerWantedLevel(killerid,4);
        GivePlayerMoney(killerid,2500);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 10);
    	format(string,256,"%s (ID: %i) ESTÁ DE HACK?!?!?! (10 KILLS CONSECUTIVAS)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 15){
        SetPlayerWantedLevel(killerid,5);
        GivePlayerMoney(killerid,5000);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 20);
    	format(string,256,"Alguém reporta o %s (ID: %i). ta cheatado, essa porra. (15 kills consecutivas)",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	if(KillingSpree[killerid] == 20){
        SetPlayerWantedLevel(killerid,6);
        GivePlayerMoney(killerid,10000);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 50);
    	format(string,256,"%s (ID: %i) chegou a 20 kills consecutivas. Quem matar ele ganha $1 milhão.",Player_Name,killerid);
		SendClientMessageToAll(COLOR_RED,string);
   	}
   	
   	//recompensa por matar player em killing spree
   	if(KillingSpree[playerid] >= 3 && KillingSpree[playerid] < 5) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($2000 + 2 score).",Player_Name2,killerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,2000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 2);
   	}
   	if(KillingSpree[playerid] >= 5 && KillingSpree[playerid] < 7) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($3000 + 4 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,3000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 4);
   	}
   	if(KillingSpree[playerid] >= 7 && KillingSpree[playerid] < 10) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($5000 + 6 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,5000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 6);
   	}
   	if(KillingSpree[playerid] >= 10 && KillingSpree[playerid] < 15) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($10000 + 10 score).",Player_Name2,playerid,Player_Name,killerid);
   		SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,10000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 10);
   	}
   	if(KillingSpree[playerid] >= 15 && KillingSpree[playerid] < 20) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($20000 + 20 score).",Player_Name2,playerid,Player_Name,killerid);
   		SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,20000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 20);
   	}
   	if(KillingSpree[playerid] >= 20) {
   	    format(string,256,"%s (ID: %i) foi neutralizado por %s (ID: %i). Recompensa ($1000000 + 100 score).",Player_Name2,playerid,Player_Name,killerid);
	   	SendClientMessageToAll(COLOR_RED,string);
   	    GivePlayerMoney(killerid,1000000);
   	    SetPlayerScore(killerid, GetPlayerScore(killerid) + 100);
   	}
    
    KillingSpree[playerid] = 0; //não ta no reset pq se ficasse no topo ia zuar o sistema de recompensa =C
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
    AddPlayerClass(285,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 8 Polícia
    AddPlayerClass(284,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 9 Polícia
    AddPlayerClass(280,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 10 Polícia
    AddPlayerClass(287,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 11 Polícia
    AddPlayerClass(228,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 12 Roxo
    AddPlayerClass(217,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 13 Roxo
    AddPlayerClass(211,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 14 Roxo
    AddPlayerClass(169,2508.1372,-1656.6781,13.5938,129.4222,0,0,0,0,0,0); // Class 15 Roxo

	// Base vermelha

	AddStaticVehicle(411,390.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,385.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,380.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,375.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,370.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,365.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,360.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,355.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,350.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(411,345.748,2541.178,16.059,180.000,211,149);
	AddStaticVehicle(487,365.059,2466.570,16.211,0.000,211,1);
	AddStaticVehicle(487,340.059,2466.570,16.211,0.000,211,1);
	AddStaticVehicle(522,418.189,2531.904,16.319,180.000,211,1);
	AddStaticVehicle(522,420.189,2531.904,16.319,180.000,211,1);
	AddStaticVehicle(522,422.189,2531.904,16.319,180.000,211,1);
	AddStaticVehicle(522,424.189,2531.904,16.319,180.000,211,1);
	AddStaticVehicle(522,426.189,2531.904,16.319,180.000,211,1);


	// Base azul

	AddStaticVehicle(522,-177.707,1225.307,19.469,270.000,79,79);
	AddStaticVehicle(522,-177.707,1222.307,19.469,270.000,79,79);
	AddStaticVehicle(522,-177.707,1219.307,19.469,270.000,79,79);
	AddStaticVehicle(522,-177.707,1216.307,19.469,270.000,79,79);
	AddStaticVehicle(522,-177.707,1213.307,19.469,270.000,79,79);
	AddStaticVehicle(402,-158.171,1229.100,19.469,180.000,79,79);
	AddStaticVehicle(415,-163.171,1229.100,19.469,180.000,79,79);
	AddStaticVehicle(424,-168.171,1229.100,19.469,180.000,79,79);
	AddStaticVehicle(429,-134.379,1217.458,19.469,180.000,79,79);
	AddStaticVehicle(439,-139.379,1217.458,19.469,180.000,79,79);
	AddStaticVehicle(451,-144.379,1217.458,19.469,180.000,79,79);
	AddStaticVehicle(477,-149.379,1217.458,19.469,180.000,79,79);

	// Base policia

	AddStaticVehicle(522,730.545,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(522,726.545,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(402,721.664,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(415,716.230,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(424,711.663,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(429,706.816,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(522,701.105,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(522,696.453,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(439,691.637,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(451,686.793,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(477,681.548,1949.693,5.103,180.000,3,3);
	AddStaticVehicle(522,676.445,1949.693,5.103,180.000,3,3);

	// Base roxa

	AddStaticVehicle(523,-527.113,2579.040,52.984,90.000,11,11); // HPV 1000
	AddStaticVehicle(523,-527.113,581.454,52.984,90.000,11,11); // HPV 1000
	AddStaticVehicle(523,-527.113,2576.397,52.984,90.000,11,11); // HPV 1000
	AddStaticVehicle(523,-527.113,2573.866,52.984,90.000,11,11); // HPV 1000
	AddStaticVehicle(523,-527.113,2571.356,52.984,90.000,11,11); // HPV 1000
	AddStaticVehicle(598,-529.922,2563.687,52.979,90.000,11,11); // LVPD
	AddStaticVehicle(598,-529.992,2558.218,52.979,90.000,11,11); // LVPD
	AddStaticVehicle(598,-521.068,2559.008,52.978,270.000,11,11); // LVPD
	AddStaticVehicle(598,-521.068,2564.219,52.979,270.000,11,11); // LVPD
	AddStaticVehicle(598,-521.068,2569.458,52.979,270.000,11,11); // LVPD
	AddStaticVehicle(528,-519.800,2577.061,52.985,270.000,11,11); // FBI
	AddStaticVehicle(528,-519.800,2582.120,52.985,270.000,11,11); // FBI
	AddStaticVehicle(470,-538.258,2603.697,52.980,270.000,11,11); // Patriot
	AddStaticVehicle(470,-538.258,2608.662,52.980,270.000,11,11); // Patriot
	AddStaticVehicle(470,-538.258,2613.509,52.980,270.000,11,11); // Patriot
	AddStaticVehicle(470,-538.258,2618.340,52.980,270.000,11,11); // Patriot
	AddStaticVehicle(470,-538.258,2623.540,52.980,270.000,11,11); // Patriot
	AddStaticVehicle(497,-510.126,2632.243,52.979,90.000,11,11); // Heli
	AddStaticVehicle(497,-511.969,2605.545,52.980,90.000,11,11); // Heli

	// Carros espalhados

    AddStaticVehicle(568,9.2662,1231.0234,18.9078,89.6072,1,1); //
	AddStaticVehicle(424,16.2422,1166.0085,19.1346,0.1662,2,2); //
	AddStaticVehicle(495,18.4716,1353.1819,8.7386,23.3455,3,3); //
	AddStaticVehicle(505,-34.4963,1377.6820,8.8819,141.9388,4,4); //
	AddStaticVehicle(403,-100.1622,1380.6021,9.8428,105.4320,5,5); //
	AddStaticVehicle(413,-89.2076,1535.0980,16.1564,35.0308,6,6); //
	AddStaticVehicle(421,-165.2876,1676.9580,14.3540,19.4646,7,7); //
	AddStaticVehicle(422,-57.6921,1841.9924,17.1237,74.9541,8,8); //
	AddStaticVehicle(426,-231.4026,2042.8424,28.7066,347.3830,9,9); //
	AddStaticVehicle(434,-38.0279,2236.6855,37.8787,309.6378,10,10); //
	AddStaticVehicle(463,-22.2527,2333.0918,23.7102,5.7975,11,11); //
	AddStaticVehicle(471,-241.0324,2595.2539,62.2753,358.2202,12,12); //
	AddStaticVehicle(568,-204.4339,2595.8342,62.2612,358.0206,13,13); //
	AddStaticVehicle(424,-223.0472,2770.4795,62.2559,179.0655,14,14); //
	AddStaticVehicle(495,-275.9200,2718.8606,62.1983,6.1004,15,15); //
	AddStaticVehicle(505,-600.7001,2701.3452,71.8574,115.1483,16,16); //
	AddStaticVehicle(413,-682.1919,2705.9470,69.1983,147.5775,17,17); //
	AddStaticVehicle(403,-767.0948,2760.2974,45.3398,180.6232,18,18); //
	AddStaticVehicle(421,-840.2679,2742.2256,45.3325,183.0326,19,19); //
	AddStaticVehicle(422,-1316.2272,2696.1790,49.6391,118.6256,20,20); //
	AddStaticVehicle(426,-1399.9670,2640.6926,55.2526,85.5841,21,21); //
	AddStaticVehicle(434,-1401.2579,2656.4988,55.2537,86.8121,22,22); //
	AddStaticVehicle(463,-1506.9604,2525.9380,55.2563,0.3813,23,23); //
	AddStaticVehicle(471,-1526.2809,2638.7605,55.3870,96.9867,24,24); //


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
	SendClientMessageToAll(COLOR_RED, "Bônus por ficar online: $10000");
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
