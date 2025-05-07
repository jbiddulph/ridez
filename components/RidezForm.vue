<template>
  <div class="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-4">Add New Ride</h2>
    <div v-if="error" class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
      {{ error }}
    </div>
    <div v-if="success" class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded">
      {{ success }}
    </div>
    <div v-if="!user" class="mb-4 p-4 bg-yellow-100 border border-yellow-400 text-yellow-700 rounded">
      Please sign in to add a ride
    </div>
    <form @submit.prevent="handleSubmit" class="space-y-4" :class="{ 'opacity-50': !user }">
      <div>
        <label for="title" class="block text-sm font-medium text-gray-700">Title</label>
        <input
          type="text"
          id="title"
          v-model="title"
          required
          :disabled="!user"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          placeholder="Enter ride title"
        />
      </div>
      <button
        type="submit"
        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        :disabled="loading || !user"
      >
        {{ loading ? 'Adding...' : 'Add Ride' }}
      </button>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const client = useSupabaseClient()
const user = useSupabaseUser()
const title = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

const handleSubmit = async () => {
  try {
    error.value = ''
    success.value = ''
    loading.value = true

    if (!user.value) {
      throw new Error('Please sign in to add a ride')
    }

    // Log the user's authentication state
    console.log('User auth state:', {
      isAuthenticated: !!user.value,
      userId: user.value?.id,
      email: user.value?.email
    })

    const { data, error: insertError } = await client
      .from('ridez_rides')
      .insert([{ 
        title: title.value,
        user_id: user.value.id
      }])
      .select()

    if (insertError) {
      console.error('Insert error details:', {
        code: insertError.code,
        message: insertError.message,
        details: insertError.details,
        hint: insertError.hint
      })
      throw new Error(insertError.message || 'Error adding ride')
    }

    success.value = 'Ride added successfully!'
    title.value = ''
  } catch (err) {
    error.value = err.message || 'Error adding ride'
    console.error('Error adding ride:', err)
  } finally {
    loading.value = false
  }
}
</script> 