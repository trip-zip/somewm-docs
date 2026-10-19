import React, {useId} from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './AnimationDemo.module.css';

interface AnimationDemoProps {
  name: string;
  title: string;
  children: React.ReactNode;
  width?: number;
  height?: number;
}

export default function AnimationDemo({name, title, children, width = 1200, height = 800}: AnimationDemoProps): React.ReactElement {
  const captionId = useId();
  const videoUrl = useBaseUrl(`/img/animation/${name}.mp4`);
  const posterUrl = useBaseUrl(`/img/animation/${name}.png`);

  return (
    <figure className={styles.figure}>
      <video
        className={styles.video}
        controls
        muted
        playsInline
        preload="metadata"
        poster={posterUrl}
        width={width}
        height={height}
        aria-label={title}
        aria-describedby={captionId}>
        <source src={videoUrl} type="video/mp4" />
        <a href={videoUrl}>Watch {title.toLowerCase()}.</a>
      </video>
      <figcaption id={captionId} className={styles.caption}>
        <strong>{title}.</strong> {children}
      </figcaption>
    </figure>
  );
}
