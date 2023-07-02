# TODO

In no particular order.

## Throughout

- Document creation of a client and issuing commands in README.md
- Add tests
- Add context
- Do not use `json.Any`

## Options

- Add support for unix socket connections
- Parse connection strings with net.URL

## Pool

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

## Proto

### Reader

- `Reader`'s `reader.read_line()` behavior is unknown. Does it need cache to prevent buffer-full errors?
- `big number` can be parsed to `big.Integer`

### Writer

- Handle `[]json.Any` and `map[string]json.Any`.