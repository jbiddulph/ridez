<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900 py-8">
    <div class="max-w-2xl mx-auto px-4">
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-8">Settings</h1>
      
      <!-- Authentication Forms -->
      <div v-if="!user" class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-6">
        <!-- Toggle between Login and Register -->
        <div class="flex justify-center space-x-4 mb-6">
          <button
            @click="isLogin = true"
            :class="[
              'px-4 py-2 rounded-md text-sm font-medium',
              isLogin
                ? 'bg-blue-600 text-white'
                : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
            ]"
          >
            Login
          </button>
          <button
            @click="isLogin = false"
            :class="[
              'px-4 py-2 rounded-md text-sm font-medium',
              !isLogin
                ? 'bg-blue-600 text-white'
                : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
            ]"
          >
            Register
          </button>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="mb-4 p-4 bg-red-100 dark:bg-red-900 border border-red-400 text-red-700 dark:text-red-200 rounded">
          {{ error }}
        </div>

        <!-- Login Form -->
        <form v-if="isLogin" @submit.prevent="handleSignIn" class="space-y-4">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
            <input
              type="email"
              id="email"
              v-model="email"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Password</label>
            <input
              type="password"
              id="password"
              v-model="password"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <button
            type="submit"
            class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            :disabled="loading"
          >
            {{ loading ? 'Signing in...' : 'Sign In' }}
          </button>
        </form>

        <!-- Register Form -->
        <form v-else @submit.prevent="handleSignUp" class="space-y-4">
          <div>
            <label for="fullName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Full Name</label>
            <input
              type="text"
              id="fullName"
              v-model="fullName"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label for="registerEmail" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
            <input
              type="email"
              id="registerEmail"
              v-model="email"
              required
              class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label for="registerPassword" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Password</label>
            <input
              type="password"
              id="registerPassword"
              v-model="password"
              required
              minlength="6"
              class="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Password must be at least 6 characters long</p>
          </div>
          <button
            type="submit"
            class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            :disabled="loading"
          >
            {{ loading ? 'Creating account...' : 'Create Account' }}
          </button>
        </form>
      </div>

      <!-- Settings Content (only shown when user is logged in) -->
      <div v-else class="space-y-6">
        <!-- Profile Section -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h2 class="text-xl font-semibold mb-4 text-gray-900 dark:text-white">Profile</h2>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
              <p class="mt-1 text-gray-900 dark:text-white">{{ user.email }}</p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
              <p class="mt-1 text-gray-900 dark:text-white">{{ user.user_metadata.full_name || 'Not set' }}</p>
            </div>
          </div>
        </div>

        <!-- Marker Settings -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 space-y-6">
          <h2 class="text-xl font-semibold mb-4 text-gray-900 dark:text-white">Marker Settings</h2>
          
          <!-- Marker Color -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Marker Color
            </label>
            <div class="flex items-center space-x-4">
              <input
                type="color"
                v-model="markerColor"
                class="h-10 w-20 rounded cursor-pointer"
              />
              <input
                type="text"
                v-model="markerColor"
                class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="#00FF00"
              />
            </div>
          </div>

          <!-- Marker Scale -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Marker Scale: {{ markerScale }}
            </label>
            <input
              type="range"
              v-model="markerScale"
              min="0.1"
              max="2"
              step="0.1"
              class="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-lg appearance-none cursor-pointer"
            />
          </div>

          <!-- Currency Selector -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Currency
            </label>
            <select
              v-model="currency"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="GBP">GBP (£)</option>
              <option value="USD">USD ($)</option>
              <option value="EUR">EUR (€)</option>
              <option value="AUD">AUD (A$)</option>
              <option value="CAD">CAD (C$)</option>
            </select>
          </div>

          <!-- Car Icon -->
          <div class="mb-6">
            <label class="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Car Icon</label>
            <div class="flex gap-4 items-center">
              <label v-for="icon in availableIcons" :key="icon.value || 'blank'" class="flex flex-col items-center cursor-pointer text-gray-900 dark:text-white">
                <input
                  type="radio"
                  name="my_icon"
                  :value="icon.value"
                  v-model="markerPreferences.my_icon"
                  class="mb-2"
                />
                <span v-if="icon.value">
                  <img :src="icon.value" alt="icon" class="w-10 h-10 object-contain rounded-full border" />
                </span>
                <span v-else class="w-10 h-10 flex items-center justify-center border rounded-full bg-gray-500 text-xs text-white">None</span>
                <span class="text-xs mt-1">{{ icon.label }}</span>
              </label>
            </div>
          </div>

          <!-- Save Button -->
          <button
            @click="saveSettings"
            class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            Save Settings
          </button>
        </div>

        <!-- Preferences Section -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h2 class="text-xl font-semibold mb-4 text-gray-900 dark:text-white">Preferences</h2>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Dark Mode</label>
                <p class="text-sm text-gray-500 dark:text-gray-400">Enable dark mode for the app</p>
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
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h2 class="text-xl font-semibold mb-4 text-gray-900 dark:text-white">Account Actions</h2>
          <button
            @click="handleSignOut"
            class="w-full bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 mb-4"
          >
            Sign Out
          </button>
          <button
            @click="showDeleteConfirm = true"
            class="w-full bg-red-700 text-white py-2 px-4 rounded-md hover:bg-red-800 focus:outline-none focus:ring-2 focus:ring-red-600"
          >
            Delete Account & All Data
          </button>
        </div>

        <!-- Delete Account Confirmation Dialog -->
        <div v-if="showDeleteConfirm" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
          <div class="bg-white dark:bg-gray-900 rounded-lg shadow-lg p-8 max-w-md w-full">
            <h3 class="text-lg font-bold mb-4 text-gray-900 dark:text-white">Confirm Account Deletion</h3>
            <p class="mb-4 text-gray-700 dark:text-gray-200">
              This will <span class="font-semibold text-red-600">permanently delete</span>:
              <ul class="list-disc ml-6 mt-2 text-sm">
                <li>Your account and login credentials</li>
                <li>All your rides (ridez_rides)</li>
                <li>All your routes (ridez_routes)</li>
                <li>Your settings and preferences (ridez_settings)</li>
              </ul>
              <span class="block mt-2 text-red-600 font-semibold">This action cannot be undone.</span>
            </p>
            <div v-if="deleteError" class="mb-2 p-2 bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-200 rounded">{{ deleteError }}</div>
            <div class="flex justify-end gap-2">
              <button @click="showDeleteConfirm = false" class="px-4 py-2 rounded bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-white">Cancel</button>
              <button @click="deleteAccount" :disabled="deleteLoading" class="px-4 py-2 rounded bg-red-600 text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500">
                {{ deleteLoading ? 'Deleting...' : 'Yes, Delete Everything' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, reactive } from 'vue'
import { useSupabaseClient, useSupabaseUser } from '#imports'
import { useRouter } from 'vue-router'
import { Capacitor } from '@capacitor/core'
import { KeepAwake } from '@capacitor-community/keep-awake'
import { useDarkMode } from '~/composables/useDarkMode'

const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const email = ref('')
const password = ref('')
const fullName = ref('')
const loading = ref(false)
const error = ref('')
const isLogin = ref(true)
const markerColor = ref('#00FF00')
const markerScale = ref(0.5)
const wakeLock = ref(null)
const { isDarkMode, fetchDarkMode, setDarkMode } = useDarkMode()
const currency = ref('GBP')

const markerPreferences = reactive({ my_icon: null })

const availableIcons = [
  { label: 'Blank', value: null },
  { label: 'Car', value: '/assets/images/car-top-view-icon-11560.png' },
  { label: 'Chick', value: '/assets/images/chick.png' },
  { label: 'UFO', value: '/assets/images/ufo.png' },
  { label: 'Taxi', value: '/assets/images/Taxi_Icon.png' },
  { label: 'Uber', value: '/assets/images/uber.png' },
]

const loadSettings = async () => {
  if (!user.value) {
    console.log('[DEBUG] No user loaded in loadSettings');
    return
  }

  try {
    console.log('[DEBUG] Loading settings for user:', user.value.id)
    const { data, error } = await client
      .from('ridez_settings')
      .select('marker_color, marker_scale, my_icon, currency')
      .eq('user_id', user.value.id)
      .single()

    console.log('[DEBUG] Supabase response:', { data, error })

    if (error) throw error

    if (data) {
      console.log('[DEBUG] Loaded marker settings:', data)
      markerColor.value = data.marker_color || '#00FF00'
      markerScale.value = data.marker_scale || 0.5
      markerPreferences.my_icon = data.my_icon ?? null
      currency.value = data.currency || 'GBP'
    } else {
      console.log('[DEBUG] No data found for user, using defaults')
    }
  } catch (error) {
    console.error('[DEBUG] Error loading settings:', error)
  }
}

// Call on mount
onMounted(() => {
  loadSettings()
  fetchDarkMode()
})

// Watch for user changes
watch(user, (newUser) => {
  if (newUser) {
    loadSettings()
    fetchDarkMode()
  }
})

// Save settings
const saveSettings = async () => {
  if (!user.value) return

  try {
    const { error } = await client
      .from('ridez_settings')
      .upsert({
        user_id: user.value.id,
        marker_color: markerColor.value,
        marker_scale: markerScale.value,
        dark_mode: isDarkMode.value,
        my_icon: markerPreferences.my_icon,
        currency: currency.value
      }, { onConflict: 'user_id' })

    if (error) throw error

    // Show success message
    alert('Settings saved successfully!')
  } catch (error) {
    console.error('Error saving settings:', error)
    alert('Error saving settings')
  }
}

const handleSignIn = async () => {
  try {
    loading.value = true
    error.value = ''
    const { error: signInError } = await client.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    if (signInError) throw signInError
  } catch (err) {
    error.value = err.message || 'Error signing in'
    console.error('Error signing in:', err)
  } finally {
    loading.value = false
  }
}

const handleSignUp = async () => {
  try {
    loading.value = true
    error.value = ''
    
    // First, sign up the user
    const { data, error: signUpError } = await client.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        data: {
          full_name: fullName.value
        }
      }
    })

    if (signUpError) throw signUpError

    // If successful, show success message
    error.value = 'Registration successful! Please check your email to verify your account.'
    
    // Clear the form
    email.value = ''
    password.value = ''
    fullName.value = ''
    
    // Switch to login view
    isLogin.value = true
  } catch (err) {
    error.value = err.message || 'Error creating account'
    console.error('Error signing up:', err)
  } finally {
    loading.value = false
  }
}

const handleSignOut = async () => {
  try {
    loading.value = true
    error.value = ''
    const { error: signOutError } = await client.auth.signOut()
    if (signOutError) throw signOutError
  } catch (err) {
    error.value = err.message || 'Error signing out'
    console.error('Error signing out:', err)
  } finally {
    loading.value = false
  }
}

const toggleDarkMode = async () => {
  await setDarkMode(!isDarkMode.value)
  await fetchDarkMode()
}

const requestWakeLock = async () => {
  if (Capacitor.isNativePlatform()) {
    try {
      await KeepAwake.keepAwake()
      console.log('Native keep awake enabled')
    } catch (err) {
      console.error('Error enabling native keep awake:', err)
    }
  } else if ('wakeLock' in navigator) {
    try {
      wakeLock.value = await navigator.wakeLock.request('screen')
      console.log('Web wake lock enabled')
    } catch (err) {
      console.error('Error enabling web wake lock:', err)
    }
  }
}

const releaseWakeLock = async () => {
  if (Capacitor.isNativePlatform()) {
    try {
      await KeepAwake.allowSleep()
      console.log('Native keep awake released')
    } catch (err) {
      console.error('Error releasing native keep awake:', err)
    }
  } else if (wakeLock.value) {
    try {
      await wakeLock.value.release()
      wakeLock.value = null
      console.log('Web wake lock released')
    } catch (err) {
      console.error('Error releasing web wake lock:', err)
    }
  }
}

const showDeleteConfirm = ref(false)
const deleteLoading = ref(false)
const deleteError = ref('')

const deleteAccount = async () => {
  if (!user.value) return
  deleteLoading.value = true
  deleteError.value = ''
  try {
    // Delete from ridez_rides
    const { error: ridesError } = await client.from('ridez_rides').delete().eq('user_id', user.value.id)
    if (ridesError) throw ridesError
    // Delete from ridez_routes
    const { error: routesError } = await client.from('ridez_routes').delete().eq('user_id', user.value.id)
    if (routesError) throw routesError
    // Delete from ridez_settings
    const { error: settingsError } = await client.from('ridez_settings').delete().eq('user_id', user.value.id)
    if (settingsError) throw settingsError
    // Call server-side API to delete user from auth
    const res = await fetch('https://ridez-66c2d14c6c66.herokuapp.com/api/delete-account', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: user.value.id })
    })
    if (!res.ok) {
      const data = await res.json().catch(() => ({}))
      console.log('Delete response:', res.status, data);
      throw new Error(data.error || 'Failed to delete user from authentication')
    }
    // Sign out and redirect
    await client.auth.signOut()
    router.push('/')
    alert('Your account and all data have been deleted.')
  } catch (err) {
    deleteError.value = err.message || 'Error deleting account'
  } finally {
    deleteLoading.value = false
    showDeleteConfirm.value = false
  }
}
</script>

<style>
input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  height: 8px;
  border-radius: 4px;
  background: #e5e7eb;
  outline: none;
}

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
}

input[type="range"]::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
  border: none;
}

/* .dark input[type="range"] {
  background: #374151;
}

.dark input[type="range"]::-webkit-slider-thumb {
  background: #60a5fa;
}

.dark input[type="range"]::-moz-range-thumb {
  background: #60a5fa;
} */
</style> 