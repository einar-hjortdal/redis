module redis

fn setup_stateful_cmdable_client() &Client {
	// Typical settings used by peony
	mut opts := Options{
		address: 'localhost:29400'
		password: 'aed3261756c78a862013ac9a4f0d31dc1451a25a79653ff3951a2343f33245e8'
	}
	return new_client(mut opts)
}

// test_hello checks that the connections are initialized properly and RESP version 3 is used.
// To test authentication with HELLO it is nececssary to configure KeyDB to use password and ACL.
// This requires 2 different servers running at the same time or running the test twice with different
// options.
// The test is by default using the most common configuration with password only.
fn test_hello() {
	client := setup_stateful_cmdable_client()

	// Check authentication
	mut res := client.ping() or { panic(err) }
	assert res.val() == 'PONG'

	// Check RESP 3 nil replies
	// TODO
}
