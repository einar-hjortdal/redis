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
	get_res := client.get('test_key') or { panic(err) }
	assert get_res.val() == 'test_value'
}

fn test_del() {
	client := setup_cmdable_client()
	set_res := client.set('test_key', 'test_value', 60 * time.second) or { panic(err) }
	del_res := client.del('test_key') or { panic(err) }
	assert del_res.val() == 1 // deleted one value
	get_res := client.get('test_key') or { panic(err) }
	println(get_res) // TODO error is not set, is there an error to set?
	// assert get_res.val() == '' // no value for key `'test_key'`
}

/*
*
*
* StatefulCmdable
*
*
*/
