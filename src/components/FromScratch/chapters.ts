/**
 * The Awesome From Scratch chapter ladder, in order.
 *
 * Single source of truth for the sequence. `ChapterNav`, `NextChapter`, and
 * `ChapterList` all read from here, so the prev/next chain, the overview list,
 * and the "chapter NN of 12" counter cannot drift apart.
 *
 * `slug` matches three things at once: the file name in
 * `docs/tutorials/from-scratch/`, the URL segment, and the git branch in
 * trip-zip/awesome-from-scratch. Keep them identical.
 *
 * The sidebar labels in `sidebars.ts` are `NN · label`.
 */

export interface Chapter {
  /** Two-digit chapter number, '00' through '12'. */
  num: string;
  /** File name, URL segment, and checkpoint branch name. */
  slug: string;
  /** Short name, used in the sidebar and in the nav components. */
  label: string;
  /** Full page title, used in the "next chapter" card. */
  title: string;
  /** One line on what this chapter adds to the config. */
  blurb: string;
}

export const chapters: Chapter[] = [
  {
    num: '00',
    slug: '00-default',
    label: 'The Default Config',
    title: 'The Default Config',
    blurb:
      'The baseline. What the stock rc.lua already does, and how to test a change in a nested session instead of your real desktop.',
  },
  {
    num: '01',
    slug: '01-theme',
    label: 'Theme',
    title: 'Theme: Palettes, Shapes, Recolored Assets',
    blurb:
      'A theme directory of your own: named palettes, semantic color roles, DPI-aware sizing, one global shape switch, and SVG assets recolored at load time.',
  },
  {
    num: '02',
    slug: '02-keybindings',
    label: 'Keybindings',
    title: 'Keybindings: A Table You Can Read',
    blurb:
      'Every binding moves into one scannable table in its own module, with the awful.key boilerplate generated instead of repeated.',
  },
  {
    num: '03',
    slug: '03-widgets',
    label: 'Widgets',
    title: 'Widgets: Wrappers, Clock, Volume, Battery, WiFi',
    blurb:
      'Four real widgets and the shared wrapper vocabulary they are made of, fed by timers, async shell reads, and a custom signal.',
  },
  {
    num: '04',
    slug: '04-wibar',
    label: 'Wibar',
    title: 'Wibar: Our Own Bar',
    blurb:
      'The stock bar goes away. A wibar factory, named tags with icons, a custom taglist that shows state, and a styled systray.',
  },
  {
    num: '05',
    slug: '05-rules-titlebars',
    label: 'Rules and Titlebars',
    title: 'Client Rules and Titlebars',
    blurb:
      'Windows land where they should: apps routed to tags, dialogs floating, and titlebars drawn in your own theme.',
  },
  {
    num: '06',
    slug: '06-notifications',
    label: 'Notifications',
    title: 'Notifications: Routing, History, Center',
    blurb:
      'A full notification system: rule-based routing and styling, a history store with unread tracking, a notification center popup, and do-not-disturb.',
  },
  {
    num: '07',
    slug: '07-exitscreen',
    label: 'Exit Screen',
    title: 'Exit Screen: The Modal Pattern',
    blurb:
      'The pivot chapter. Extract the modal pattern into modal.lua, refactor the notification center onto it, and build a power menu as its first consumer.',
  },
  {
    num: '08',
    slug: '08-mainmenu',
    label: 'Main Menu',
    title: 'Main Menu',
    blurb:
      'A data-driven, fully themed replacement for awful.menu, built on the modal pattern from chapter 07.',
  },
  {
    num: '09',
    slug: '09-switcher',
    label: 'Window Switcher',
    title: 'Window Switcher',
    blurb:
      'Alt-Tab semantics: clients ordered most-recently-used, and hold-and-release input that deliberately does not fit the modal pattern.',
  },
  {
    num: '10',
    slug: '10-launcher',
    label: 'Launcher',
    title: 'Launcher: A Menubar Replacement',
    blurb:
      'A native fuzzy-search app launcher: parse .desktop files, scan asynchronously, score matches, and cache icon lookups on disk.',
  },
  {
    num: '11',
    slug: '11-dashboard',
    label: 'Dashboard',
    title: 'Dashboard: The Control Center',
    blurb:
      'Profile, sliders, toggles, and calendar composed into one popup, bound two ways to the system without feedback loops.',
  },
  {
    num: '12',
    slug: '12-lockscreen',
    label: 'Lock Screen',
    title: 'Lock Screen',
    blurb:
      'The finale: a native lock screen on the session-lock API, with PAM authentication, a masked UTF-8 prompt, and multi-monitor covers.',
  },
];

/** Chapter numbers are 00-based, so the last chapter number is the count minus one. */
export const lastChapterNum = chapters[chapters.length - 1].num;

export function getChapter(num: string): Chapter {
  const chapter = chapters.find((c) => c.num === num);
  if (!chapter) {
    throw new Error(
      `Unknown From Scratch chapter "${num}". Valid: ${chapters
        .map((c) => c.num)
        .join(', ')}`,
    );
  }
  return chapter;
}

export function getNeighbors(num: string): {prev?: Chapter; next?: Chapter} {
  const i = chapters.findIndex((c) => c.num === num);
  return {prev: chapters[i - 1], next: chapters[i + 1]};
}
