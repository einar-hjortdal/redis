module pool

import net

fn test_new_connection() {
	mut tcp_connection := net.dial_tcp('localhost:6379') or { panic(err) }
	connection := new_connection(tcp_connection)
	assert connection.id != ''
	tcp_connection.close() or { panic(err) }
}
