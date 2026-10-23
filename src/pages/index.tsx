import React from 'react';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import styles from './index.module.css';

function Hero() {
  return (
    <header className={styles.hero}>
      <div className={styles.heroInner}>
        <h1 className={styles.heroTitle}>SomeWM</h1>
        <p className={styles.heroSubtitle}>A Lua framework to build your perfect Wayland desktop.</p>
        <div className={styles.heroScreenshot}>
          <img
            className={styles.screenshot}
            src="/img/screenshot-styled.png"
            alt="SomeWM desktop with a themed bar, the hotkeys popup, and tiled terminals"
            width={1600}
            height={900}
          />
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
  const features: {title: string; description: React.ReactNode}[] = [
    {
      title: 'Configure your desktop in Lua',
      description: (
        <>
          Use AwesomeWM-style objects, rules, signals and themes.{' '}
          <Link to="/docs/getting-started/migrating">Bring an existing configuration</Link>
          {' '}or start with the bundled desktop.
        </>
      ),
    },
    {
      title: 'A full widget toolkit',
      description: (
        <>
          Describe your widgets and layouts in Lua. SomeWM handles sizing and drawing.{' '}
          <Link to="/docs/tutorials/widgets">Build your first widget</Link>.
        </>
      ),
    },
    {
      title: 'Restart without losing your session',
      description: (
        <>
          On Wayland, a compositor restart kills your apps.{' '}
          <code>awesome.restart()</code> hot-reloads the Lua runtime
          in-process. Clients stay put.
        </>
      ),
    },
    {
      title: 'Scriptable from the outside',
      description: (
        <>
          <code>somewm-client</code>: ~45 commands plus event subscription,
          from your shell or any script.
        </>
      ),
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

function BuildSomething() {
  return (
    <section className={styles.kiln}>
      <div className={styles.kilnCard}>
        <h2>Build something in SomeWM 2.1</h2>
        <p>
          Start with a clock you can see and click, then put it in your bar.
          Build reusable widgets with your own data and behaviour, or write
          Clay descriptions for new content and sizing rules.
        </p>
        <div className={styles.kilnLinks}>
          <Link className={styles.btnPrimary} to="/docs/tutorials/widgets">
            Build a clock widget
          </Link>
          <Link className={styles.btnSecondary} to="/docs/guides/custom-widgets">
            Create a custom widget
          </Link>
          <Link className={styles.btnSecondary} to="/docs/getting-started/upgrading-from-2.0">
            Upgrade from 2.0
          </Link>
        </div>
      </div>
    </section>
  );
}

function FromScratch() {
  return (
    <section className={styles.kiln}>
      <div className={styles.kilnCard}>
        <h2>Awesome From Scratch: SomeWM 1.4 and AwesomeWM</h2>
        <p>
          A thirteen-chapter course, read in order, that builds a complete
          desktop configuration: theme, widgets, bar, notifications, launcher,
          dashboard, lockscreen. Each chapter starts from the config the
          previous one finished and has a checkpoint branch with the finished
          code. The course targets SomeWM 1.4 and AwesomeWM. Use the
          tutorials above for SomeWM 2.1.
        </p>
        <div className={styles.kilnLinks}>
          <Link className={styles.btnSecondary} to="/docs/1.4/tutorials/from-scratch/">
            Start the series
          </Link>
        </div>
      </div>
    </section>
  );
}

function Kiln() {
  return (
    <section className={styles.kiln}>
      <div className={styles.kilnCard}>
        <h2>kiln</h2>
        <p>
          SomeWM's parallel experiment: a Wayland compositor whose entire
          surface is one <a href="https://github.com/nicbarker/clay">Clay</a>{' '}
          layout tree per screen. Windows, bars, widgets, and notifications
          are all Clay nodes, declared from Lua.
        </p>
        <div className={styles.kilnLinks}>
          <Link className={styles.btnSecondary} to="/kiln">
            Explore kiln
          </Link>
          <Link className={styles.btnSecondary} to="/kiln/concepts/the-clay-bet">
            Read the Clay bet
          </Link>
        </div>
      </div>
    </section>
  );
}

function Release() {
  return (
    <section className={styles.release}>
      <p>
        <strong>Latest Release: 2.1.0</strong> · Declarative widget and client layout.{' '}
        <Link to="/blog/somewm-2.1.0">Read the announcement</Link>
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
        <BuildSomething />
        <FromScratch />
        <Kiln />
        <Release />
      </main>
    </Layout>
  );
}
