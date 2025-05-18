# TODO

## Questions for Tuesday 20

- Is it okay to use additional (also open-source) python packages for automated tests?

## Tools for convenience

`tmux` makes switching between docker and linux easier. I personally distrust the VS Code intergrated command line.

### Install

```bash
sudo apt install tmux
```

### Basic use

All commands are prefixed by Control + B (`^B`).

`tmux`

New window: `^B ^C`

Next window: `^B ^N`

Previous window: `^B ^P`

Rename window: `^B ,`

Enter scroll mode: `^B [`

Scroll: PgUp / PgDn

Exit bash (close window): `exit` or `^D`
