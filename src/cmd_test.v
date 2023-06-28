module redis

fn test_ping() {
	mut opts := Options{}
	println(opts)
	client := new_client(mut opts)
	println(client)
	res := client.ping()
	println(res.val())
}
