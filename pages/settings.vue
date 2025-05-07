<template>
  <div class="min-h-screen bg-gray-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold mb-6">Settings</h1>

        <div v-if="user" class="space-y-6">
          <!-- Profile Section -->
          <div class="border-b pb-6">
            <h2 class="text-xl font-semibold mb-4">Profile</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <p class="mt-1 text-gray-900">{{ user.email }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">User ID</label>
                <p class="mt-1 text-gray-900">{{ user.id }}</p>
              </div>
            </div>
          </div>

          <!-- Preferences Section -->
          <div class="border-b pb-6">
            <h2 class="text-xl font-semibold mb-4">Preferences</h2>
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <label class="text-sm font-medium text-gray-700">Dark Mode</label>
                  <p class="text-sm text-gray-500">Enable dark mode for the app</p>
                </div>
                <button 
                  @click="toggleDarkMode"
                  class="relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none"
                  :class="isDarkMode ? 'bg-blue-600' : 'bg-gray-200'"
                >
                  <span 
                    class="pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                    :class="isDarkMode ? 'translate-x-5' : 'translate-x-0'"
                  />
                </button>
              </div>
            </div>
          </div>

          <!-- Account Actions -->
          <div class="space-y-4">
            <h2 class="text-xl font-semibold">Account Actions</h2>
            <button 
              @click="handleSignOut"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
            >
              Sign Out
            </button>
          </div>
        </div>

        <div v-else class="text-center py-8">
          <p class="text-gray-600">Please sign in to view your settings</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()
const isDarkMode = ref(false)

definePageMeta({
  layout: 'default'
})

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  // TODO: Implement dark mode functionality
}

const handleSignOut = async () => {
  try {
    const { error } = await client.auth.signOut()
    if (error) throw error
    // Redirect to home page after sign out
    navigateTo('/')
  } catch (error) {
    console.error('Error signing out:', error.message)
  }
}
</script> 