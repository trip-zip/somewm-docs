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

  plugins: [
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'kiln',
        path: 'kiln',
        routeBasePath: '/kiln',
        sidebarPath: './sidebarsKiln.ts',
        editUrl: 'https://github.com/trip-zip/somewm-docs/tree/main/',
      },
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'from-scratch',
        path: 'from-scratch',
        routeBasePath: '/from-scratch',
        sidebarPath: './sidebarsFromScratch.ts',
        editUrl: 'https://github.com/trip-zip/somewm-docs/tree/main/',
        // Chapter files are 00-default.md .. 12-lockscreen.md and their URLs
        // must keep the numeric prefix (the checkpoint branch READMEs link
        // to /from-scratch/chapters/NN-<name>), so don't strip it.
        numberPrefixParser: false,
      },
    ],
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/trip-zip/somewm-docs/tree/main/',
          routeBasePath: '/docs',
          lastVersion: '1.4',
          versions: {
            current: {
              label: '2.0 (dev)',
              banner: 'unreleased',
            },
            '1.4': {
              label: '1.4',
            },
          },
        },
        blog: {
          showReadingTime: true,
          editUrl: 'https://github.com/trip-zip/somewm-docs/tree/main/',
        },
        sitemap: {},
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themes: [
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        indexBlog: true,
        docsRouteBasePath: ['/docs', '/kiln', '/from-scratch'],
        highlightSearchTermsOnTargetPage: true,
        searchContextByPaths: [
          {label: 'SomeWM', path: 'docs'},
          {label: 'kiln', path: 'kiln'},
          {label: 'From Scratch', path: 'from-scratch'},
        ],
        useAllContextsWithNoSearchContext: true,
      },
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
          type: 'docSidebar',
          sidebarId: 'fromScratchSidebar',
          docsPluginId: 'from-scratch',
          position: 'left',
          label: 'From Scratch',
        },
        {
          to: '/blog',
          label: 'Blog',
          position: 'left',
        },
        {
          type: 'docsVersionDropdown',
          position: 'left',
        },
        {
          type: 'docSidebar',
          sidebarId: 'kilnSidebar',
          docsPluginId: 'kiln',
          position: 'right',
          label: 'Kiln',
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
          title: 'SomeWM',
          items: [
            {label: 'Getting Started', to: '/docs/getting-started/installation'},
            {label: 'Tutorials', to: '/docs/tutorials/basics'},
            {label: 'From Scratch', to: '/from-scratch'},
            {label: 'Reference', to: '/docs/reference/lua-libraries'},
            {label: 'Blog', to: '/blog'},
          ],
        },
        {
          title: 'kiln',
          items: [
            {label: 'Overview', to: '/kiln'},
            {label: 'Installation', to: '/kiln/getting-started/installation'},
            {label: 'Reference', to: '/kiln/reference/'},
            {label: 'kiln vs SomeWM', to: '/kiln/concepts/kiln-vs-somewm'},
            {label: 'Source Code', href: 'https://github.com/trip-zip/kiln'},
          ],
        },
        {
          title: 'Community',
          items: [
            {label: 'Discussions', href: 'https://github.com/trip-zip/somewm/discussions'},
            {label: 'AwesomeWM', href: 'https://awesomewm.org/community/'},
            {label: 'Source Code', href: 'https://github.com/trip-zip/somewm'},
          ],
        },
      ],
      copyright: `© ${new Date().getFullYear()} SomeWM Contributors. Portions copyright the AwesomeWM contributors. Licensed under GPL v3 or later — see <a href="https://github.com/trip-zip/somewm-docs/blob/main/LICENSE">LICENSE</a> and <a href="https://github.com/trip-zip/somewm-docs/blob/main/ATTRIBUTION.md">ATTRIBUTION</a>.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['lua', 'bash'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
