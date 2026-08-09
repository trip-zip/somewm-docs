import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  fromScratchSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Chapters',
      collapsed: false,
      items: [
        'chapters/00-default',
        'chapters/01-theme',
        'chapters/02-keybindings',
        'chapters/03-widgets',
        'chapters/04-wibar',
        'chapters/05-rules-titlebars',
        'chapters/06-notifications',
        'chapters/07-exitscreen',
        'chapters/08-mainmenu',
        'chapters/09-switcher',
        'chapters/10-launcher',
        'chapters/11-dashboard',
        'chapters/12-lockscreen',
      ],
    },
  ],
};

export default sidebars;
