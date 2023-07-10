module redis

import time

/*
*
*
* Cmdable
*
*
*/

fn setup_cmdable_client() &Client {
	mut opts := Options{}
	return new_client(mut opts)
}

fn test_ping() {
	client := setup_cmdable_client()
	res := client.ping() or { panic(err) }
	assert res.val() == 'PONG'
}

fn test_set_and_get() {
	client := setup_cmdable_client()
	set_res := client.set('test_key', 'test_value', 60 * time.second) or { panic(err) }
	get_res := client.get('test_key') or { panic(err) } // hangs for some reason
	assert get_res.val() == 'test_value'
}

/*
*
*
* StatefulCmdable
*
*
*/
