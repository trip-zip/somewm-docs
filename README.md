# somewm-docs

Documentation for [somewm](https://github.com/trip-zip/somewm), a Wayland compositor with an AwesomeWM-compatible Lua API. Lives at [somewm.org](https://somewm.org).

The docs aim to provide a complete reference for SomeWM users. The [Diátaxis framework](https://diataxis.fr/) separates tutorials, how-to guides, reference and concepts. See [`docs/intro.md`](docs/intro.md), rendered as the [development documentation](https://somewm.org/docs/next/intro).

## Compatibility documentation

| Content | Maintained home |
| --- | --- |
| Supported APIs and behaviour | The selected version's `reference/` pages |
| AwesomeWM and Wayland differences | The selected version's `reference/deviations.md` compatibility index |
| Configuration changes between releases | The destination version's `getting-started/upgrading-from-*.md` guide |
| Architectural reasons | The selected version's `concepts/` pages |

`docs/` is 2.1 development documentation. `versioned_docs/version-2.0/` and `versioned_docs/version-1.4/` describe those releases. Verify behaviour against the matching source version before changing a versioned page. The 1.4 line mirrors AwesomeWM master; 2.x develops independently.

Keep existing page URLs and useful anchors when reorganising content. Use relative Markdown links within a version; an absolute `/docs/` link selects the default release. Cross-version links must name the destination release in their label.

Record a behaviour in its API reference and link to it from the compatibility index. Upgrade guides explain what a configuration must change and point to concepts for the reason. The source repository's `DEVIATIONS.md` contains navigation links only.

Before publishing, run `npm run typecheck` and `npm run build`, check affected examples in an isolated compositor, and review the generated version-specific links.

## License

Documentation is licensed under the GNU General Public License, version 3 or later. See [LICENSE](LICENSE). Portions are derived from the AwesomeWM project (GPL v2 or later); see [ATTRIBUTION.md](ATTRIBUTION.md).
