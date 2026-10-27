import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting started',
      collapsed: false,
      items: [
        'getting-started/installation',
        'getting-started/first-launch',
        'getting-started/migrating',
        'getting-started/upgrading-from-2.0',
      ],
    },
    {
      type: 'category',
      label: 'Tutorials',
      link: {type: 'doc', id: 'tutorials/index'},
      items: [
        'tutorials/try-somewm-without-installing',
        'tutorials/basics',
        'tutorials/widgets',
        'tutorials/wibar',
        'tutorials/keybindings',
        'tutorials/theme',
        'tutorials/carousel',
      ],
    },
    {
      type: 'category',
      label: 'How-to guides',
      link: {type: 'doc', id: 'guides/index'},
      items: [
        {
          type: 'category',
          label: 'Bar and widgets',
          items: [
            'guides/custom-widgets',
            'guides/widget-timers',
            'guides/wibar-background-image',
            'guides/notifications',
            'guides/animation',
          ],
        },
        {
          type: 'category',
          label: 'Windows and layouts',
          items: [
            'guides/client-rules',
            'guides/focus',
            'guides/react-to-client-lifecycle',
            'guides/rounded-corners',
            'guides/shadows',
            'guides/custom-layouts',
            'guides/carousel-column-widths',
            'guides/carousel-centering',
            'guides/carousel-gestures',
            'guides/carousel-stacking',
          ],
        },
        {
          type: 'category',
          label: 'Input',
          items: [
            'guides/keybinding-patterns',
            'guides/keyboard-layouts',
            'guides/input-devices',
          ],
        },
        {
          type: 'category',
          label: 'Displays',
          items: [
            'guides/multi-monitor',
            'guides/fractional-scaling',
            'guides/tag-persistence',
          ],
        },
        {
          type: 'category',
          label: 'Session',
          items: [
            'guides/autostart',
            'guides/lockscreen',
            'guides/screenshots',
          ],
        },
        {
          type: 'category',
          label: 'Config and debugging',
          items: [
            'guides/replace-default-handler',
            'guides/defer-startup-with-request-rules',
            'guides/cli-control',
            'guides/debugging',
            'guides/testing-with-nested-compositor',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      link: {type: 'doc', id: 'reference/index'},
      items: [
        {
          type: 'category',
          label: 'Libraries',
          items: [
            {
              type: 'category',
              label: 'awful',
              link: {type: 'doc', id: 'reference/awful/index'},
              items: [
                'reference/awful/accessibility',
                'reference/awful/carousel',
                'reference/awful/input',
                'reference/awful/layout',
                'reference/awful/screenshot',
              ],
            },
            {
              type: 'category',
              label: 'beautiful',
              link: {type: 'doc', id: 'reference/beautiful/index'},
              items: [
                'reference/beautiful/theme-variables',
              ],
            },
            'reference/gears/index',
            'reference/naughty/index',
            {
              type: 'category',
              label: 'wibox',
              link: {type: 'doc', id: 'reference/wibox/index'},
              items: [
                'reference/wibox/common',
                'reference/wibox/wibar',
                {
                  type: 'category',
                  label: 'Widgets',
                  items: [
                    'reference/wibox/widget/calendar',
                    'reference/wibox/widget/checkbox',
                    'reference/wibox/widget/graph',
                    'reference/wibox/widget/imagebox',
                    'reference/wibox/widget/piechart',
                    'reference/wibox/widget/progressbar',
                    'reference/wibox/widget/separator',
                    'reference/wibox/widget/slider',
                    'reference/wibox/widget/systray',
                    'reference/wibox/widget/textbox',
                    'reference/wibox/widget/textclock',
                  ],
                },
                {
                  type: 'category',
                  label: 'Containers',
                  items: [
                    'reference/wibox/container/arcchart',
                    'reference/wibox/container/background',
                    'reference/wibox/container/constraint',
                    'reference/wibox/container/margin',
                    'reference/wibox/container/mirror',
                    'reference/wibox/container/place',
                    'reference/wibox/container/radialprogressbar',
                    'reference/wibox/container/rotate',
                    'reference/wibox/container/scroll',
                    'reference/wibox/container/tile',
                  ],
                },
              ],
            },

          ],
        },
        {
          type: 'category',
          label: 'Objects',
          items: [
            'reference/screen',
            'reference/output',
            'reference/layer_surface/index',
          ],
        },
        'reference/key-names-all',
        'reference/rc-lua-anatomy',
        'reference/deviations',
        'reference/default-keybindings',
        'reference/key-names',
        'reference/lock',
        'reference/lockscreen',
        'reference/shadows',
        'reference/signals',
        'reference/somewm-client',
        'reference/tag-persistence',
        'reference/wayland-protocols',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      link: {type: 'doc', id: 'concepts/index'},
      items: [
        {
          type: 'category',
          label: 'Start here',
          items: [
            'concepts/why-somewm',
            'concepts/object-model',
            'concepts/signals',
            'concepts/architecture',
          ],
        },
        {
          type: 'category',
          label: 'Layout and rendering',
          items: [
            'concepts/how-somewm-draws',
            'concepts/widgets-in-the-tree',
            'concepts/clients-in-the-tree',
            'concepts/reading-the-tree',
            'concepts/scene-graph',
          ],
        },
        {
          type: 'category',
          label: 'Windows and tags',
          items: [
            'concepts/client-stack',
            'concepts/focus-history',
            'concepts/master-and-stack',
            'concepts/scrollable-tiling',
            'concepts/tag-persistence',
          ],
        },
        {
          type: 'category',
          label: 'Platform',
          items: [
            'concepts/awesomewm-compat',
            'concepts/wayland-vs-x11',
            'concepts/display-scaling',
            'concepts/lockscreen',
            'concepts/screenshots',
            'concepts/test-mode',
          ],
        },
      ],
    },
    'faq',
    'troubleshooting'
  ],
};

export default sidebars;
