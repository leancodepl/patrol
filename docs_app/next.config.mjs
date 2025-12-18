import { createMDX } from 'fumadocs-mdx/next';

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  redirects: async () => {
    return [
      {
        source: '/patrol/native/feature-parity',
        destination: '/native/feature-parity',
        permanent: false,
      },
      {
        source: '/patrol/native/usage',
        destination: '/native/usage',
        permanent: false,
      },
      {
        source: '/patrol/native/overview',
        destination: '/native/overview',
        permanent: false,
      },
      {
        source: '/patrol/native/advanced',
        destination: '/native/advanced',
        permanent: false,
      },
      {
        source: '/patrol/finders/usage',
        destination: '/finders/usage',
        permanent: false,
      },
      {
        source: '/patrol/finders/finders-setup',
        destination: '/finders/finders-setup',
        permanent: false,
      },
      {
        source: '/patrol/finders/overview',
        destination: '/finders/overview',
        permanent: false,
      },
      {
        source: '/patrol/finders/advanced',
        destination: '/finders/advanced',
        permanent: false,
      },
      {
        source: '/cli-commands/develop',
        destination: '/cli-commands',
        permanent: false,
      },
      {
        source: '/cheatsheet',
        destination: '/documentation/cheatsheet',
        permanent: false,
      },
      {
        source: '/feature-guide/introduction',
        destination: '/feature-guide',
        permanent: false,
      },
      {
        source: '/getting-started',
        destination: '/documentation',
        permanent: false,
      },
      {
        source: '/write-your-first-test',
        destination: '/documentation/write-your-first-test',
        permanent: false,
      },
      {
        source: '/supported-platforms',
        destination: '/documentation/supported-platforms',
        permanent: false,
      },
      {
        source: '/compatibility-table',
        destination: '/documentation/compatibility-table',
        permanent: false,
      },
      {
        source: '/web',
        destination: '/documentation/web',
        permanent: false,
      },
      {
        source: '/effective-patrol',
        destination: '/documentation/other/effective-patrol',
        permanent: false,
      },
      {
        source: '/tips-and-tricks',
        destination: '/documentation/other/tips-and-tricks',
        permanent: false,
      },
      {
        source: '/debugging-patrol-tests',
        destination: '/documentation/other/debugging-patrol-tests',
        permanent: false,
      },
      {
        source: '/documentation/patrol-tags',
        destination: '/documentation/other/patrol-tags',
        permanent: false,
      },
      {
        source: '/documentation/patrol-vs-code-extension',
        destination: '/documentation/other/patrol-vs-code-extension',
        permanent: false,
      },
      {
        source: '/documentation/patrol-devtools-extension',
        destination: '/documentation/other/patrol-devtools-extension',
        permanent: false,
      },
      {
        source: '/documentation/effective-patrol',
        destination: '/documentation/other/effective-patrol',
        permanent: false,
      },
      {
        source: '/documentation/tips-and-tricks',
        destination: '/documentation/other/tips-and-tricks',
        permanent: false,
      },
      {
        source: '/documentation/debugging-patrol-tests',
        destination: '/documentation/other/debugging-patrol-tests',
        permanent: false,
      },
      {
        source: '/native/overview',
        destination: '/documentation/native/overview',
        permanent: false,
      },
      {
        source: '/native/usage',
        destination: '/documentation/native/usage',
        permanent: false,
      },
      {
        source: '/native/advanced',
        destination: '/documentation/native/advanced',
        permanent: false,
      },
      {
        source: '/finders/overview',
        destination: '/documentation/finders/overview',
        permanent: false,
      },
      {
        source: '/finders/usage',
        destination: '/documentation/finders/usage',
        permanent: false,
      },
      {
        source: '/finders/advanced',
        destination: '/documentation/finders/advanced',
        permanent: false,
      },
      {
        source: '/finders/finders-setup',
        destination: '/documentation/finders/finders-setup',
        permanent: false,
      },
      {
        source: '/ci/overview',
        destination: '/documentation/ci/overview',
        permanent: false,
      },
      {
        source: '/integrations/allure',
        destination: '/documentation/integrations/allure',
        permanent: false,
      },
      {
        source: '/integrations/firebase-test-lab',
        destination: '/documentation/integrations/firebase-test-lab',
        permanent: false,
      },
      {
        source: '/documentation/ci/firebase-test-lab',
        destination: '/documentation/integrations/firebase-test-lab',
        permanent: false,
      },
      {
        source: '/announcements/v3',
        destination: '/v3',
        permanent: false,
      },
      {
        source: '/announcements/patrol-finders-release',
        destination: '/patrol-finders-release',
        permanent: false,
      },
      {
        source: '/announcements/logs-announcement',
        destination: '/logs-announcement',
        permanent: false,
      },
      {
        source: '/logs',
        destination: '/documentation/logs',
        permanent: false,
      },
      {
        source: '/native/feature-parity',
        destination: '/documentation/native/feature-parity',
        permanent: false,
      },
      {
        source: '/native/setup',
        destination: '/documentation',
        permanent: false,
      },
      {
        source: '/documentation/native/setup',
        destination: '/documentation',
        permanent: false,
      },
      {
        source: '/finders/usage',
        destination: '/documentation/finders/usage',
        permanent: false,
      },
      {
        source: '/ci/platforms',
        destination: '/documentation/ci/platforms',
        permanent: false,
      },
      {
        source: '/integrations/browserstack',
        destination: '/documentation/integrations/browserstack',
        permanent: false,
      },
    ];
  },
};

export default withMDX(config);
