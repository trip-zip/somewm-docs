import {useLocation} from '@docusaurus/router';

/**
 * The docs are versioned, so the series lives at two prefixes at once:
 * `/docs/tutorials/from-scratch` (1.4, the default) and
 * `/docs/next/tutorials/from-scratch` (2.0 dev). These components are shared by
 * both, so they cannot hardcode either one: a hardcoded link would throw the
 * reader out of the version they are reading.
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
