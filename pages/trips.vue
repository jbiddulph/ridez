<template>
  <div class="min-h-screen bg-gray-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold mb-6">Past Trips</h1>
        <div v-if="loading" class="text-center py-4">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p class="mt-2 text-gray-600">Loading trips...</p>
        </div>
        <div v-else-if="error" class="text-red-600 p-4 bg-red-100 rounded-lg">
          {{ error }}
        </div>
        <div v-else-if="trips.length === 0" class="text-center py-8 text-gray-600">
          No trips recorded yet. Start tracking your first trip!
        </div>
        <div v-else class="space-y-4">
          <div v-for="trip in trips" :key="trip.id" class="border rounded-lg p-4 hover:bg-gray-50">
            <div class="flex justify-between items-start">
              <div>
                <h3 class="font-semibold text-lg">{{ trip.title }}</h3>
                <p class="text-sm text-gray-600">
                  {{ new Date(trip.created_at).toLocaleDateString() }}
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
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()
const trips = ref([])
const loading = ref(true)
const error = ref('')

definePageMeta({
  layout: 'default'
})

// Fetch trips when component is mounted
onMounted(async () => {
  try {
    if (!user.value) {
      error.value = 'Please sign in to view your trips'
      loading.value = false
      return
    }

    const { data, error: fetchError } = await client
      .from('ridez_rides')
      .select('*')
      .eq('user_id', user.value.id)
      .order('created_at', { ascending: false })

    if (fetchError) throw fetchError

    trips.value = data
  } catch (err) {
    console.error('Error fetching trips:', err)
    error.value = 'Error loading trips: ' + err.message
  } finally {
    loading.value = false
  }
})
</script> 