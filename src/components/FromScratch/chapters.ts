/**
 * Chapter metadata for the SomeWM 1.4 From Scratch series.
 * ChapterNav, NextChapter, and ChapterList use this order and these labels.
 * Slugs match files in versioned_docs/version-1.4/tutorials/from-scratch/.
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
      'Run the stock rc.lua in a nested session and identify its main sections.',
  },
  {
    num: '01',
    slug: '01-theme',
    label: 'Theme',
    title: 'Theme: Palettes, Shapes, Recolored Assets',
    blurb:
      'Create a theme with named palettes, shared fonts, shapes, and recoloured icons.',
  },
  {
    num: '02',
    slug: '02-keybindings',
    label: 'Keybindings',
    title: 'Keybindings: A Table You Can Read',
    blurb:
      'Move bindings into a module and register global, client, and tag shortcuts.',
  },
  {
    num: '03',
    slug: '03-widgets',
    label: 'Widgets',
    title: 'Widgets: Clock, Volume, Battery, WiFi',
    blurb:
      'Build clock, volume, battery, and WiFi widgets with shared theme settings and asynchronous updates.',
  },
  {
    num: '04',
    slug: '04-wibar',
    label: 'Wibar',
    title: 'Wibar: Our Own Bar',
    blurb:
      'Build a bar with icon tags, a clock, status widgets, and a system tray.',
  },
  {
    num: '05',
    slug: '05-rules-titlebars',
    label: 'Rules and Titlebars',
    title: 'Client Rules and Titlebars',
    blurb:
      'Route applications to tags, set floating rules, and style titlebars.',
  },
  {
    num: '06',
    slug: '06-notifications',
    label: 'Notifications',
    title: 'Notifications: Routing, History, Center',
    blurb:
      'Add notification rules, history, unread counts, snooze, and do-not-disturb.',
  },
  {
    num: '07',
    slug: '07-exitscreen',
    label: 'Exit Screen',
    title: 'Exit Screen: The Modal Pattern',
    blurb:
      'Share popup controls through modal.lua and build a power menu.',
  },
  {
    num: '08',
    slug: '08-mainmenu',
    label: 'Main Menu',
    title: 'Main Menu',
    blurb:
      'Build an application and session menu with mouse and keyboard controls.',
  },
  {
    num: '09',
    slug: '09-switcher',
    label: 'Window Switcher',
    title: 'Window Switcher',
    blurb:
      'Build a Super+Tab window switcher that activates on modifier release.',
  },
  {
    num: '10',
    slug: '10-launcher',
    label: 'Launcher',
    title: 'Launcher: A Menubar Replacement',
    blurb:
      'Build an application launcher with fuzzy search and cached icons.',
  },
  {
    num: '11',
    slug: '11-dashboard',
    label: 'Dashboard',
    title: 'Dashboard: The Control Center',
    blurb:
      'Build a dashboard with sliders, quick settings, a clock, and a calendar.',
  },
  {
    num: '12',
    slug: '12-lockscreen',
    label: 'Lock Screen',
    title: 'Lock Screen',
    blurb:
      'Build a SomeWM lock screen with a password prompt and monitor covers.',
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
