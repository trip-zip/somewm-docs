import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  kilnSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'getting-started/installation',
        'getting-started/first-launch',
        'getting-started/rc-anatomy',
      ],
    },
    {
      type: 'category',
      label: 'Tutorials',
      items: [
        'tutorials/basics',
        'tutorials/keybindings',
        'tutorials/a-bar-from-scratch',
        'tutorials/widgets',
        'tutorials/theming',
      ],
    },
    {
      type: 'category',
      label: 'How-To Guides',
      items: [
        'guides/client-rules',
        'guides/custom-layouts',
        'guides/floating-and-placement',
        'guides/menus',
        'guides/notifications',
        'guides/replace-default-policies',
        'guides/multi-monitor',
        'guides/input-devices',
        'guides/lockscreen-and-idle',
        'guides/wallpaper',
        'guides/screenshots',
        'guides/hotkeys-popup',
        'guides/app-launcher',
        'guides/data-widgets',
        'guides/spawn-lifecycle',
        'guides/tag-persistence',
        'guides/ipc-and-scripting',
        'guides/reload-and-debugging',
        'guides/testing-headless',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      items: [
        'concepts/the-clay-thesis',
        'concepts/frames-and-dirty',
        'concepts/object-model',
        'concepts/nodes-floats-and-bands',
        'concepts/c-lua-boundary',
        'concepts/kiln-vs-somewm',
        'concepts/limitations',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      items: [
        'reference/index',
        {
          type: 'category',
          label: 'Objects',
          items: [
            'reference/client',
            'reference/tag',
            'reference/screen',
            'reference/layer',
            'reference/notification',
          ],
        },
        'reference/some',
        'reference/ui',
        'reference/layout',
        'reference/keybindings-and-rules',
        'reference/defaults',
        'reference/placement',
        'reference/theme-variables',
        'reference/signals',
        'reference/core',
        'reference/events',
        'reference/environment-and-ipc',
      ],
    },
    'faq',
  ],
};

export default sidebars;
