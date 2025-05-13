<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900 py-8">
    <div class="max-w-3xl mx-auto px-4">
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-8">
        <h1 class="text-2xl font-bold mb-4 text-gray-900 dark:text-white">Trip Details</h1>
        <div v-if="loading" class="text-center py-4 text-gray-900 dark:text-gray-100">Loading trip details...</div>
        <div v-else-if="error" class="text-red-600 p-4 bg-red-100 rounded-lg">{{ error }}</div>
        <div v-else>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Title:</span>
            <span class="text-gray-900 dark:text-white font-semibold">{{ trip.title }}</span>
          </div>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Date:</span>
            <span class="text-gray-900 dark:text-white">{{ formatDate(trip.created_at) }}</span>
          </div>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Transport Type:</span>
            <span class="px-3 py-1 rounded bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200">{{ trip.transport_type }}</span>
          </div>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Transaction Type:</span>
            <span class="px-3 py-1 rounded bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">{{ trip.transaction_type }}</span>
          </div>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Amount:</span>
            <span class="text-gray-900 dark:text-white">${{ trip.amount }}</span>
          </div>
          <div class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300">Notes:</span>
            <span class="text-gray-900 dark:text-white">{{ trip.notes || 'None' }}</span>
          </div>
          <div v-if="trip.route && trip.route.length" class="mb-4">
            <span class="block text-gray-700 dark:text-gray-300 mb-2">Route:</span>
            <div class="bg-gray-50 dark:bg-gray-900 rounded p-4 overflow-x-auto">
              <table class="min-w-full text-sm bg-white dark:bg-gray-800 rounded shadow overflow-hidden">
                <thead>
                  <tr>
                    <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">#</th>
                    <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Latitude</th>
                    <th class="px-4 py-2 text-left text-gray-700 dark:text-gray-300">Longitude</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(point, idx) in trip.route" :key="idx">
                    <td class="px-4 py-2 text-gray-900 dark:text-white">{{ idx + 1 }}</td>
                    <td class="px-4 py-2 text-gray-900 dark:text-white">{{ point.latitude }}</td>
                    <td class="px-4 py-2 text-gray-900 dark:text-white">{{ point.longitude }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

const router = useRouter()
const route = useRoute()
const client = useSupabaseClient()
const mapContainer = ref(null)
let map = null
const trip = ref(null)
const loading = ref(true)
const error = ref(null)

const formatDistance = (meters) => {
  if (!meters) return 'N/A'
  const kilometers = meters / 1000
  return `${kilometers.toFixed(1)} km`
}

// Calculate trip duration from created_at and end_time
const calculateTripDuration = computed(() => {
  if (!trip.value?.created_at || !trip.value?.end_time) return 'N/A'
  
  const startTime = new Date(trip.value.created_at)
  const endTime = new Date(trip.value.end_time)
  const durationMs = endTime - startTime
  
  const hours = Math.floor(durationMs / (1000 * 60 * 60))
  const minutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((durationMs % (1000 * 60)) / 1000)
  
  if (hours > 0) {
    return `${hours}h ${minutes}m ${seconds}s`
  } else if (minutes > 0) {
    return `${minutes}m ${seconds}s`
  } else {
    return `${seconds}s`
  }
})

const initMap = async () => {
  if (!trip.value?.route || !mapContainer.value) return

  const config = useRuntimeConfig()
  mapboxgl.accessToken = config.public.mapboxToken

  // Create map
  map = new mapboxgl.Map({
    container: mapContainer.value,
    style: 'mapbox://styles/mapbox/streets-v12',
    center: trip.value.route[0],
    zoom: 12
  })

  // Add route line
  map.on('load', () => {
    map.addSource('route', {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: trip.value.route
        }
      }
    })

    map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3b82f6',
        'line-width': 4
      }
    })

    // Add start and end markers
    new mapboxgl.Marker({ color: '#22c55e' })
      .setLngLat(trip.value.route[0])
      .addTo(map)

    new mapboxgl.Marker({ color: '#ef4444' })
      .setLngLat(trip.value.route[trip.value.route.length - 1])
      .addTo(map)

    // Fit bounds to show entire route
    const bounds = trip.value.route.reduce((bounds, coord) => {
      return bounds.extend(coord)
    }, new mapboxgl.LngLatBounds(trip.value.route[0], trip.value.route[0]))

    map.fitBounds(bounds, {
      padding: 50,
      maxZoom: 15
    })
  })
}

// Fetch trip details
onMounted(async () => {
  try {
    console.log('Fetching trip details for ID:', route.params.id) // Debug log
    const { data, error: fetchError } = await client
      .from('ridez_rides')
      .select('*, ridez_routes(*)')
      .eq('id', route.params.id)
      .single()

    if (fetchError) throw fetchError

    trip.value = {
      ...data,
      route: data.ridez_routes?.coordinates || []
    }

    // Initialize map after trip data is loaded
    await nextTick()
    initMap()
  } catch (err) {
    console.error('Error fetching trip details:', err)
    error.value = 'Error loading trip details: ' + err.message
  } finally {
    loading.value = false
  }
})

// Clean up map on component unmount
onUnmounted(() => {
  if (map) {
    map.remove()
  }
})
</script>

<style>
.page-enter-active,
.page-leave-active {
  transition: transform 0.3s ease;
}

.page-enter-from {
  transform: translateX(100%);
}

.page-leave-to {
  transform: translateX(-100%);
}

.dark .modal-content {
  background: #1f2937;
  color: #fff;
}
</style> 