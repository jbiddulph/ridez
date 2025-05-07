import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  mapboxgl.accessToken = config.public.mapboxToken
}) 