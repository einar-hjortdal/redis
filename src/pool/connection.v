module pool

import net
import rand
import time
import proto

pub struct Connection {
pub:
	id         string
	created_at time.Time
	reader     proto.Reader
	writer     proto.Writer
mut:
	connection net.TcpConn
	pooled     bool
pub mut:
	initialized bool
}

fn new_connection(connection net.TcpConn) Connection {
	new := Connection{
		connection: connection
		id: rand.uuid_v4()
		created_at: time.now()
		reader: proto.new_reader(connection)
		writer: proto.new_writer(connection)
	}
	return new
}

fn (mut connection Connection) close() ! {
	connection.connection.close()!
}
