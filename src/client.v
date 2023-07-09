module redis

import pool
import net
import pool.proto

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

fn (mut c BaseClient) get_connection() !pool.Connection {
	cn := c.retrieve_connection()!
	return cn
}

fn (mut c BaseClient) retrieve_connection() !pool.Connection {
	mut cn := c.connection_pool.get()!

	if cn.initialized {
		return cn
	}

	c.init_connection(mut cn) or {
		c.connection_pool.remove(mut cn, err.msg())
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
			conn.auth_acl(username, password)!
		} else {
			conn.auth(password)!
		}
	}
	if c.options.db > 0 {
		conn.select_db(c.options.db)!
	}
}

fn (mut c BaseClient) release_connection(mut cn pool.Connection) ! {
	c.connection_pool.put(mut cn)!
}

fn (mut c BaseClient) with_connection(func fn (mut pool.Connection) !) ! {
	mut cn := c.get_connection()!
	func(mut cn) or {
		c.release_connection(mut cn)!
		return err
	}
	c.release_connection(mut cn)!
}

fn (mut c BaseClient) dial(address string) !&net.TcpConn {
	return c.options.dialer(address)
}

fn (mut c BaseClient) process(mut cmd Cmder) ! {
	for attempt := 0; attempt <= c.options.max_retries; attempt += 1 {
		c.attempt_process(mut cmd) or {
			if attempt == c.options.max_retries {
				return err
			} else {
				continue
			}
		}
		break
	}
}

fn (mut c BaseClient) attempt_process(mut cmd_val Cmder) ! {
	// Trying to apply https://github.com/vlang/v/blob/3558e05bfb6f5a1607bf60dd503786a90c1fdbc3/doc/docs.md#closures
	// Defining a reference to propagate changes outside of closure scope.
	mut cmd := &cmd_val // <-- error
	// `cmd_val` cannot be referenced outside `unsafe` blocks as it might be stored on stack.
	// Consider wrapping the `.Cmder` object in a `struct` declared as `[heap]`.
	//
	// A few problems here:
	// 1) cmd_val is already supposed to be a reference.
	// 2) cmd_val is already a StatusCmd struct, defined as [heap] that impplements the Cmder interface.
	// How is it possible to wrap an interface in a struct?
	c.with_connection(fn [mut cmd] (mut cn pool.Connection) ! {
		cn.with_writer(fn [cmd] (mut wr proto.Writer) ! {
			write_cmd(mut wr, cmd)!
		})!
		cn.with_reader(cmd.read_reply)! // <-- Even by using unsafe blocks, the same situation as
		// commit 3a7d04e59a92416700a03191ad605f35daf6a65e happens.
	})!
}

// close closes the client, releasing any open resources.
// It is rare to close a Client, as the Client is meant to be long-lived and shared between many coroutines.
fn (mut c BaseClient) close() ! {
	c.connection_pool.close()!
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
[heap]
pub struct Client {
	BaseClient
	Cmdable
}

// new_client returns a client according to the specified Options.
pub fn new_client(mut options Options) &Client {
	options.init()

	mut c := &Client{
		BaseClient: BaseClient{
			options: options
			connection_pool: new_connection_pool(options)
		}
	}
	c.cmdable_function = c.process
	return c
}

fn (mut c Client) process(mut cmd Cmder) ! {
	c.BaseClient.process(mut cmd)!
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
