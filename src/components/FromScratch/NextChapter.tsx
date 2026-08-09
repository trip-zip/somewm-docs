import React from 'react';
import Link from '@docusaurus/Link';
import {getNeighbors} from './chapters';
import {useDocsBase, useSeriesBase} from './seriesBase';
import styles from './styles.module.css';

interface NextChapterProps {
  /** Two-digit chapter number, '00' through '12'. */
  chapter: string;
}

/**
 * The forward pointer at the foot of a chapter, after the checkpoint. The last
 * chapter gets a close-out card instead, because there is nowhere further to go
 * inside the series.
 */
export default function NextChapter({chapter}: NextChapterProps): React.ReactElement {
  const base = useSeriesBase();
  const docs = useDocsBase();
  const {next} = getNeighbors(chapter);

  if (!next) {
    return (
      <aside className={`${styles.next} ${styles.done}`}>
        <div className={styles.nextLabel}>Series complete</div>
        <p className={styles.nextBlurb}>
          Thirteen chapters, and every line of the config is yours. The{' '}
          <code>12-lockscreen</code> branch and <code>main</code> now hold the
          same tree. From here the docs stop being a course: the{' '}
          <Link to={`${docs}/faq`}>FAQ</Link> and{' '}
          <Link to={`${docs}/troubleshooting`}>troubleshooting</Link> pages
          answer questions as they come up, and the how-to guides in the sidebar
          are written to be read one at a time.
        </p>
        <Link className={styles.nextTitle} to={`${base}/`}>
          Back to the series overview
        </Link>
      </aside>
    );
  }

  return (
    <aside className={styles.next}>
      <div className={styles.nextLabel}>Next</div>
      <Link className={styles.nextTitle} to={`${base}/${next.slug}`}>
        {next.num} · {next.title}
      </Link>
      <p className={styles.nextBlurb}>{next.blurb}</p>
    </aside>
  );
}
