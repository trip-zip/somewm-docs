import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'getting-started/installation',
        'getting-started/first-launch',
        'getting-started/migrating',
      ],
    },
    {
      type: 'category',
      label: 'Tutorials',
      items: [
        'tutorials/try-somewm-without-installing',
        'tutorials/basics',
        'tutorials/theme',
        'tutorials/widgets',
        'tutorials/keybindings',
        'tutorials/wibar',
        'tutorials/carousel',
        // From Scratch is hidden on 2.0: the series is built on the 1.4
        // default config and 2.0's has moved on. The pages still exist under
        // docs/tutorials/from-scratch/, marked `unlisted: true`, until the
        // series is rebuilt for 2.0. The 1.4 sidebar still carries it.
      ],
    },
    {
      type: 'category',
      label: 'How-To Guides',
      items: [
        'guides/autostart',
        'guides/client-rules',
        'guides/replace-default-handler',
        'guides/react-to-client-lifecycle',
        'guides/focus',
        'guides/keybinding-patterns',
        'guides/defer-startup-with-request-rules',
        'guides/cli-control',
        'guides/custom-layouts',
        'guides/carousel-column-widths',
        'guides/carousel-centering',
        'guides/carousel-gestures',
        'guides/carousel-stacking',
        'guides/debugging',
        'guides/testing-with-nested-compositor',
        'guides/fractional-scaling',
        'guides/input-devices',
        'guides/keyboard-layouts',
        'guides/lockscreen',
        'guides/multi-monitor',
        'guides/tag-persistence',
        'guides/notifications',
        'guides/screenshots',
        'guides/shadows',
        'guides/wallpaper-caching',
        'guides/wibar-background-image',
        'guides/widget-timers',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      items: [
        'reference/lua-libraries',
        // AwesomeWM libraries (alphabetical)
        {
          type: 'category',
          label: 'awful',
          items: [
            'reference/awful/index',
            'reference/awful/layout',
            'reference/awful/carousel',
            'reference/awful/input',
            'reference/awful/screenshot',
          ],
        },
        {
          type: 'category',
          label: 'beautiful',
          items: [
            'reference/beautiful/index',
            'reference/beautiful/theme-variables',
          ],
        },
        'reference/gears/index',
        'reference/naughty/index',
        {
          type: 'category',
          label: 'wibox',
          items: [
            'reference/wibox/index',
            'reference/wibox/wibar',
          ],
        },
        // SomeWM-specific (alphabetical)
        'reference/output',
        'reference/default-keybindings',
        'reference/rc-lua-anatomy',
        'reference/deviations',
        'reference/key-names',
        'reference/key-names-all',
        'reference/lock',
        'reference/lockscreen',
        'reference/layer_surface/index',
        'reference/screen',
        'reference/tag-persistence',
        'reference/wayland-protocols',
        'reference/shadows',
        'reference/signals',
        'reference/somewm-client',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      items: [
        'concepts/why-somewm',
        'concepts/object-model',
        'concepts/architecture',
        'concepts/signals',
        'concepts/wayland-vs-x11',
        'concepts/display-scaling',
        'concepts/wallpaper-caching',
        'concepts/client-stack',
        'concepts/master-and-stack',
        'concepts/scrollable-tiling',
        'concepts/focus-history',
        'concepts/lockscreen',
        'concepts/screenshots',
        'concepts/tag-persistence',
        'concepts/scene-graph',
        'concepts/awesomewm-compat',
        'concepts/test-mode',
      ],
    },
    'faq',
    'troubleshooting',
  ],
};

export default sidebars;
