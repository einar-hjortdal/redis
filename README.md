# redis

Redis library for the V language.

## Features

- Compatible with [RESP3 protocol](https://github.com/redis/redis-specifications/blob/master/protocol/RESP3.md)
- Managed connection pool

## Usage

Install with `v install Coachonko.redis`

```V
import coachonko.redis

```

Supported commands are listed in the `cmdable.v` file.

## Ecosystem

- [Coachonko/sessions](https://github.com/Coachonko/sessions)
- [Coachonko/cache](https://github.com/Coachonko/cache)

## Notes

This library is developed against [KeyDB](https://github.com/Snapchat/KeyDB/). I do not use Redis itself, 
but given that KeyDB is a drop-in replacement for Redis, it should work as expected with Redis.

Pull requests are very welcome. Please look at [CONTRIBUTING.md](./CONTRIBUTING.md) and at [TODO.md](./TODO.md) 
files. Open issues for problems you encounter, reach out to me and the other contributors on [V's Discord](https://discord.gg/vlang).
