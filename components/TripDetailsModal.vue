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
            Trip Details
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
        <div class="p-6">
          <!-- Trip Info -->
          <div class="mb-6">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <h4 class="text-lg font-medium text-gray-900">{{ trip?.title }}</h4>
                <p class="text-sm text-gray-500">
                  {{ trip?.created_at ? new Date(trip.created_at).toLocaleDateString() : '' }} at 
                  {{ trip?.created_at ? new Date(trip.created_at).toLocaleTimeString() : '' }}
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

          <!-- Map -->
          <div class="mb-6 h-96 rounded-lg overflow-hidden border border-gray-200 relative">
            <div ref="mapContainer" class="w-full h-full z-[60] bg-gray-100"></div>
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
                <div v-if="trip?.distance">
                  <dt class="text-sm font-medium text-gray-500">Distance</dt>
                  <dd class="text-base text-gray-900">{{ formatDistance(trip.distance) }}</dd>
                </div>
                <div v-if="trip?.amount">
                  <dt class="text-sm font-medium text-gray-500">{{ trip.transaction_type === 'spending' ? 'Amount Spent' : 'Amount Earned' }}</dt>
                  <dd class="text-base text-gray-900">${{ trip.amount }}</dd>
                </div>
              </dl>
            </div>
            <div>
              <h4 class="text-lg font-medium text-gray-900 mb-4">Notes</h4>
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
import { ref, onMounted, watch, computed } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'

const props = defineProps({
  isOpen: Boolean,
  trip: Object
})

const emit = defineEmits(['close'])
const mapContainer = ref(null)
let map = null

const close = () => {
  emit('close')
}

const formatDistance = (meters) => {
  if (!meters) return 'N/A'
  const kilometers = meters / 1000
  return `${kilometers.toFixed(1)} km`
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

    // Create a basic map centered on London
    map = new mapboxgl.Map({
      container: mapContainer.value,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [-0.127758, 51.507351], // London coordinates
      zoom: 10
    })

    map.on('load', () => {
      console.log('Map loaded successfully')
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