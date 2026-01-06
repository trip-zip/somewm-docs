import React, { useEffect } from 'react';

interface RootProps {
  children: React.ReactNode;
}

export default function Root({ children }: RootProps): React.ReactElement {
  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      // Ignore if user is typing in an input, textarea, or contenteditable
      const target = event.target as HTMLElement;
      if (
        target.tagName === 'INPUT' ||
        target.tagName === 'TEXTAREA' ||
        target.isContentEditable
      ) {
        return;
      }

      // Trigger search on f, /, or s (without modifiers)
      if (
        (event.key === 'f' || event.key === '/' || event.key === 's') &&
        !event.ctrlKey &&
        !event.metaKey &&
        !event.altKey
      ) {
        // Look for common search input selectors
        const searchInput = document.querySelector<HTMLInputElement>(
          '.navbar__search-input, ' +
          '[class*="searchBox"] input, ' +
          '[class*="DocSearch"] button, ' +
          '.DocSearch-Button, ' +
          'input[type="search"], ' +
          '[aria-label="Search"]'
        );

        if (searchInput) {
          event.preventDefault();
          if (searchInput.tagName === 'BUTTON') {
            searchInput.click();
          } else {
            searchInput.focus();
          }
        }
      }
    }

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, []);

  return <>{children}</>;
}
