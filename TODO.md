# TODO

In no particular order.

## Throughout

- Only support RESP 3
- Document creation of a client and issuing commands in README.md
- Add tests
- Add context
- Eliminate `json.Any`
- Add logger
- Use more `&Struct`
- Define most structs as `[heap]`

## Options

- Add support for unix socket connections
- Parse connection strings with net.URL

## Pool

- Send `HELLO 3` on connection to ensure RESP 3 protocol is being used
- Add timeout
- Max idle time
- Max life time
- implement `StickyConnectionPool`

## Client

- Implement [cluster](https://docs.keydb.dev/docs/cluster-spec/) client
- Implement [pipeline](https://docs.keydb.dev/docs/pipelining/)
- Implement [pub/sub](https://docs.keydb.dev/docs/pubsub/)
- Implement retry_backoff
- Handle errors properly
- Implement hooks: provide a way to modify or customize the behavior of specific stages in the command 
  execution process. Allow users to inject additional logic before or after a command is executed (such 
  as logging).

## Cmd

- Format `BaseCmd.string_arg` returned string with `append_arg` instead of using string interpolation.

## Cmdable

- Add `do` API to issue unsupported commands
- Support all commands listed [here](https://docs.keydb.dev/docs/commands)
- `get` should return a `nil` result instead of an error when `key` does not exist https://docs.keydb.dev/docs/commands/#get. 
  At the moment, Cmdable returns an error with a string `'nil'`. It would be better to have a dedicated 
  property for nil results.

## Proto

### Reader

- `big number` can be parsed to `big.Integer`

### Writer

- Handle `[]json.Any` and `map[string]json.Any`.