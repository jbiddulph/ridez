<template>
  <div class="relative w-full h-[500px] rounded-lg overflow-hidden shadow-lg">
    <div ref="mapContainer" class="absolute inset-0 w-full h-full"></div>
    <div v-if="error" class="absolute top-4 left-4 right-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded z-10">
      {{ error }}
    </div>
    <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10">
      <div class="text-lg font-medium text-gray-700">Loading map...</div>
    </div>
    <div class="absolute bottom-4 left-4 right-4 flex justify-center z-10">
      <button
        @click="isTracking ? stopTrip() : showTitleInput = true"
        :class="[
          'px-6 py-3 rounded-full font-bold text-white shadow-lg transition-all',
          isTracking
            ? 'bg-red-600 hover:bg-red-700'
            : 'bg-green-600 hover:bg-green-700'
        ]"
      >
        {{ isTracking ? 'STOP TRIP' : 'START TRIP' }}
      </button>
    </div>

    <!-- Title Input Modal -->
    <div v-if="showTitleInput" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <h3 class="text-xl font-bold mb-4">Start New Trip</h3>
        <div class="mb-4">
          <label for="rideTitle" class="block text-sm font-medium text-gray-700 mb-2">Trip Title</label>
          <input
            id="rideTitle"
            v-model="rideTitle"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter trip title"
            @keyup.enter="startTrip"
          />
        </div>
        <div class="flex justify-end space-x-3">
          <button
            @click="showTitleInput = false"
            class="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            Cancel
          </button>
          <button
            @click="startTrip"
            :disabled="!rideTitle.trim()"
            class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Start Trip
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import { Geolocation } from '@capacitor/geolocation'

const mapContainer = ref(null)
const map = ref(null)
const loading = ref(true)
const error = ref('')
const isTracking = ref(false)
const watchId = ref(null)
const lastPosition = ref(null)
const sequenceNumber = ref(0)
const client = useSupabaseClient()
const user = useSupabaseUser()
const showTitleInput = ref(false)
const rideTitle = ref('')
const currentRideId = ref(null)

// Calculate distance between two points using Haversine formula
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371e3 // Earth's radius in meters
  const φ1 = (lat1 * Math.PI) / 180
  const φ2 = (lat2 * Math.PI) / 180
  const Δφ = ((lat2 - lat1) * Math.PI) / 180
  const Δλ = ((lon2 - lon1) * Math.PI) / 180

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  return R * c // Distance in meters
}

// Create a new ride record
const createRide = async () => {
  try {
    const { data, error: insertError } = await client
      .from('ridez_rides')
      .insert({
        user_id: user.value.id,
        title: rideTitle.value.trim()
      })
      .select()
      .single()

    if (insertError) throw insertError
    return data.id
  } catch (err) {
    console.error('Error creating ride:', err)
    error.value = 'Error creating ride: ' + err.message
    return null
  }
}

// Handle position updates
const handlePositionUpdate = async (position) => {
  if (!isTracking.value || !currentRideId.value) return

  const { latitude, longitude } = position
  const distance = lastPosition.value
    ? calculateDistance(
        lastPosition.value.latitude,
        lastPosition.value.longitude,
        latitude,
        longitude
      )
    : 0

  // Only record if moved more than 5 meters or it's the first point
  if (distance >= 5 || !lastPosition.value) {
    try {
      const { error: insertError } = await client.from('ridez_routes').insert({
        user_id: user.value.id,
        ride_id: currentRideId.value,
        latitude,
        longitude,
        distance_from_last_point: distance,
        sequence_number: sequenceNumber.value++
      })

      if (insertError) throw insertError

      // Update last position
      lastPosition.value = { latitude, longitude }

      // Add point to map
      new mapboxgl.Marker({
        color: '#00FF00',
        scale: 0.5
      })
        .setLngLat([longitude, latitude])
        .addTo(map.value)
    } catch (err) {
      console.error('Error recording position:', err)
      error.value = 'Error recording position: ' + err.message
    }
  }
}

// Start trip with title
const startTrip = async () => {
  if (!user.value) {
    error.value = 'Please sign in to start tracking'
    return
  }

  if (!rideTitle.value.trim()) {
    error.value = 'Please enter a trip title'
    return
  }

  try {
    // Request background location permission
    await Geolocation.requestPermissions()
    
    // Create ride record first
    const rideId = await createRide()
    if (!rideId) {
      return
    }

    currentRideId.value = rideId
    isTracking.value = true
    showTitleInput.value = false

    // Start watching position with Capacitor
    watchId.value = await Geolocation.watchPosition(
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0
      },
      (position) => {
        handlePositionUpdate(position)
      }
    )
  } catch (err) {
    error.value = 'Error starting trip: ' + err.message
    console.error('Error starting trip:', err)
  }
}

// Stop trip
const stopTrip = async () => {
  if (watchId.value) {
    await Geolocation.clearWatch({ id: watchId.value })
    watchId.value = null
  }
  lastPosition.value = null
  sequenceNumber.value = 0
  currentRideId.value = null
  isTracking.value = false
  rideTitle.value = ''
}

// Toggle trip tracking
const toggleTrip = () => {
  if (isTracking.value) {
    stopTrip()
  } else if (!showTitleInput.value) {
    showTitleInput.value = true
  }
}

// Initialize map
onMounted(async () => {
  try {
    const token = useRuntimeConfig().public.mapboxToken
    if (!token) {
      throw new Error('Mapbox access token is not configured')
    }

    // Get current position using Capacitor
    const position = await Geolocation.getCurrentPosition({
      enableHighAccuracy: true,
      timeout: 5000
    })

    const { longitude, latitude } = position.coords

    mapboxgl.accessToken = token
    map.value = new mapboxgl.Map({
      container: mapContainer.value,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [longitude, latitude],
      zoom: 12,
      attributionControl: true
    })

    map.value.on('load', () => {
      loading.value = false
      map.value.addControl(new mapboxgl.NavigationControl(), 'top-right')

      new mapboxgl.Marker({
        color: '#FF0000'
      })
        .setLngLat([longitude, latitude])
        .addTo(map.value)

      new mapboxgl.Popup({ offset: 25 })
        .setLngLat([longitude, latitude])
        .setHTML('<h3 class="font-bold">Your Location</h3>')
        .addTo(map.value)
    })

    map.value.on('error', (e) => {
      console.error('Map error:', e)
      error.value = 'Error loading map: ' + e.message
      loading.value = false
    })

  } catch (err) {
    error.value = 'Error loading map: ' + err.message
    loading.value = false
    console.error('Map error:', err)
  }
})

// Clean up
onUnmounted(async () => {
  if (watchId.value) {
    await Geolocation.clearWatch({ id: watchId.value })
  }
  if (map.value) {
    map.value.remove()
  }
})
</script>

<style>
.mapboxgl-popup-content {
  @apply p-4 rounded-lg shadow-lg;
}

.mapboxgl-ctrl-attrib {
  @apply text-xs;
}

.mapboxgl-ctrl-attrib a {
  @apply text-blue-600 hover:text-blue-800;
}

/* Ensure the map container has proper dimensions */
.mapboxgl-canvas {
  width: 100% !important;
  height: 100% !important;
}
</style> 