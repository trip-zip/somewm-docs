import React from 'react';
import styles from './SomewmOnly.module.css';

export default function SomewmOnly(): React.ReactElement {
  return (
    <span className={styles.badge} title="SomeWM extension, not available in AwesomeWM">
      somewm-only
    </span>
  );
}
