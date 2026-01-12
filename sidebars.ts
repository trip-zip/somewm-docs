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
        'guides/input-devices',
        'guides/cli-control',
        'guides/multi-monitor',
        'guides/autostart',
        'guides/notifications',
        'guides/screenshots',
        'guides/fractional-scaling',
        'guides/widget-timers',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      items: [
        'reference/lua-libraries',
        'reference/screen',
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
        {
          type: 'category',
          label: 'wibox',
          items: [
            'reference/wibox/index',
            'reference/wibox/wibar',
          ],
        },
        'reference/layer_surface/index',
        'reference/naughty/index',
        'reference/gears/index',
        'reference/key-names',
        'reference/signals',
        'reference/somewm-client',
        'reference/default-keybindings',
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
