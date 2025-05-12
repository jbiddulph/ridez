<template>
  <div class="relative w-full h-full">
    <div ref="mapContainer" class="absolute inset-0 w-full h-full"></div>
    <div v-if="error" class="absolute top-4 left-4 right-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded z-10">
      {{ error }}
    </div>
    <div v-if="!authReady" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10">
      <div class="text-lg font-medium text-gray-700">Redirecting to settings...</div>
    </div>
    <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10">
      <div class="text-lg font-medium text-gray-700">Loading map...</div>
    </div>
    <div class="absolute bottom-[200px] left-4 right-4 flex justify-center z-[100]">
      <button
        v-if="!showTitleInput"
        @click="isTracking ? stopTrip() : showTitleInput = true"
        :class="[
          'px-6 py-3 rounded-full font-bold text-white shadow-lg transition-all',
          isTracking
            ? 'bg-red-600 hover:bg-red-700'
            : 'bg-green-600 hover:bg-green-700'
        ]"
        :disabled="!authReady"
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
            class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed z-[62px]"
          >
            GO
          </button>
        </div>
      </div>
    </div>

    <!-- End Trip Modal -->
    <div v-if="showEndTripModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[200]" style="margin-top: -100px;">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <h3 class="text-xl font-bold mb-4">End Trip Details</h3>
        <form @submit.prevent="submitEndTripDetails" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-3">Transport Type</label>
            <div class="grid grid-cols-3 gap-3">
              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transport_type === 'walk'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transport_type"
                  value="walk"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2" 
                  :class="endTripDetails.transport_type === 'walk' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transport_type === 'walk'}">Walk</span>
              </label>

              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transport_type === 'cycle'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transport_type"
                  value="cycle"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2"
                  :class="endTripDetails.transport_type === 'cycle' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transport_type === 'cycle'}">Cycle</span>
              </label>

              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transport_type === 'drive'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transport_type"
                  value="drive"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2"
                  :class="endTripDetails.transport_type === 'drive' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transport_type === 'drive'}">Drive</span>
              </label>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-3">Transaction Type</label>
            <div class="grid grid-cols-3 gap-3">
              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transaction_type === 'spending'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transaction_type"
                  value="spending"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2"
                  :class="endTripDetails.transaction_type === 'spending' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transaction_type === 'spending'}">Spending</span>
              </label>

              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transaction_type === 'earning'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transaction_type"
                  value="earning"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2"
                  :class="endTripDetails.transaction_type === 'earning' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transaction_type === 'earning'}">Earning</span>
              </label>

              <label class="relative flex flex-col items-center p-3 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors"
                :class="{'bg-blue-50 border-blue-500': endTripDetails.transaction_type === 'na'}">
                <input
                  type="radio"
                  v-model="endTripDetails.transaction_type"
                  value="na"
                  class="absolute opacity-0 w-0 h-0"
                />
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 mb-2"
                  :class="endTripDetails.transaction_type === 'na' ? 'text-blue-600' : 'text-gray-600'"
                  fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
                <span class="text-sm font-medium" :class="{'text-blue-600': endTripDetails.transaction_type === 'na'}">N/A</span>
              </label>
            </div>
          </div>

          <div>
            <label for="amount" class="block text-sm font-medium text-gray-700 mb-2">Amount</label>
            <input
              id="amount"
              v-model="endTripDetails.amount"
              type="number"
              step="0.01"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter amount"
            />
          </div>

          <div>
            <label for="notes" class="block text-sm font-medium text-gray-700 mb-2">Notes</label>
            <textarea
              id="notes"
              v-model="endTripDetails.notes"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Add any notes about the trip"
            ></textarea>
          </div>

          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="cancelEndTrip"
              class="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
            >
              Save Trip Details
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import { Geolocation } from '@capacitor/geolocation'
import { useSupabaseClient, useSupabaseUser } from '#imports'
import { useRouter } from 'vue-router'
import { useTripTracking } from '~/composables/useTripTracking'

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
const router = useRouter()
const showTitleInput = ref(false)
const rideTitle = ref('')
const currentRideId = ref(null)
const markers = ref([])
const isFollowing = ref(false)
const authReady = ref(false)
const showEndTripModal = ref(false)
const markerPreferences = ref({
  marker_color: '#00FF00',
  marker_scale: 0.5
})
const endTripDetails = ref({
  transport_type: '',
  transaction_type: '',
  amount: '',
  notes: ''
})
const { setTracking } = useTripTracking()
const currentLocationMarker = ref(null)
const currentAccuracyCircle = ref(null)

// Function to fetch user marker preferences
const fetchMarkerPreferences = async () => {
  if (!user.value) return

  try {
    console.log('Fetching marker settings for user:', user.value.id)
    const { data, error: fetchError } = await client
      .from('ridez_settings')
      .select('marker_color, marker_scale')
      .eq('user_id', user.value.id)
      .single()

    if (fetchError) {
      // If no settings exist, create default settings for the user
      if (fetchError.code === 'PGRST116') {
        console.log('No settings found, creating default settings')
        const { data: newSettings, error: insertError } = await client
          .from('ridez_settings')
          .insert({
            user_id: user.value.id,
            marker_color: '#00FF00',
            marker_scale: 0.5
          })
          .select()
          .single()

        if (insertError) {
          console.error('Error creating default settings:', insertError)
          return
        }

        markerPreferences.value = {
          marker_color: newSettings.marker_color,
          marker_scale: newSettings.marker_scale
        }
      } else {
        console.error('Error fetching marker settings:', fetchError)
        return
      }
    } else if (data) {
      console.log('Found marker settings:', data)
      markerPreferences.value = {
        marker_color: data.marker_color,
        marker_scale: data.marker_scale
      }

      // Update any existing markers with new preferences
      markers.value.forEach(marker => {
        marker.setColor(markerPreferences.value.marker_color)
        marker.setScale(markerPreferences.value.marker_scale)
      })
    }
  } catch (err) {
    console.error('Error in fetchMarkerPreferences:', err)
  }
}

// Function to update marker preferences
const updateMarkerPreferences = async (newColor, newScale) => {
  if (!user.value) return

  try {
    console.log('Updating marker preferences for user:', user.value.id, {
      newColor,
      newScale
    })

    // First check if settings exist
    const { data: existingSettings, error: checkError } = await client
      .from('ridez_settings')
      .select('id')
      .eq('user_id', user.value.id)
      .single()

    if (checkError && checkError.code !== 'PGRST116') {
      console.error('Error checking existing settings:', checkError)
      return
    }

    let result
    if (existingSettings) {
      // Update existing row
      console.log('Updating existing settings row:', existingSettings.id)
      const { data, error: updateError } = await client
        .from('ridez_settings')
        .update({
          marker_color: newColor,
          marker_scale: newScale
        })
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (updateError) {
        console.error('Error updating marker settings:', updateError)
        return
      }
      result = data
    } else {
      // Create new row if none exists
      console.log('Creating new settings row for user')
      const { data, error: insertError } = await client
        .from('ridez_settings')
        .insert({
          user_id: user.value.id,
          marker_color: newColor,
          marker_scale: newScale
        })
        .select()
        .single()

      if (insertError) {
        console.error('Error creating marker settings:', insertError)
        return
      }
      result = data
    }

    console.log('Successfully updated marker preferences:', result)
    markerPreferences.value = {
      marker_color: result.marker_color,
      marker_scale: result.marker_scale
    }

    // Update existing markers
    markers.value.forEach(marker => {
      marker.setColor(markerPreferences.value.marker_color)
      marker.setScale(markerPreferences.value.marker_scale)
    })
  } catch (err) {
    console.error('Error in updateMarkerPreferences:', err)
  }
}

// Watch for user changes and fetch preferences
watch(user, (newUser) => {
  console.log('User state changed:', {
    isAuthenticated: !!newUser,
    userId: newUser?.id,
    email: newUser?.email
  })
  authReady.value = !!newUser
  if (newUser) {
    fetchMarkerPreferences()
    console.log('Marker preferences:', markerPreferences.value)
  } else {
    router.push('/settings')
  }
}, { immediate: true })

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
    if (!user.value) {
      error.value = 'Please sign in to start tracking'
      return null
    }

    const insertData = {
      user_id: user.value.id,
      title: rideTitle.value.trim()
    }
    console.log('Attempting to insert:', insertData)

    const { data, error: insertError } = await client
      .from('ridez_rides')
      .insert(insertData)
      .select()
      .single()

    if (insertError) {
      console.error('Insert error details:', {
        code: insertError.code,
        message: insertError.message,
        details: insertError.details,
        hint: insertError.hint,
        status: insertError.status
      })
      throw insertError
    }

    console.log('Successfully created ride:', data)
    return data.id
  } catch (err) {
    console.error('Error creating ride:', err)
    error.value = 'Error creating ride: ' + (err.message || JSON.stringify(err))
    return null
  }
}

// Handle position updates
const handlePositionUpdate = async (position) => {
  if (!isTracking.value || !currentRideId.value) return

  const latitude = position.coords?.latitude
  const longitude = position.coords?.longitude
  const accuracy = position.coords?.accuracy

  if (typeof latitude !== 'number' || typeof longitude !== 'number') {
    console.error('Invalid coordinates:', position)
    return
  }

  const distance = lastPosition.value
    ? calculateDistance(
        lastPosition.value.latitude,
        lastPosition.value.longitude,
        latitude,
        longitude
      )
    : 0

  // Always update the blue dot and accuracy circle
  if (map.value) {
    // Remove previous marker/circle
    if (currentLocationMarker.value) currentLocationMarker.value.remove();
    if (currentAccuracyCircle.value) currentAccuracyCircle.value.remove();

    // Add blue dot marker
    currentLocationMarker.value = new mapboxgl.Marker({
      color: '#007AFF', // iOS blue
      scale: 1.2
    })
      .setLngLat([longitude, latitude])
      .addTo(map.value);

    // Add accuracy circle (optional)
    if (accuracy && accuracy < 100) {
      const circle = new mapboxgl.Circle({
        center: [longitude, latitude],
        radius: accuracy,
        color: '#007AFF',
        fillOpacity: 0.1,
        strokeOpacity: 0.3
      });
      currentAccuracyCircle.value = circle.addTo(map.value);
    }

    // Always center the map on the current position
    map.value.flyTo({
      center: [longitude, latitude],
      zoom: 19,
      pitch: 60,
      essential: true,
      duration: 500
    });
  }

  // Calculate bearing and update map orientation
  if (lastPosition.value && (latitude !== lastPosition.value.latitude || longitude !== lastPosition.value.longitude)) {
    const bearing = calculateBearing(
      lastPosition.value.latitude,
      lastPosition.value.longitude,
      latitude,
      longitude
    );
    map.value.flyTo({
      center: [longitude, latitude],
      zoom: 19,
      pitch: 60,
      bearing: bearing,
      essential: true,
      duration: 500
    });
  }

  // Calculate distance from last marker
  let prev = lastPosition.value
  let dist = calculateDistance(prev.latitude, prev.longitude, latitude, longitude)
  if (dist < 1) return // Ignore noise

  if (dist >= 20) {
    // Interpolate points every 20m
    const points = interpolatePoints(prev.latitude, prev.longitude, latitude, longitude, 20)
    // Add all interpolated points (if any), then the current point
    for (const pt of points) {
      try {
        const { data: insertedPoint, error: insertError } = await client.from('ridez_routes').insert({
          user_id: user.value.id,
          ride_id: currentRideId.value,
          latitude: pt.latitude,
          longitude: pt.longitude,
          distance_from_last_point: 20,
          sequence_number: sequenceNumber.value++
        }).select().single()
        if (insertError) throw insertError
        const marker = new mapboxgl.Marker({
          color: markerPreferences.value.marker_color,
          scale: markerPreferences.value.marker_scale
        })
          .setLngLat([pt.longitude, pt.latitude])
          .addTo(map.value)
        markers.value.push(marker)
        // Update map bearing to direction of movement
        const bearing = calculateBearing(prev.latitude, prev.longitude, pt.latitude, pt.longitude)
        map.value.flyTo({
          center: [pt.longitude, pt.latitude],
          zoom: 19,
          pitch: 60,
          bearing: bearing,
          essential: true,
          duration: 500
        })
        prev = { latitude: pt.latitude, longitude: pt.longitude }
      } catch (err) {
        console.error('Error recording interpolated position:', err)
        error.value = 'Error recording position: ' + err.message
      }
    }
    // Add the actual GPS point if not exactly on a 20m interval
    const lastPt = points.length > 0 ? points[points.length - 1] : lastPosition.value
    if (lastPt.latitude !== latitude || lastPt.longitude !== longitude) {
      const lastSegDist = calculateDistance(lastPt.latitude, lastPt.longitude, latitude, longitude)
      try {
        const { data: insertedPoint, error: insertError } = await client.from('ridez_routes').insert({
          user_id: user.value.id,
          ride_id: currentRideId.value,
          latitude,
          longitude,
          distance_from_last_point: lastSegDist,
          sequence_number: sequenceNumber.value++
        }).select().single()
        if (insertError) throw insertError
        const marker = new mapboxgl.Marker({
          color: markerPreferences.value.marker_color,
          scale: markerPreferences.value.marker_scale
        })
          .setLngLat([longitude, latitude])
          .addTo(map.value)
        markers.value.push(marker)
        // Update map bearing
        const bearing = calculateBearing(lastPt.latitude, lastPt.longitude, latitude, longitude)
        map.value.flyTo({
          center: [longitude, latitude],
          zoom: 19,
          pitch: 60,
          bearing: bearing,
          essential: true,
          duration: 500
        })
        lastPosition.value = { latitude, longitude }
      } catch (err) {
        console.error('Error recording final position:', err)
        error.value = 'Error recording position: ' + err.message
      }
    } else {
      lastPosition.value = prev
    }
  } else {
    // Less than 20m, just update lastPosition for next time
    lastPosition.value = { latitude, longitude }
  }
}

// Start trip
const startTrip = async () => {
  try {
    console.log('Starting trip with auth state:', {
      authReady: authReady.value,
      user: user.value,
      userId: user.value?.id
    })

    if (!user.value) {
      error.value = 'Please sign in to start tracking'
      router.push('/login')
      return
    }

    if (!rideTitle.value.trim()) {
      error.value = 'Please enter a trip title'
      return
    }

    // Create ride record first
    const rideId = await createRide()
    if (!rideId) {
      return
    }

    currentRideId.value = rideId
    isTracking.value = true
    setTracking(true)
    isFollowing.value = true
    showTitleInput.value = false
    rideTitle.value = '' // Clear the title input

    // Get current position
    const position = await Geolocation.getCurrentPosition({
      enableHighAccuracy: true,
      timeout: 5000
    })

    // Start location tracking
    const isNative = window.Capacitor?.isNative
    if (isNative) {
      // Request background location permission for native platforms
      await Geolocation.requestPermissions()
      
      // Start watching position with Capacitor
      watchId.value = await Geolocation.watchPosition(
        {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0,
          distanceFilter: 2 // Reduced minimum distance between updates
        },
        (position) => {
          handlePositionUpdate(position)
        },
        (error) => {
          console.error('Geolocation error:', error)
          error.value = 'Error getting location: ' + error.message
        }
      )
    } else {
      // Use browser's geolocation for web
      if ('geolocation' in navigator) {
        watchId.value = navigator.geolocation.watchPosition(
          (position) => {
            handlePositionUpdate({
              coords: {
                latitude: position.coords.latitude,
                longitude: position.coords.longitude,
                accuracy: position.coords.accuracy
              }
            })
          },
          (error) => {
            console.error('Geolocation error:', error)
            error.value = 'Error getting location: ' + error.message
          },
          {
            enableHighAccuracy: true,
            timeout: 5000,
            maximumAge: 0
          }
        )
      } else {
        throw new Error('Geolocation is not supported by your browser')
      }
    }

    // Add initial marker
    const marker = new mapboxgl.Marker({
      color: markerPreferences.value.marker_color,
      scale: markerPreferences.value.marker_scale
    })
      .setLngLat([position.coords.longitude, position.coords.latitude])
      .addTo(map.value)
    
    markers.value.push(marker)

    // Insert initial position
    const { data: initialPoint, error: insertError } = await client.from('ridez_routes').insert({
      user_id: user.value.id,
      ride_id: currentRideId.value,
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
      distance_from_last_point: 0,
      sequence_number: sequenceNumber.value++
    }).select().single()

    if (insertError) {
      throw insertError
    }

    // Update last position
    lastPosition.value = {
      latitude: position.coords.latitude,
      longitude: position.coords.longitude
    }

    // Set initial map view
    map.value.flyTo({
      center: [position.coords.longitude, position.coords.latitude],
      zoom: 19,
      pitch: 60,
      essential: true,
      duration: 2000
    })

  } catch (err) {
    console.error('Error starting trip:', err)
    error.value = 'Failed to start trip: ' + err.message
  }
}

// Stop trip
const stopTrip = async () => {
  if (watchId.value) {
    // Check if we're running in a native environment
    const isNative = window.Capacitor?.isNative
    if (isNative) {
      await Geolocation.clearWatch({ id: watchId.value })
    } else {
      navigator.geolocation.clearWatch(watchId.value)
    }
    watchId.value = null
  }
  setTracking(false)
  showEndTripModal.value = true
}

// Add new function to handle end trip form submission
const submitEndTripDetails = async () => {
  try {
    if (!currentRideId.value) {
      throw new Error('No active ride found')
    }

    // Log the raw input values
    console.log('Raw input values:', endTripDetails.value)

    // Format and validate the data
    const formattedData = {
      end_time: new Date().toISOString(),
      transport_type: String(endTripDetails.value.transport_type || '').toLowerCase().trim(),
      transaction_type: String(endTripDetails.value.transaction_type || '').toLowerCase().trim(),
      amount: endTripDetails.value.amount ? parseFloat(endTripDetails.value.amount) : 0,
      notes: String(endTripDetails.value.notes || '').trim()
    }

    // Log the formatted data
    console.log('Formatted data:', formattedData)

    // Validate transport type
    if (!formattedData.transport_type || !['walk', 'cycle', 'drive'].includes(formattedData.transport_type)) {
      throw new Error('Please select a valid transport type (walk, cycle, or drive)')
    }

    // Validate transaction type
    if (!formattedData.transaction_type || !['spending', 'earning', 'na'].includes(formattedData.transaction_type)) {
      throw new Error('Please select a valid transaction type (spending, earning, or N/A)')
    }

    // Log the update attempt
    console.log('Attempting to update ride:', {
      rideId: currentRideId.value,
      formattedData
    })

    // First, verify the ride exists
    const { data: existingRide, error: fetchError } = await client
      .from('ridez_rides')
      .select('*')
      .eq('id', currentRideId.value)
      .single()

    if (fetchError) {
      console.error('Error fetching ride:', fetchError)
      throw new Error('Failed to verify ride exists')
    }

    if (!existingRide) {
      throw new Error('Ride not found')
    }

    console.log('Found existing ride:', existingRide)

    // Perform the update
    const { data, error: updateError } = await client
      .from('ridez_rides')
      .update(formattedData)
      .eq('id', currentRideId.value)
      .select()

    if (updateError) {
      console.error('Update error:', updateError)
      throw new Error(`Failed to update ride: ${updateError.message}`)
    }

    if (!data || data.length === 0) {
      throw new Error('Failed to update ride details')
    }

    console.log('Successfully updated ride:', data[0])

    // Reset the form and close modal
    endTripDetails.value = {
      transport_type: '',
      transaction_type: '',
      amount: '',
      notes: ''
    }
    showEndTripModal.value = false

    // Remove all green markers from the map
    markers.value.forEach(marker => marker.remove())
    markers.value = []

    // Reset map view
    isFollowing.value = false
    map.value.flyTo({
      zoom: 12,
      duration: 2000
    })

    lastPosition.value = null
    sequenceNumber.value = 0
    currentRideId.value = null
    isTracking.value = false
    rideTitle.value = ''
  } catch (err) {
    console.error('Error updating ride details:', err)
    error.value = 'Error updating ride details: ' + (err.message || JSON.stringify(err))
  }
}

// Add function to cancel end trip
const cancelEndTrip = () => {
  showEndTripModal.value = false
  // Reset the form
  endTripDetails.value = {
    transport_type: '',
    transaction_type: '',
    amount: '',
    notes: ''
  }
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
      style: 'mapbox://styles/mapbox/navigation-night-v1',
      center: [longitude, latitude],
      zoom: 12,
      pitch: 60,
      bearing: 0,
      attributionControl: true
    })

    map.value.on('load', () => {
      loading.value = false
      
      map.value.addControl(new mapboxgl.NavigationControl({
        showCompass: true,
        showZoom: true,
        visualizePitch: true
      }), 'bottom-right')

      map.value.addLayer({
        'id': '3d-buildings',
        'source': 'composite',
        'source-layer': 'building',
        'filter': ['==', 'extrude', 'true'],
        'type': 'fill-extrusion',
        'minzoom': 15,
        'paint': {
          'fill-extrusion-color': '#aaa',
          'fill-extrusion-height': [
            'interpolate',
            ['linear'],
            ['zoom'],
            15,
            0,
            15.05,
            ['get', 'height']
          ],
          'fill-extrusion-base': [
            'interpolate',
            ['linear'],
            ['zoom'],
            15,
            0,
            15.05,
            ['get', 'min_height']
          ],
          'fill-extrusion-opacity': 0.6
        }
      })

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