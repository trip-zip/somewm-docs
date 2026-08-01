import React from 'react';
import {useLocation} from '@docusaurus/router';
import DocsVersionDropdownNavbarItem from '@theme-original/NavbarItem/DocsVersionDropdownNavbarItem';
import type DocsVersionDropdownNavbarItemType from '@theme/NavbarItem/DocsVersionDropdownNavbarItem';
import type {WrapperProps} from '@docusaurus/types';

type Props = WrapperProps<typeof DocsVersionDropdownNavbarItemType>;

// The version dropdown belongs to the SomeWM docs plugin, but Docusaurus renders
// navbar items on every route. Kiln is a separate project with no versions, and
// the landing page and blog select nothing, so only show it under /docs.
export default function DocsVersionDropdownNavbarItemWrapper(
  props: Props,
): React.ReactNode {
  const {pathname} = useLocation();
  const inSomewmDocs = pathname === '/docs' || pathname.startsWith('/docs/');
  return inSomewmDocs ? <DocsVersionDropdownNavbarItem {...props} /> : null;
}
