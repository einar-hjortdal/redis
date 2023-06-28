module redis

import pool

/*
*
*
* BaseClient
*
*
*/

struct BaseClient {
	options Options
mut:
	connection_pool pool.Pooler
	on_close        fn () !
}

fn (mut c BaseClient) new_connection() !pool.Connection {
	mut cn := c.connection_pool.new_connection()!

	c.init_connection(mut cn) or {
		c.connection_pool.close_connection(mut cn)!
		return err
	}

	return cn
}

fn (c BaseClient) init_connection(mut cn pool.Connection) ! {
	if cn.initialized {
		return
	}
	cn.initialized = true

	username := c.options.username
	password := c.options.password
	conn_pool := pool.new_single_connection_pool(c.connection_pool, cn)
	conn := new_connection(c.options, conn_pool)

	// These commands can be pipelined.
	if password != '' {
		if username != '' {
			conn.auth_acl(username, password)
		} else {
			conn.auth(password)
		}
	}
	if c.options.db > 0 {
		conn.select_db(c.options.db)
	}
}

/*
*
*
* Client
*
*
*/

// Client representing a pool of zero or more underlying connections. A client creates and frees connections
// automatically.
pub struct Client {
	BaseClient
	Cmdable
}

// new_client returns a client according to the specified Options.
pub fn new_client(mut options Options) Client {
	options.init()

	mut c := Client{
		BaseClient: BaseClient{
			options: options
			connection_pool: new_connection_pool(options)
		}
	}
	return c
}

/*
*
*
* Connection
*
*
*/

// Connection represents a single connection rather than a pool of connections. A Connection is used
// to start a new client and should not be used unless strictly necessary.
pub struct Connection {
	BaseClient
	Cmdable
	CmdableStateful
}

fn new_connection(options Options, connection_pool pool.Pooler) Connection {
	mut c := Connection{
		BaseClient: BaseClient{
			options: options
			connection_pool: connection_pool
		}
	}
	return c
}
