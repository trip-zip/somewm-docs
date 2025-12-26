import React from 'react';
import styles from './YouWillLearn.module.css';

interface YouWillLearnProps {
  children: React.ReactNode;
}

export default function YouWillLearn({children}: YouWillLearnProps): React.ReactElement {
  return (
    <div className={styles.container}>
      <h4 className={styles.title}>You will learn</h4>
      <div className={styles.content}>{children}</div>
    </div>
  );
}
