import React from 'react';
import Link from '@docusaurus/Link';
import {chapters, getChapter, getNeighbors, lastChapterNum} from './chapters';
import {useSeriesBase} from './seriesBase';
import styles from './styles.module.css';

interface ChapterNavProps {
  /** Two-digit chapter number, '00' through '12'. */
  chapter: string;
}

/**
 * The "you are here" strip that sits directly under a chapter's H1. Every
 * chapter assumes the code from the ones before it, so a reader who arrives
 * from search needs to see the sequence before they start typing.
 */
export default function ChapterNav({chapter}: ChapterNavProps): React.ReactElement {
  const base = useSeriesBase();
  const current = getChapter(chapter);
  const {prev} = getNeighbors(chapter);
  const position = chapters.indexOf(current) + 1;

  return (
    <nav className={styles.nav} aria-label="Position in the series">
      <div className={styles.navHead}>
        <Link className={styles.series} to={`${base}/`}>
          Awesome From Scratch
        </Link>
        <span className={styles.counter}>
          Chapter {current.num} of {lastChapterNum}
        </span>
      </div>

      <div
        className={styles.track}
        role="img"
        aria-label={`Chapter ${position} of ${chapters.length}`}>
        <div
          className={styles.trackFill}
          style={{width: `${(position / chapters.length) * 100}%`}}
        />
      </div>

      <div className={styles.navLinks}>
        {prev ? (
          <span>
            Builds on{' '}
            <Link to={`${base}/${prev.slug}`}>
              {prev.num} · {prev.label}
            </Link>
          </span>
        ) : (
          <span>The first chapter. Nothing comes before this one.</span>
        )}
        {prev && (
          <Link className={styles.navStart} to={`${base}/${chapters[0].slug}`}>
            Start at chapter 00
          </Link>
        )}
      </div>
    </nav>
  );
}
