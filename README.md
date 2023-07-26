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

```

Supported commands are listed in the `cmdable.v` file.

## Ecosystem

- [Coachonko/sessions](https://github.com/Coachonko/sessions)
- [Coachonko/cache](https://github.com/Coachonko/cache)

## Notes

This library is developed against [KeyDB](https://github.com/Snapchat/KeyDB/), a multithreaded drop-in 
replacement for Redis backed by [Snap](https://snap.com/).

Pull requests are very welcome. Please look at [CONTRIBUTING.md](./CONTRIBUTING.md) and at [TODO.md](./TODO.md) 
files. Open issues for problems you encounter, reach out to me and the other contributors on [V's Discord](https://discord.gg/vlang).
