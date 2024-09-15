# redis

Redis library for the V language.

## Features

- RESP version 3 only
- [Commands](src/cmdable.v)
- Aumtomatic connection pool

## Usage

Install with `v install Coachonko.redis`

```V
import coachonko.redis

// Configure.
mut ro := redis.Options{
  // refer to the options.v file
}

// Create a new client.
client := new_client(mut opts)

// Issue commands as Client methods.
// Supported commands are listed in the `cmdable.v` file.
mut result := client.set('test_key', 'test_value', 0)!

// Get the value from results
result = client.get('test_key')!
println(result.val())
```

## Notes

This library is developed against [Redict](https://redict.io/).

Pull requests are very welcome. Please look at [CONTRIBUTING.md](./CONTRIBUTING.md) and at [TODO.md](./TODO.md) 
files. Open issues for problems you encounter, reach out to me and the other contributors on [V's Discord](https://discord.gg/vlang).
