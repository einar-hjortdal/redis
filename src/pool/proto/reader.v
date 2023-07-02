module proto

import io
import math
// import math.big
import strconv
import x.json2 as json

pub struct Reader {
mut:
	reader io.BufferedReader
}

pub fn new_reader(io_reader io.Reader) Reader {
	return Reader{
		reader: io.new_buffered_reader(io.BufferedReaderConfig{ reader: io_reader })
	}
}

// reset discards any buffered data
pub fn (mut rd Reader) reset() {
	rd.reader.free()
}

pub fn (mut rd Reader) read_line() !string {
	line := rd.read()!

	if line.starts_with(resp_error) {
		return error(line.trim_string_right(resp_error))
	}
	if line.starts_with(resp_nil) {
		return ''
	}
	if line.starts_with(resp_blob_error) {
		return rd.read_string_reply(line)!
	}
	// Discard attribute type
	if line.starts_with(resp_attr) {
		rd.discard(line)!
		return rd.read_line()!
	}
	return line
}

fn (mut rd Reader) read() !string {
	// BufferedReader `read_line` stops at `\n`
	// https://modules.vlang.io/io.html#BufferedReader.read_line
	b := rd.reader.read_line()!
	if b == resp_crlf || !b.ends_with(resp_crlf) { // b does not end with resp_crlf. Why?
		return error('Invalid reply: ${b}')
	}
	return b.trim_string_right(resp_crlf)
}

fn (mut rd Reader) read_string_reply(line string) !string {
	n := reply_len(line)!
	mut b := []u8{len: n + 2}
	rd.reader.read(mut b)!

	return b[..n].bytestr()
}

fn reply_len(line string) !int {
	n := strconv.atoi(line[1..])!

	if n < -1 {
		return error('Invalid reply: ${line}')
	}

	if line.starts_with(resp_string) || line.starts_with(resp_verbatim)
		|| line.starts_with(resp_blob_error) || line.starts_with(resp_array)
		|| line.starts_with(resp_set) || line.starts_with(resp_push) || line.starts_with(resp_map)
		|| line.starts_with(resp_attr) {
		if n == -1 {
			return 0
		}
	}
	return n
}

pub fn (mut rd Reader) discard(line string) ! {
	if line.len == 0 {
		return error('Invalid line')
	}

	if line.starts_with(resp_status) || line.starts_with(resp_error) || line.starts_with(resp_int)
		|| line.starts_with(resp_nil) || line.starts_with(resp_float) || line.starts_with(resp_bool)
		|| line.starts_with(resp_big_int) {
		return
	}

	n := reply_len(line)!

	if line.starts_with(resp_blob_error) || line.starts_with(resp_string)
		|| line.starts_with(resp_verbatim) {
		// Skip over the next n+2 bytes
		mut discarded := []u8{cap: n + 2}
		_ := rd.reader.read(mut discarded)!
	}
	if line.starts_with(resp_array) || line.starts_with(resp_set) || line.starts_with(resp_push) {
		for i := 0; i < n; i++ {
			rd.discard_next()!
		}
	}
	if line.starts_with(resp_map) || line.starts_with(resp_attr) {
		for i := 0; i < n * 2; i++ {
			rd.discard_next()!
		}
	}

	return error("Can't parse ${line}")
}

pub fn (mut rd Reader) discard_next() ! {
	line := rd.read()!
	return rd.discard(line)
}

// read_reply parses the data returned by read_line()
pub fn (mut rd Reader) read_reply() !json.Any {
	line := rd.read_line()!
	if line.starts_with(resp_status) {
		return line.trim_string_left(resp_status)
	}
	if line.starts_with(resp_int) {
		return strconv.parse_int(line.trim_string_left(resp_int), 10, 64)!
	}
	if line.starts_with(resp_float) {
		return rd.read_float(line)!
	}
	if line.starts_with(resp_bool) {
		return rd.read_bool(line)!
	}
	// big int is not part of json.Any, consider returning a string instead or create a sum type.
	// if line.starts_with(resp_big_int) {
	// 	return rd.read_big_int(line)!
	// }
	if line.starts_with(resp_string) {
		return rd.read_string_reply(line)!
	}
	if line.starts_with(resp_verbatim) {
		return rd.read_verb(line)!
	}
	if line.starts_with(resp_array) || line.starts_with(resp_set) || line.starts_with(resp_push) {
		return rd.read_slice(line)!
	}
	if line.starts_with(resp_map) {
		return rd.read_map(line)!
	}
	return error("Can't parse ${line}")
}

fn (rd Reader) read_float(line string) !f64 {
	if line[1..] == 'inf' {
		return math.inf(1)
	}
	if line[1..] == '-inf' {
		return math.inf(-1)
	}
	if line[1..] == 'nan' || line[1..] == '-nan' {
		return math.nan()
	}
	return strconv.atof64(line[1..])!
}

fn (rd Reader) read_bool(line string) !bool {
	if line[1..] == 't' {
		return true
	}
	if line[1..] == 'f' {
		return false
	}
	return error("Can't parse bool reply: ${line}")
}

// fn (rd Reader) read_big_int(line string) !big.Integer {
// 	if i := big.integer_from_string(line[1..]) {
// 		return i
// 	} else {
// 		return error("Can't parse bigInt reply: ${line}")
// 	}
// }

fn (mut rd Reader) read_verb(line string) !string {
	s := rd.read_string_reply(line)!
	if s.len < 4 || s[3] != ':'[0] {
		return error("Can't parse verbatim string reply: ${line}")
	}
	return s[4..]
}

fn (mut rd Reader) read_slice(line string) ![]json.Any {
	// TODO n := reply_len(line)!

	mut val := []json.Any{} // TODO len: n
	for i := 0; i < val.len; i++ {
		if v := rd.read_reply() {
			val[i] = v
		} else {
			val[i] = err.msg()
		}
	}
	return val
}

fn (mut rd Reader) read_map(line string) !map[string]json.Any {
	n := reply_len(line)!
	mut m := map[string]json.Any{}
	for i := 0; i < n; i++ {
		k := rd.read_reply()! // expected string
		match k {
			string {
				if v := rd.read_reply() {
					m[k] = v
				} else {
					m[k] = err.msg()
				}
				return m
			}
			else {
				return error('Map expected string key but got ${typeof(k).name} instead')
			}
		}
	}
}

/*
*
*
* TODO
*
*
*/

pub fn (mut rd Reader) read_string() !string {
	line := rd.read_line()!

	if line.starts_with(resp_status) {
		return line.trim_string_left(resp_status)
	}
	if line.starts_with(resp_int) {
		return line.trim_string_left(resp_int)
	}
	if line.starts_with(resp_float) {
		return line.trim_string_left(resp_float)
	}
	if line.starts_with(resp_string) {
		return rd.read_string_reply(line)!
	}
	if line.starts_with(resp_bool) {
		b := rd.read_bool(line)!
		return '${b}'
	}
	if line.starts_with(resp_verbatim) {
		return rd.read_verb(line)
	}
	// if line.starts_with(resp_big_int) {
	// 	b := rd.read_big_int(line)!
	// 	return '${b}'
	// }
	return error("Can't parse reply=${line} reading string")
}
