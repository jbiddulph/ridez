// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: false,
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase'
  ],
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_KEY,
    redirect: false
  },
  runtimeConfig: {
    public: {
      mapboxToken: process.env.MAPBOX_ACCESS_TOKEN
    }
  },
  nitro: {
    // For Heroku deployment, we always use node-server preset
    preset: 'node-server'
    // We'll handle Capacitor builds separately via npm scripts
  },
  ssr: true,
  app: {
    baseURL: '',
    buildAssetsDir: '/_nuxt/',
    head: {
      title: 'Tripz',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  }
})
