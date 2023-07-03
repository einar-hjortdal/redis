module redis

fn test_ping() {
	mut opts := Options{}
	mut client := new_client(mut opts)
	res := client.ping() or {
		println(err)
		return
	}
	assert res.val() == 'PONG'
}
