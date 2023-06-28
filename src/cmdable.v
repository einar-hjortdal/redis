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
	cmdable_function fn (cmd Cmder) !
}

fn (c Cmdable) ping() !StatusCmd {
	cmd := new_status_cmd('ping')
	c.cmdable_function(Cmder(cmd))! // https://github.com/vlang/v/issues/18701
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
	cmdable_stateful_function fn (cmd Cmder)
}

pub fn (c CmdableStateful) auth(password string) StatusCmd {
	cmd := new_status_cmd('auth', password)
	c.cmdable_stateful_function(Cmder(cmd))
	return cmd
}

pub fn (c CmdableStateful) auth_acl(username string, password string) StatusCmd {
	cmd := new_status_cmd('auth', username, password)
	c.cmdable_stateful_function(Cmder(cmd))
	return cmd
}

// It is called `select_db` because `select` is a reserved keyword.
pub fn (c CmdableStateful) select_db(index int) StatusCmd {
	cmd := new_status_cmd('select', index)
	c.cmdable_stateful_function(Cmder(cmd))
	return cmd
}
