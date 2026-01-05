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
        'reference/awful-input',
        'reference/somewm-client',
        'reference/default-keybindings',
        'reference/signals',
        'reference/awesomewm-apis',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      items: [
        'concepts/object-model',
        'concepts/architecture',
        'concepts/wayland-vs-x11',
        'concepts/scene-graph',
        'concepts/awesomewm-compat',
      ],
    },
    'faq',
    'troubleshooting',
  ],
};

export default sidebars;
