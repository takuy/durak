#define system(x) output(x,"system")

proc
	isHost(mob/x) return (world.internet_address==x.client.address||world.address==x.client.address||!x.client.address||world.host==x.key||x.client.address=="127.0.0.1")
