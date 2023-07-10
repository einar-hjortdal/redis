module redis

import arrays
import time
import x.json2 as json

fn use_precise(duration time.Duration) bool {
	return duration < time.second || duration % time.second != 0
}

fn format_ms(duration time.Duration) i64 {
	if duration > 0 && duration < time.millisecond {
		return 1
	}
	return i64(duration / time.millisecond)
}

fn format_sec(duration time.Duration) i64 {
	if duration > 0 && duration < time.second {
		return 1
	}
	return i64(duration / time.second)
}

/*
*
*
* Cmdable
*
*
*/

struct Cmdable {
mut:
	cmdable_function fn (cmd &Cmder) !
}

fn (c Cmdable) ping() !&StatusCmd {
	cmd := new_status_cmd('ping')
	c.cmdable_function(cmd)!
	return cmd
}

// func (c cmdable) Del(ctx context.Context, keys ...string) *IntCmd {
// 	args := make([]interface{}, 1+len(keys))
// 	args[0] = "del"
// 	for i, key := range keys {
// 		args[1+i] = key
// 	}
// 	cmd := NewIntCmd(ctx, args...)
// 	_ = c(ctx, cmd)
// 	return cmd
// }

fn (c Cmdable) get(key string) !&StringCmd {
	cmd := new_string_cmd('get', key)
	c.cmdable_function(cmd)!
	return cmd
}

// set issues a `SET key value [expiration]` command.
// Zero expiration means the key has no expiration time.
fn (c Cmdable) set(key string, value string, expiration time.Duration) !&StatusCmd {
	mut args := []json.Any{}
	args << 'set'
	args << key
	args << value
	if expiration > 0 {
		if use_precise(expiration) {
			args = arrays.concat(args, 'px', format_ms(expiration))
		} else {
			args = arrays.concat(args, 'ex', format_sec(expiration))
		}
	}
	cmd := new_status_cmd(...args)
	c.cmdable_function(cmd)!
	return cmd
}

/*
*
*
* CmdableStateful
*
*
*/

struct CmdableStateful {
	Cmdable
mut:
	cmdable_stateful_function fn (cmd &Cmder) !
}

pub fn (c CmdableStateful) auth(password string) !&StatusCmd {
	cmd := new_status_cmd('auth', password)
	c.cmdable_stateful_function(cmd)!
	return cmd
}

pub fn (c CmdableStateful) auth_acl(username string, password string) !&StatusCmd {
	cmd := new_status_cmd('auth', username, password)
	c.cmdable_stateful_function(cmd)!
	return cmd
}

// It is called `select_db` because `select` is a reserved keyword.
pub fn (c CmdableStateful) select_db(index int) !&StatusCmd {
	cmd := new_status_cmd('select', index)
	c.cmdable_stateful_function(cmd)!
	return cmd
}
