import React from 'react';
import styles from './FromAwesomeWM.module.css';

interface FromAwesomeWMProps {
  upstream: string;
  lastSynced: string;
}

export default function FromAwesomeWM({
  upstream,
  lastSynced,
}: FromAwesomeWMProps): React.ReactElement {
  const url = `https://awesomewm.org/apidoc/${upstream}.html`;
  return (
    <aside className={styles.banner} aria-label="AwesomeWM upstream attribution">
      <span className={styles.label}>From AwesomeWM</span>
      <span className={styles.body}>
        Mirrors{' '}
        <a href={url} target="_blank" rel="noopener noreferrer">
          <code>{upstream}</code>
        </a>
        {' '}(synced {lastSynced}). Differences are documented{' '}
        <a href="#deviations-from-awesomewm">inline below</a>.
      </span>
    </aside>
  );
}
