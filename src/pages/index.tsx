import React from 'react';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import styles from './index.module.css';

function Hero() {
  return (
    <header className={styles.hero}>
      <div className={styles.heroInner}>
        <h1 className={styles.heroTitle}>SomeWM</h1>
        <p className={styles.heroSubtitle}>A Lua-scriptable Wayland compositor</p>
        <div className={styles.heroScreenshot}>
          <div className={styles.screenshotPlaceholder}>
            <span>screenshot coming soon</span>
          </div>
        </div>
        <div className={styles.heroButtons}>
          <Link className={styles.btnPrimary} to="/docs/getting-started/installation">
            Get Started
          </Link>
          <Link className={styles.btnSecondary} to="/docs/intro">
            Read the Docs
          </Link>
        </div>
      </div>
    </header>
  );
}

function Features() {
  const features = [
    {
      title: 'Hot Reload',
      description:
        'Edit your Lua config, see changes live. No restart required.',
    },
    {
      title: 'Full Lua API',
      description:
        "AwesomeWM's complete Lua scripting API, running natively on Wayland.",
    },
    {
      title: 'IPC Control',
      description:
        'Drive your compositor from scripts and the terminal with somewm-client.',
    },
    {
      title: 'AwesomeWM Compatible',
      description:
        'Bring your existing rc.lua. Targets 100% API compatibility.',
    },
  ];

  return (
    <section className={styles.features}>
      <div className={styles.featuresGrid}>
        {features.map((feature) => (
          <div key={feature.title} className={styles.featureCard}>
            <h3>{feature.title}</h3>
            <p>{feature.description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

function Release() {
  return (
    <section className={styles.release}>
      <p>
        <strong>Latest Release: 1.4.0</strong> · First stable release.
        AwesomeWM 4.4 on Wayland.{' '}
        <Link to="/blog/somewm-1.4.0">Read the announcement</Link>
      </p>
    </section>
  );
}

export default function Home(): React.ReactElement {
  return (
    <Layout title="Home" description="A Lua-scriptable Wayland compositor">
      <main>
        <Hero />
        <Features />
        <Release />
      </main>
    </Layout>
  );
}
