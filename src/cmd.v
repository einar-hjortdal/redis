module redis

import pool.proto
// import time
import x.json2 as json

/*
*
*
* Cmder
*
*
*/

pub interface Cmder {
	name() string
	full_name() string
	args() []json.Any
	cmd_string() string
	arg_string(int) string
	first_key_pos() int
	// read_timeout() time.Duration
	err() string
mut:
	set_first_key_pos(int)
	read_reply(mut rd proto.Reader) !
	set_err(string)
}

fn write_cmds(mut wr proto.Writer, cmds []Cmder) ! {
	for cmd in cmds {
		write_cmd(mut wr, cmd) or { return err }
	}
}

fn write_cmd(mut wr proto.Writer, cmd Cmder) ! {
	return wr.write_args(cmd.args())
}

fn cmd_string(cmd Cmder, val json.Any) string {
	mut b := ''

	for i, arg in cmd.args() {
		if i > 0 {
			b += ' '
		}
		b += '${arg}'
	}

	e := cmd.err()
	if e != '' {
		b += ': ${e}'
	} else if val !is json.Null {
		b += ': ${val}'
	}

	return b
}

/*
*
*
* BaseCmd
*
*
*/

struct BaseCmd {
	args []json.Any
mut:
	err     string
	key_pos int
}

pub fn (cmd BaseCmd) name() string {
	if cmd.args.len == 0 {
		return ''
	}
	return to_lower(cmd.arg_string(0))
}

pub fn (cmd BaseCmd) full_name() string {
	mut name := cmd.name()
	match name {
		'cluster', 'command' {
			if cmd.args.len == 1 {
				return name
			}
			if cmd.args[1] is string {
				return '${name} ${cmd.args[1]}'
			}
			return name
		}
		else {
			return name
		}
	}
}

pub fn (cmd BaseCmd) args() []json.Any {
	return cmd.args
}

fn (cmd BaseCmd) arg_string(pos int) string {
	if pos < 0 || pos >= cmd.args.len {
		return ''
	}
	arg := cmd.args[pos]
	match arg {
		string {
			return arg
		}
		else {
			return '${arg}'
		}
	}
}

fn (cmd BaseCmd) first_key_pos() int {
	return cmd.key_pos
}

fn (mut cmd BaseCmd) set_first_key_pos(key_pos int) {
	cmd.key_pos = key_pos
}

fn (mut cmd BaseCmd) set_err(e string) {
	cmd.err = e
}

fn (cmd BaseCmd) err() string {
	return cmd.err
}

/*
*
*
* Cmd
*
*
*/

struct Cmd {
	BaseCmd
mut:
	val json.Any
}

/*
*
*
* StatusCmd
*
*
*/

pub struct StatusCmd {
	BaseCmd
mut:
	val string
}

fn new_status_cmd(args ...json.Any) StatusCmd {
	return StatusCmd{
		BaseCmd: BaseCmd{
			args: args
		}
	}
}

fn (mut cmd StatusCmd) set_val(val string) {
	cmd.val = val
}

fn (cmd StatusCmd) val() string {
	return cmd.val
}

fn (cmd StatusCmd) result() !string {
	if cmd.val != '' {
		return cmd.val
	} else {
		return cmd.err
	}
}

fn (cmd StatusCmd) cmd_string() string {
	return cmd_string(cmd, cmd.val)
}

fn (mut cmd StatusCmd) read_reply(mut rd proto.Reader) ! {
	cmd.val = rd.read_string()!
}
