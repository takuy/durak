Buttons
	parent_type = /obj
	Cant
		name = "Take"
		screen_loc = "1,4"
		icon = 'Take.png'
		Click()
			world << system("[Game.defender] folds this round. They take everything on the table and add it to their hand.")
			Game.New_round(1)
			Game.table = new

	Done
		name = "Done"
		screen_loc = "1,5"
		icon = 'Done.png'
		Click()
			if(Game.defender!=usr)
				usr.done = 1
			var/d = 0
			var/b = 0
			for(var/Cards/x in Game.table)
				if(x.beat) b++
			if(b == Game.table.len && Game.defender==usr)
				world << system("The defender, [Game.defender] has beaten all the cards on the table. If there are no more cards to add, everyone click \"Done\".")
			for(var/mob/x in players)
				if(x.done) d++

			if(Game.defender!=usr)
				world << system("[usr] has chosen not to add to the attack anymore this round.")
				if((d >= players.len-1)&&(b == Game.table.len))
					Game.New_round()
/*	Add_mob()
		if(isHost(src)&&!GameOn&&((players.len<4&&Deck.setting==36)||(players.len<8&&Deck.setting==52)))
			var/mob/A = new
			players += A
			world << system("mob joins the game!")
			A.loc = locate(text2path("/spawns/player_[players.Find(A)]"))
			A.icon = 'mob.dmi' */
	Join
		name = "Join"
		screen_loc = "1,5"
		icon = 'Join.png'
		Click()
			if(!GameOn && !(usr in players) && ( (players.len<4 && Deck.setting==36) || (players.len<8 && Deck.setting==52) ))
				players += usr
				world << system("[usr] joins the game!")
				usr.loc = locate(text2path("/spawns/player_[players.Find(usr)]"))
				usr.icon = 'mob.dmi'
				var/obj/t = new(world)
				t.maptext = "<center><font color=white>[usr.key]</font></center>"
				t.maptext_width = 200
				t.pixel_y = -30
				t.pixel_x = -((200-32)*0.5)
				t.layer = MOB_LAYER+1
				usr.overlays += t
				del t
	Start
		name = "Start"
		screen_loc = "1,4"
		icon = 'Start.png'
		Click()
			if(isHost(usr) && !GameOn && players.len>1)
				Start()
	Settings
		screen_loc = "13,16"
		icon = 'Settings.png'
		var/showing = 0
		Click()
			if(isHost(usr) && players.len<5)
				showing = !showing
				if(showing)
					usr.client.screen += host_stuff
				else
					usr.client.screen -= host_stuff

		Deck_setting
			var/size = 0
			screen_loc = "6,12"
			icon = 'Deck.png'
			Click()
				if(isHost(usr) && players.len<5)
					if(!size)
						Deck.setting = Deck.setting==36? 52 : 36
						world << system("The deck will now have [Deck.setting] cards. (32 cards is limited to 4 players, 52 cards has a maximum of 8.)")
					else
						Deck.setting = size
						world << system("The deck will now have [Deck.setting] cards. (32 cards is limited to 4 players, 52 cards has a maximum of 8.)")
			size_36
				screen_loc = "9,12"
				icon = 'size_36.png'
				size = 36
			size_52
				screen_loc = "10,12"
				icon = 'size_52.png'
				size = 52

		Pass_setting
			screen_loc = "6, 11"
			icon = 'Pass.png'
			Click()
				if(isHost(usr) && !GameOn)
					Game.passing = Game.passing? Game.passing==1? 2 : 0 : 1
					world << system("Pass setting: [Game.passing==2? "Flashing" : Game.passing==1? "Matching" : "Off"]")
	Help
		screen_loc = "1,16"
		icon = 'Help.png'
		Click()
			usr << browse(instructions, "window=Help")
var
	Buttons
		Cant/Cant = new
		Done/Done = new
		Join/Join = new
		Start/Start = new
		Help/Help = new
		Settings/Settings = new
	host_stuff = newlist(
	/Buttons/Settings/Deck_setting,
	/Buttons/Settings/Deck_setting/size_36,
	/Buttons/Settings/Deck_setting/size_52,
	/Buttons/Settings/Pass_setting)