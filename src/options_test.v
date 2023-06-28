module redis

fn setup_options() Options {
	mut opts := Options{}
	opts.init()
	return opts
}

fn test_new_dealer() {
	opts := setup_options()
	dialer := new_dialer(opts) or { panic(err) }
}

fn test_new_connection_pool() {
	opts := setup_options()
	dialer := new_dialer(opts) or { panic(err) }
	mut pool := new_connection_pool(opts, dialer)
	pool.close() or { panic(err) }
}

fn test_pool_get() {
	opts := setup_options()
	dialer := new_dialer(opts)!
	mut pool := new_connection_pool(opts, dialer)
	conn := pool.get() or { panic(err) }
	assert conn.id != ''
	pool.close() or { panic(err) }
}

// fn test_pool_put() {
// 	opts := setup_options()
// 	dialer := new_dialer(opts)!
// 	mut pool := new_connection_pool(opts, dialer)
// 	mut conn := pool.get() or { panic(err) }
// 	pool.put(mut conn) or { panic(err) } // should hang on free_turn() because of empty channel
// 	pool.close() or { panic(err) }
// }
