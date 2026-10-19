import React from 'react';
import styles from './WidgetSource.module.css';

export default function WidgetSource({children}: {children: React.ReactNode}): React.ReactElement {
  return (
    <details className={styles.source}>
      <summary>Show Lua</summary>
      <div className={styles.content}>{children}</div>
    </details>
  );
}
