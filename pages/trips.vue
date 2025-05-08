<template>
  <div class="min-h-screen bg-gray-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white rounded-lg shadow-lg">
        <!-- Fixed Header -->
        <div class="p-6 border-b">
          <div class="flex justify-between items-center">
            <h1 class="text-3xl font-bold">Past Trips</h1>
            <div class="flex space-x-4">
              <!-- Month Dropdown -->
              <select 
                v-model="selectedMonth" 
                class="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option v-for="(month, index) in months" :key="index" :value="index">
                  {{ month }}
                </option>
              </select>

              <!-- Year Dropdown -->
              <select 
                v-model="selectedYear" 
                class="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option v-for="year in years" :key="year" :value="year">
                  {{ year }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <!-- Scrollable Content -->
        <div class="p-6 overflow-y-auto">
          <div v-if="loading" class="text-center py-4">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p class="mt-2 text-gray-600">Loading trips...</p>
          </div>
          <div v-else-if="error" class="text-red-600 p-4 bg-red-100 rounded-lg">
            {{ error }}
          </div>
          <div v-else-if="filteredTrips.length === 0" class="text-center py-8 text-gray-600">
            No trips recorded for the selected period. Start tracking your first trip!
          </div>
          <div v-else class="space-y-4">
            <!-- Group trips by day with accordions -->
            <div v-for="(dayTrips, date) in groupedTrips" :key="date" class="border-b last:border-b-0">
              <button 
                @click="toggleDay(date)"
                class="w-full text-left flex justify-between items-center py-4 focus:outline-none"
              >
                <div class="flex items-center">
                  <h2 class="text-xl font-semibold text-gray-800">
                    {{ formatDate(date) }}
                    <span class="ml-2 text-sm font-normal text-gray-500">
                      ({{ dayTrips.length }} {{ dayTrips.length === 1 ? 'trip' : 'trips' }})
                    </span>
                  </h2>
                </div>
                <span class="ml-6 flex-shrink-0">
                  <svg 
                    class="h-6 w-6 transform transition-transform duration-200"
                    :class="{ 'rotate-180': openDays[date] }"
                    fill="none" 
                    viewBox="0 0 24 24" 
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                  </svg>
                </span>
              </button>
              <div 
                v-show="openDays[date]"
                class="pb-4"
              >
                <div class="space-y-4">
                  <div 
                    v-for="trip in dayTrips" 
                    :key="trip.id" 
                    class="border rounded-lg p-4 hover:bg-gray-50 cursor-pointer transition-colors duration-150"
                    @click="openTripDetails(trip)"
                  >
                    <div class="flex justify-between items-start">
                      <div>
                        <h3 class="font-semibold text-lg">{{ trip.title }}</h3>
                        <p class="text-sm text-gray-600">
                          {{ new Date(trip.created_at).toLocaleTimeString() }}
                        </p>
                      </div>
                      <div class="text-right">
                        <span class="inline-block px-2 py-1 text-xs rounded-full" 
                              :class="{
                                'bg-green-100 text-green-800': trip.transport_type === 'walk',
                                'bg-blue-100 text-blue-800': trip.transport_type === 'cycle',
                                'bg-purple-100 text-purple-800': trip.transport_type === 'drive'
                              }">
                          {{ trip.transport_type }}
                        </span>
                      </div>
                    </div>
                    <div class="mt-2 text-sm text-gray-600">
                      <p v-if="trip.amount">
                        {{ trip.transaction_type === 'spending' ? 'Spent' : 'Earned' }}: ${{ trip.amount }}
                      </p>
                      <p v-if="trip.notes" class="mt-1">{{ trip.notes }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Trip Details Modal -->
    <TripDetailsModal
      :is-open="!!selectedTrip"
      :trip="selectedTrip"
      @close="selectedTrip = null"
    />
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const trips = ref([])
const loading = ref(true)
const error = ref('')
const selectedTrip = ref(null)

// Month and year selection
const months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]
const currentDate = new Date()
const selectedMonth = ref(currentDate.getMonth())
const selectedYear = ref(currentDate.getFullYear())

// Track open/closed state for each day
const openDays = ref({})

// Generate years array (current year and 5 years back)
const years = computed(() => {
  const currentYear = new Date().getFullYear()
  return Array.from({ length: 6 }, (_, i) => currentYear - i)
})

definePageMeta({
  layout: 'default'
})

// Format date for display
const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  })
}

// Toggle day accordion
const toggleDay = (date) => {
  openDays.value[date] = !openDays.value[date]
}

// Fetch trips when component is mounted
onMounted(async () => {
  try {
    if (!user.value) {
      error.value = 'Please sign in to view your trips'
      loading.value = false
      return
    }

    await fetchTrips()
  } catch (err) {
    console.error('Error fetching trips:', err)
    error.value = 'Error loading trips: ' + err.message
  } finally {
    loading.value = false
  }
})

// Function to fetch trips with date filtering
const fetchTrips = async () => {
  try {
    loading.value = true
    
    // Calculate start and end dates for the selected month and year
    const startDate = new Date(selectedYear.value, selectedMonth.value, 1)
    const endDate = new Date(selectedYear.value, selectedMonth.value + 1, 0)
    
    const { data, error: fetchError } = await client
      .from('ridez_rides')
      .select('*')
      .eq('user_id', user.value.id)
      .gte('created_at', startDate.toISOString())
      .lte('created_at', endDate.toISOString())
      .order('created_at', { ascending: false })

    if (fetchError) throw fetchError

    trips.value = data
  } catch (err) {
    console.error('Error fetching trips:', err)
    error.value = 'Error loading trips: ' + err.message
  } finally {
    loading.value = false
  }
}

// Watch for changes in month/year selection
watch([selectedMonth, selectedYear], () => {
  // Reset open days when changing month/year
  openDays.value = {}
  // Fetch trips for the new month/year
  fetchTrips()
})

// Remove the filteredTrips computed property since we're now filtering in the database
const filteredTrips = computed(() => trips.value)

// Group trips by day
const groupedTrips = computed(() => {
  const groups = {}
  trips.value.forEach(trip => {
    const date = new Date(trip.created_at)
    const dateKey = date.toISOString().split('T')[0]
    if (!groups[dateKey]) {
      groups[dateKey] = []
    }
    groups[dateKey].push(trip)
  })
  return groups
})

// Open trip details modal
const openTripDetails = async (trip) => {
  try {
    // Fetch the complete trip data including route
    const { data, error: fetchError } = await client
      .from('ridez_rides')
      .select('*, ridez_routes(*)')
      .eq('id', trip.id)
      .single()

    if (fetchError) throw fetchError

    selectedTrip.value = {
      ...data,
      route: data.ridez_routes?.coordinates || []
    }
  } catch (err) {
    console.error('Error fetching trip details:', err)
    error.value = 'Error loading trip details: ' + err.message
  }
}
</script> 