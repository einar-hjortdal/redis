module redis

fn setup_client() &Client {
	mut opts := Options{}
	return new_client(mut opts)
}

fn test_ping() {
	client := setup_client()
	res := client.ping() or {
		println(err)
		return
	}
	assert res.val() == 'PONG'
}
