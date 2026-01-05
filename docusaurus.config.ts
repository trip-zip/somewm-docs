import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'SomeWM',
  tagline: 'AwesomeWM on Wayland',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://somewm.org',
  baseUrl: '/',

  organizationName: 'trip-zip',
  projectName: 'somewm-docs',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/trip-zip/somewm-docs/tree/main/',
          routeBasePath: '/', // Docs at root, no /docs prefix
        },
        blog: false, // Disable blog
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/somewm-social-card.png',
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'SomeWM',
      logo: {
        alt: 'SomeWM Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://github.com/trip-zip/somewm',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {label: 'Getting Started', to: '/getting-started/installation'},
            {label: 'Tutorials', to: '/tutorials/basics'},
            {label: 'Reference', to: '/reference/awful-input'},
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'GitHub Discussions',
              href: 'https://github.com/trip-zip/somewm/discussions',
            },
            {
              label: 'AwesomeWM Community',
              href: 'https://awesomewm.org/community/',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Source Code',
              href: 'https://github.com/trip-zip/somewm',
            },
            {
              label: 'AwesomeWM Docs',
              href: 'https://awesomewm.org/doc/api/',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} SomeWM Contributors. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['lua', 'bash'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
