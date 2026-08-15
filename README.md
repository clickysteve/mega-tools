# mega-tools

A single browser-friendly home for the tools around
[**GENMDDJ**](https://github.com/little-scale/genmddj), a Sega Mega Drive
music tracker by [little-scale](https://github.com/little-scale) (Sebastian
Tomczak). Live at [clickysteve.github.io/mega-tools](https://clickysteve.github.io/mega-tools/).

## What this is, and isn't

GENMDDJ ships its own suite of browser tools (`user-tools/` in that repo) for
patching a ROM, converting songs, managing saves, and so on. This repo is a
convenience wrapper around that suite: one landing page, one place to open
any of them, kept in sync with upstream. It isn't a fork or a competing
project, almost everything here is little-scale's original work, copied in
as-is.

Two things here are actually mine, built during a testing/contribution pass
on GENMDDJ and since submitted upstream:

- A handful of features added to the **palette patcher** (slot reorder,
  copy/paste, per-colour hex entry, Export All)
- The **GENMDDJ Web Player**, a browser port of the project's experimental
  native player, running the real ROM through a WebAssembly build of
  Genesis Plus GX entirely client-side

Both are (or are becoming) part of GENMDDJ proper; they live here too so
this site stays a complete, current set.

## Structure

```
index.html      landing page -- reads tools.json, renders a card per tool
tools.json      the tool registry: name, path, category, description
tools/          single-file tools, copied straight from genmddj/user-tools/
webplayer/      the web player (multiple files: core, ROM, license notice)
sync-tools.sh   pulls the latest single-file tools from upstream genmddj
```

## Keeping this up to date

```sh
./sync-tools.sh
```

Pulls the latest `genmddj` master, copies over anything in `tools/` that's
changed, and flags any upstream tool that doesn't have a `tools.json` entry
yet (new tools need one added by hand, see the comment at the top of
`index.html`). Review with `git diff`, commit, push.

## License

The GENMDDJ tools themselves (`tools/*.html`) are MIT-licensed by Sebastian
Tomczak, see [`LICENSE`](./LICENSE). The web player's own code is the same;
the **compiled Genesis Plus GX core it bundles is not** — that's
non-commercial-use software with its own terms, see
[`webplayer/NOTICE.md`](./webplayer/NOTICE.md) before using this site's
player output anywhere commercial.
