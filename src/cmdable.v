module redis

// import time
// import x.json2 as json

/*
*
*
* Cmdable
*
*
*/

struct Cmdable {
mut:
	cmdable_function fn (mut cmd Cmder) !
}

fn (c Cmdable) ping() !StatusCmd {
	mut cmd := new_status_cmd('ping')
	c.cmdable_function(mut cmd)!
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
	cmdable_stateful_function fn (mut cmd Cmder)
}

pub fn (c CmdableStateful) auth(password string) StatusCmd {
	mut cmd := new_status_cmd('auth', password)
	c.cmdable_stateful_function(mut cmd)
	return cmd
}

pub fn (c CmdableStateful) auth_acl(username string, password string) StatusCmd {
	mut cmd := new_status_cmd('auth', username, password)
	c.cmdable_stateful_function(mut cmd)
	return cmd
}

// It is called `select_db` because `select` is a reserved keyword.
pub fn (c CmdableStateful) select_db(index int) StatusCmd {
	mut cmd := new_status_cmd('select', index)
	c.cmdable_stateful_function(mut cmd)
	return cmd
}
