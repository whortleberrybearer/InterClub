// @ts-check
import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import robotsTxt from 'astro-robots-txt';

// https://astro.build/config
export default defineConfig({
  site: 'https://whortleberrybearer.github.io',
  base: '/InterClub',
  server: { port: process.env.PORT ? parseInt(process.env.PORT) : 4321 },
  integrations: [
    sitemap(),
    robotsTxt({
      policy: [{ userAgent: '*', disallow: '/' }],
    }),
  ],
  vite: {
    plugins: [tailwindcss()]
  }
});
