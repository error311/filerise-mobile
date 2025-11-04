import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'net.filerise.mobile',
  appName: 'FileRise',
  webDir: 'app',
  bundledWebRuntime: false,
  ios: { contentInset: 'automatic' },
  server: {
    // During development, wildcard is convenient. For App Store, list explicit hosts.
    allowNavigation: [
      // 'demo.filerise.net',
      // 'files.yourdomain.com',
      '*'
    ],
  },
};

export default config;