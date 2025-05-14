<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto">
    <!-- Backdrop -->
    <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" @click="close"></div>

    <!-- Modal -->
    <div class="flex min-h-full items-center justify-center p-4">
      <div class="relative w-full max-w-4xl bg-white rounded-lg shadow-xl">
        <!-- Header -->
        <div class="flex items-center justify-between p-6 border-b">
          <h3 class="text-2xl font-semibold text-gray-900">
            {{ trip?.title }}
          </h3>
          <button 
            @click="close"
            class="text-gray-400 hover:text-gray-500"
          >
            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Content -->
        <div>
          <!-- Trip Info -->
          <div class="mx-6 my-2">
            <div class="grid grid-cols-2 gap-4">
              <div class="text-left">
                <p class="text-sm text-gray-500">
                  {{ trip?.created_at ? new Date(trip.created_at).toLocaleDateString() : '' }} at {{ trip?.created_at ? new Date(trip.created_at).toLocaleTimeString() : '' }}
                </p>
              </div>
              <div class="text-right">
                <span class="inline-block px-3 py-1 text-sm rounded-full" 
                      :class="{
                        'bg-green-100 text-green-800': trip?.transport_type === 'walk',
                        'bg-blue-100 text-blue-800': trip?.transport_type === 'cycle',
                        'bg-purple-100 text-purple-800': trip?.transport_type === 'drive'
                      }">
                  {{ trip?.transport_type }}
                </span>
              </div>
            </div>
          </div>
        </div>
          <!-- Map -->
          <div class="h-80 overflow-hidden border border-gray-200 relative">
            <div ref="mapContainer" class="w-full h-full z-[60] bg-gray-100"></div>
          </div>
        <div class="p-6">
          <!-- Trip Details -->
          <div class="grid grid-cols-1 gap-3">
            <div class="grid grid-cols-3 md:grid-cols-3 gap-3 mb-6">
              <div class="flex flex-col items-center">
                <dt class="text-sm font-medium text-gray-500">Duration</dt>
                <dd class="text-2xl text-gray-900 font-bold">{{ calculateTripDuration }}</dd>
              </div>
              <div class="flex flex-col items-center border-x border-gray-200">
                <dt class="text-sm font-medium text-gray-500">Distance</dt>
                <dd class="text-2xl text-gray-900 font-bold">{{ formatDistanceMiles(trip?.distance) }}</dd>
              </div>
              <div class="flex flex-col items-center">
                <dt class="text-sm font-medium text-gray-500">Amount</dt>
                <dd class="text-2xl text-gray-900 font-bold">
                  <span v-if="trip?.amount !== undefined && trip?.amount !== null">
                    {{ currencySymbol }}{{ trip.amount }}
                  </span>
                  <span v-else>N/A</span>
                </dd>
              </div>
            </div>
            <div class="text-center">
              <h4 class="text-lg font-medium text-gray-900 mb-2">Notes</h4>
              <p v-if="trip?.notes" class="text-gray-600">{{ trip.notes }}</p>
              <p v-else class="text-gray-500 italic">No notes for this trip</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed, inject, provide } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import { useSupabaseUser, useSupabaseClient } from '#imports'

const props = defineProps({
  isOpen: Boolean,
  trip: Object
})

const emit = defineEmits(['close'])
const mapContainer = ref(null)
let map = null

const user = useSupabaseUser()
const client = useSupabaseClient()
const currency = ref('GBP') // default

// Fetch the user's currency from settings
const fetchCurrency = async () => {
  if (!user.value) return
  const { data } = await client
    .from('ridez_settings')
    .select('currency')
    .eq('user_id', user.value.id)
    .single()
  if (data && data.currency) currency.value = data.currency
}
onMounted(fetchCurrency)
watch(user, fetchCurrency)

const currencySymbol = computed(() => {
  switch ((currency.value || '').toUpperCase()) {
    case 'GBP': return '£'
    case 'USD': return '$'
    case 'EUR': return '€'
    case 'AUD': return 'A$'
    case 'CAD': return 'C$'
    default: return currency.value || '£'
  }
})

// Provide it to all children
provide('currencySymbol', currencySymbol)

const close = () => {
  emit('close')
}

const formatDistanceMiles = (meters) => {
  if (!meters) return 'N/A'
  const miles = meters / 1609.344
  return `${miles.toFixed(2)}mi`
}

// Calculate trip duration from created_at and end_time
const calculateTripDuration = computed(() => {
  if (!props.trip?.created_at || !props.trip?.end_time) return 'N/A'
  
  const startTime = new Date(props.trip.created_at)
  const endTime = new Date(props.trip.end_time)
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

// Debug function to log map initialization
const initMap = async () => {
  console.log('Initializing map...')
  console.log('Map container:', mapContainer.value)
  console.log('Trip data:', props.trip)

  if (!mapContainer.value) {
    console.error('Map container not found')
    return
  }

  try {
    const config = useRuntimeConfig()
    console.log('Mapbox token:', config.public.mapboxToken ? 'Token exists' : 'No token')

    mapboxgl.accessToken = config.public.mapboxToken

    // Get route points from the trip
    const { data: routePoints, error } = await useSupabaseClient()
      .from('ridez_routes')
      .select('latitude, longitude, sequence_number')
      .eq('ride_id', props.trip.id)
      .order('sequence_number', { ascending: true })

    if (error) {
      console.error('Error fetching route points:', error)
      return
    }

    if (!routePoints || routePoints.length === 0) {
      console.error('No route points found')
      return
    }

    // Calculate the middle point index
    const middleIndex = Math.floor(routePoints.length / 2)
    const middlePoint = routePoints[middleIndex]

    // Create a basic map centered on the middle point
    map = new mapboxgl.Map({
      container: mapContainer.value,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [middlePoint.longitude, middlePoint.latitude],
      zoom: 13
    })

    map.on('load', () => {
      console.log('Map loaded successfully')

      // Add the route line
      map.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates: routePoints.map(point => [point.longitude, point.latitude])
          }
        }
      })

      // Add the route line layer
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

      // Add markers for start and end points
      const startPoint = routePoints[0]
      const endPoint = routePoints[routePoints.length - 1]

      // Add start marker
      new mapboxgl.Marker({ color: '#22c55e' })
        .setLngLat([startPoint.longitude, startPoint.latitude])
        .addTo(map)

      // Add end marker
      new mapboxgl.Marker({ color: '#ef4444' })
        .setLngLat([endPoint.longitude, endPoint.latitude])
        .addTo(map)

      // Fit bounds to show the entire route
      const bounds = routePoints.reduce((bounds, point) => {
        return bounds.extend([point.longitude, point.latitude])
      }, new mapboxgl.LngLatBounds())

      map.fitBounds(bounds, {
        padding: 50,
        duration: 1000
      })
    })

    map.on('error', (e) => {
      console.error('Map error:', e)
    })
  } catch (error) {
    console.error('Error initializing map:', error)
  }
}

// Watch for modal open state
watch(() => props.isOpen, (isOpen) => {
  console.log('Modal open state changed:', isOpen)
  if (isOpen) {
    // Small delay to ensure DOM is ready
    setTimeout(() => {
      initMap()
    }, 100)
  } else if (map) {
    map.remove()
    map = null
  }
})

// Clean up map on component unmount
onUnmounted(() => {
  console.log('Component unmounting, cleaning up map')
  if (map) {
    map.remove()
    map = null
  }
})
</script>

<style>

/* Add a background color to make the map container visible even if map fails to load */
.mapboxgl-map {
  background-color: #f3f4f6;
}
</style> 