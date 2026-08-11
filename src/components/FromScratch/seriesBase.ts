import {useLocation} from '@docusaurus/router';

/**
 * The series currently ships for 1.4 only, at `/docs/tutorials/from-scratch`,
 * but the docs are versioned and the prefix moves: a 2.0 rebuild would live at
 * `/docs/next/tutorials/from-scratch`, and today's prefix becomes
 * `/docs/1.4/...` the moment another version is added.
 *
 * Deriving the prefix from the current URL keeps every link inside the version
 * the reader is already in, and survives a baseUrl change too.
 */
const SERIES_SEGMENT = '/tutorials/from-scratch';

function useSeriesSplit(): {docs: string; series: string} {
  const {pathname} = useLocation();
  const at = pathname.indexOf(SERIES_SEGMENT);
  if (at === -1) {
    throw new Error(
      `The From Scratch nav components only work on pages under ${SERIES_SEGMENT}, got "${pathname}".`,
    );
  }
  return {
    docs: pathname.slice(0, at),
    series: pathname.slice(0, at + SERIES_SEGMENT.length),
  };
}

/** Version-correct prefix for the series, with no trailing slash. */
export function useSeriesBase(): string {
  return useSeriesSplit().series;
}

/** Version-correct docs root, for the few links that leave the series. */
export function useDocsBase(): string {
  return useSeriesSplit().docs;
}
