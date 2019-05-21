client
	show_popup_menus=0

world
	hub = "supersaiyanx.durak"
	version = 1

mob
	layer = MOB_LAYER+1
	var
		done
		list
			hand = list()
	proc
		Redraw_Hand(list/ohand)
			client.screen = new
			client.screen +=  Help
			if(isHost(src)) client.screen += Settings
			//world << ohand.len
		//	world << kText.list2text(ohand)
			for(var/Cards/z in hand)
				if(!(z in ohand))
					sleep(2)

				z.Place(src,first=0,ohan=(z in ohand)? z : null)
				z.Reset()
	verb
		say(msg as text)
			if(msg) world << "<b>[src]:</b> [html_encode(msg)]"
		Server_address()
			src << world.url

	Stat()
		stat("Deck settings:","[Deck.setting] cards.")
		stat("Joined:", players.len)
		stat(Deck.trump)
		stat(Deck.talon.len)
		for(var/mob/x in players)
			stat("[x]", "Cards: [x.hand.len]")

	Login()
		world << "[src] has logged on."
		loc = locate (1,1,1)
		client.screen += Join
		client.screen += Start
		client.screen += Help
		if(isHost(src)) client.screen += Settings
		src << browse(instructions)

	Logout()
		world << "[src] has logged out."
		players -= src
		del src

	Move()
		return 0

green
	parent_type = /turf
	icon = 'green.dmi'

table
	parent_type = /turf
	icon = 'green.dmi'

spawns
	parent_type = /turf
	icon = 'black.dmi'
	New()
		..()
		icon = 'green.dmi'
	player_1
	player_2
	player_3
	player_4
	player_5
	player_6
	player_7
	player_8

borders
	parent_type =/obj
	icon = 'borders.dmi'

var
	list
		order = list("Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Jack","Queen","King","Ace","")
		players = new
	GameOn = 0
