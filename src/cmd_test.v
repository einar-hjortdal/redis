module redis

fn test_ping() {
	mut opts := Options{}
	mut client := new_client(mut opts)
	res := client.ping()!
	val := res.val()
	println(val)
}
