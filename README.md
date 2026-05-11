# somewm-docs

Documentation for [somewm](https://github.com/trip-zip/somewm), a Wayland compositor with an AwesomeWM-compatible Lua API. Lives at [somewm.org](https://somewm.org).

The docs aim to be *self-sufficient* — a complete reference for SomeWM users — so you don't need to bounce between sites. Organized via the [Diátaxis framework](https://diataxis.fr/) for clearer separation of tutorials, how-to guides, reference, and concepts. See [`docs/intro.md`](docs/intro.md) for what these docs aim to be.

## License

Documentation is licensed under the GNU General Public License, version 3 or later. See [LICENSE](LICENSE). Portions are derived from the AwesomeWM project (GPL v2 or later); see [ATTRIBUTION.md](ATTRIBUTION.md).

## Local development

Built with [Docusaurus](https://docusaurus.io/).

## Installation

```bash
yarn
```

## Local Development

```bash
yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

## Build

```bash
yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

## Deployment

Using SSH:

```bash
USE_SSH=true yarn deploy
```

Not using SSH:

```bash
GIT_USER=<Your GitHub username> yarn deploy
```

If you are using GitHub pages for hosting, this command is a convenient way to build the website and push to the `gh-pages` branch.
