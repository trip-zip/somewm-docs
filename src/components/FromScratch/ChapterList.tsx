import React from 'react';
import Link from '@docusaurus/Link';
import SomewmOnly from '@site/src/components/SomewmOnly';
import {chapters} from './chapters';
import {useSeriesBase} from './seriesBase';
import styles from './styles.module.css';

interface Group {
  title: string;
  summary: React.ReactNode;
  from: string;
  to: string;
}

const groups: Group[] = [
  {
    title: 'Chapters 00 to 05: the foundation',
    summary:
      'The structure every later chapter edits. Skip any of these and the files the feature chapters ask you to open will not exist.',
    from: '00',
    to: '05',
  },
  {
    title: 'Chapters 06 to 11: the features',
    summary:
      'A notification system, then a run of overlay UIs, all sharing one modal pattern that you extract yourself in chapter 07.',
    from: '06',
    to: '11',
  },
  {
    title: 'Chapter 12: the finale',
    summary: (
      <>
        A native lock screen on SomeWM&apos;s session-lock API. <SomewmOnly />
      </>
    ),
    from: '12',
    to: '12',
  },
];

/**
 * The full ladder on the overview page. Ordered, numbered, and grouped, so the
 * course reads as a sequence rather than a menu of thirteen topics.
 */
export default function ChapterList(): React.ReactElement {
  const base = useSeriesBase();

  return (
    <div className={styles.list}>
      {groups.map((group) => (
        <section key={group.title} className={styles.group}>
          <h3 className={styles.groupTitle}>{group.title}</h3>
          <p className={styles.groupSummary}>{group.summary}</p>
          <ol className={styles.chapters}>
            {chapters
              .filter((c) => c.num >= group.from && c.num <= group.to)
              .map((c) => (
                <li key={c.slug} className={styles.chapter}>
                  <Link className={styles.chapterLink} to={`${base}/${c.slug}`}>
                    <span className={styles.chapterNum}>{c.num}</span>
                    <span className={styles.chapterText}>
                      <span className={styles.chapterLabel}>{c.label}</span>
                      <span className={styles.chapterBlurb}>{c.blurb}</span>
                    </span>
                  </Link>
                </li>
              ))}
          </ol>
        </section>
      ))}
    </div>
  );
}
