<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <div class="sticky top-0 z-10 bg-white border-b border-gray-200">
      <div class="px-4 py-4 flex items-center">
        <button 
          @click="router.back()"
          class="mr-4 text-gray-600 hover:text-gray-900"
        >
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 class="text-xl font-semibold text-gray-900">Trip Details</h1>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-[50vh]">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="p-4 text-red-600">
      {{ error }}
    </div>

    <!-- Content -->
    <div v-else-if="trip" class="p-4">
      <!-- Trip Info -->
      <div class="mb-6">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <h4 class="text-lg font-medium text-gray-900">{{ trip.title }}</h4>
            <p class="text-sm text-gray-500">
              {{ new Date(trip.created_at).toLocaleDateString() }} at 
              {{ new Date(trip.created_at).toLocaleTimeString() }}
            </p>
          </div>
          <div class="text-right">
            <span class="inline-block px-3 py-1 text-sm rounded-full" 
                  :class="{
                    'bg-green-100 text-green-800': trip.transport_type === 'walk',
                    'bg-blue-100 text-blue-800': trip.transport_type === 'cycle',
                    'bg-purple-100 text-purple-800': trip.transport_type === 'drive'
                  }">
              {{ trip.transport_type }}
            </span>
          </div>
        </div>
      </div>

      <!-- Map -->
      <div class="mb-6 h-96 rounded-lg overflow-hidden border border-gray-200">
        <div ref="mapContainer" class="w-full h-full"></div>
      </div>

      <!-- Trip Details -->
      <div class="grid grid-cols-2 gap-6">
        <div>
          <h4 class="text-lg font-medium text-gray-900 mb-4">Trip Information</h4>
          <dl class="space-y-3">
            <div>
              <dt class="text-sm font-medium text-gray-500">Trip Duration</dt>
              <dd class="text-base text-gray-900">{{ calculateTripDuration }}</dd>
            </div>
            <div v-if="trip.distance">
              <dt class="text-sm font-medium text-gray-500">Distance</dt>
              <dd class="text-base text-gray-900">{{ formatDistance(trip.distance) }}</dd>
            </div>
            <div v-if="trip.amount">
              <dt class="text-sm font-medium text-gray-500">{{ trip.transaction_type === 'spending' ? 'Amount Spent' : 'Amount Earned' }}</dt>
              <dd class="text-base text-gray-900">${{ trip.amount }}</dd>
            </div>
          </dl>
        </div>
        <div>
          <h4 class="text-lg font-medium text-gray-900 mb-4">Notes</h4>
          <p v-if="trip.notes" class="text-gray-600">{{ trip.notes }}</p>
          <p v-else class="text-gray-500 italic">No notes for this trip</p>
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
</style> 