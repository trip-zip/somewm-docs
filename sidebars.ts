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
        'tutorials/basics',
        'tutorials/widgets',
        'tutorials/keybindings',
        'tutorials/theme',
        'tutorials/wibar',
      ],
    },
    {
      type: 'category',
      label: 'How-To Guides',
      items: [
        'guides/autostart',
        'guides/client-rules',
        'guides/cli-control',
        'guides/debugging',
        'guides/fractional-scaling',
        'guides/input-devices',
        'guides/keyboard-layouts',
        'guides/multi-monitor',
        'guides/notifications',
        'guides/screenshots',
        'guides/shadows',
        'guides/wallpaper-caching',
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
            'reference/awful/input',
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
        'reference/default-keybindings',
        'reference/key-names',
        'reference/layer_surface/index',
        'reference/screen',
        'reference/shadows',
        'reference/signals',
        'reference/somewm-client',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      items: [
        'concepts/object-model',
        'concepts/architecture',
        'concepts/wayland-vs-x11',
        'concepts/display-scaling',
        'concepts/wallpaper-caching',
        'concepts/client-stack',
        'concepts/focus-history',
        'concepts/scene-graph',
        'concepts/awesomewm-compat',
      ],
    },
    'faq',
    'troubleshooting',
  ],
};

export default sidebars;
