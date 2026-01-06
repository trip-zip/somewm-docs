import React from 'react';
import Link from '@docusaurus/Link';
import styles from './ModuleTable.module.css';

interface ModuleItem {
  name: string;
  description: string;
  link: string;
}

interface ModuleTableProps {
  title?: string;
  modules: ModuleItem[];
}

export default function ModuleTable({ title, modules }: ModuleTableProps): React.ReactElement {
  return (
    <div className={styles.moduleTable}>
      {title && <h3 className={styles.title}>{title}</h3>}
      <table>
        <thead>
          <tr>
            <th>Module</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          {modules.map((module) => (
            <tr key={module.name}>
              <td>
                <Link to={module.link} className={styles.moduleName}>
                  {module.name}
                </Link>
              </td>
              <td>{module.description}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
