# Attribution

somewm-docs incorporates structure, examples, and selectively reused prose from upstream projects. This file documents what is borrowed and from where, in compliance with their licenses.

## AwesomeWM

- Project: <https://github.com/awesomeWM/awesome>
- API docs: <https://awesomewm.org/apidoc/>
- Copyright © Julien Danjou and the AwesomeWM contributors
- License: GNU General Public License, version 2 or later

What is reused: page structure, heading ordering, table columns, property orderings, and short prose passages from the AwesomeWM API documentation. Reference pages that derive from a specific upstream page carry a `<FromAwesomeWM>` banner at the top naming the upstream source and the date of last sync.

## Diátaxis

- Project: <https://diataxis.fr/>
- Author: Daniele Procida
- License: CC BY-SA 4.0

The four-quadrant framework (tutorials, how-to guides, reference, explanation) is described and credited on the [intro page](docs/intro.md) and the [AwesomeWM compatibility page](docs/concepts/awesomewm-compat.md). Diátaxis is a methodology, not text incorporated wholesale, so attribution is by link.

## Code examples

Many examples are rewritten for Wayland-native idioms (the `output` object, `somewm-client`, fractional scaling, monitor hotplug semantics). Where an example is closely derived from an AwesomeWM sample, the GPL applies as above.

## License compatibility

somewm-docs is distributed under the GNU General Public License, version 3 or later (see [LICENSE](LICENSE)). AwesomeWM's GPL v2-or-later terms permit redistribution under any later GPL version, including v3, so the combination is consistent.
