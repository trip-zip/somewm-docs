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
        sitemap: {
          // /kiln is live but unlisted: reachable by URL, absent from the
          // sitemap, search index, navbar, and footer.
          ignorePatterns: ['/kiln/**'],
        },
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
        docsRouteBasePath: '/docs',
        highlightSearchTermsOnTargetPage: true,
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
          to: '/blog',
          label: 'Blog',
          position: 'left',
        },
        {
          type: 'docsVersionDropdown',
          position: 'left',
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
        {label: 'Getting Started', to: '/docs/getting-started/installation'},
        {label: 'Tutorials', to: '/docs/tutorials/basics'},
        {label: 'Reference', to: '/docs/reference/lua-libraries'},
        {label: 'Blog', to: '/blog'},
        {label: 'Discussions', href: 'https://github.com/trip-zip/somewm/discussions'},
        {label: 'AwesomeWM', href: 'https://awesomewm.org/community/'},
        {label: 'Source Code', href: 'https://github.com/trip-zip/somewm'},
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
