import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.ridez.app',
  appName: 'ridez',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
    hostname: 'localhost',
    cleartext: true
  },
  plugins: {
    Geolocation: {
      permissions: {
        ios: {
          whenInUse: 'Allow $(PRODUCT_NAME) to use your location.',
          always: 'Allow $(PRODUCT_NAME) to use your location in the background.'
        },
        android: {
          coarse: 'Allow $(PRODUCT_NAME) to access your location.',
          fine: 'Allow $(PRODUCT_NAME) to access your precise location.'
        }
      }
    }
  }
};

export default config;