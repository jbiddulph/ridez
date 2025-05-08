<template>
  <div class="min-h-screen bg-gray-100 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="bg-white rounded-lg shadow-lg p-6">
        <h1 class="text-3xl font-bold mb-6">Settings</h1>

        <!-- Authentication Forms -->
        <div v-if="!user" class="max-w-md mx-auto">
          <!-- Toggle between Login and Register -->
          <div class="flex justify-center space-x-4 mb-6">
            <button
              @click="isLogin = true"
              :class="[
                'px-4 py-2 rounded-md text-sm font-medium',
                isLogin
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-600 hover:text-gray-900'
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
                  : 'text-gray-600 hover:text-gray-900'
              ]"
            >
              Register
            </button>
          </div>

          <!-- Error Message -->
          <div v-if="error" class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
            {{ error }}
          </div>

          <!-- Login Form -->
          <form v-if="isLogin" @submit.prevent="handleSignIn" class="space-y-4">
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
              <input
                type="email"
                id="email"
                v-model="email"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
              <input
                type="password"
                id="password"
                v-model="password"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
            <button
              type="submit"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              :disabled="loading"
            >
              {{ loading ? 'Signing in...' : 'Sign In' }}
            </button>
          </form>

          <!-- Register Form -->
          <form v-else @submit.prevent="handleSignUp" class="space-y-4">
            <div>
              <label for="fullName" class="block text-sm font-medium text-gray-700">Full Name</label>
              <input
                type="text"
                id="fullName"
                v-model="fullName"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label for="registerEmail" class="block text-sm font-medium text-gray-700">Email</label>
              <input
                type="email"
                id="registerEmail"
                v-model="email"
                required
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label for="registerPassword" class="block text-sm font-medium text-gray-700">Password</label>
              <input
                type="password"
                id="registerPassword"
                v-model="password"
                required
                minlength="6"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <p class="mt-1 text-sm text-gray-500">Password must be at least 6 characters long</p>
            </div>
            <button
              type="submit"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              :disabled="loading"
            >
              {{ loading ? 'Creating account...' : 'Create Account' }}
            </button>
          </form>
        </div>

        <!-- Settings Content (only shown when user is logged in) -->
        <div v-else class="space-y-6">
          <!-- Profile Section -->
          <div class="border-b pb-6">
            <h2 class="text-xl font-semibold mb-4">Profile</h2>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <p class="mt-1 text-gray-900">{{ user.email }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Name</label>
                <p class="mt-1 text-gray-900">{{ user.user_metadata.full_name || 'Not set' }}</p>
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
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const email = ref('')
const password = ref('')
const fullName = ref('')
const loading = ref(false)
const error = ref('')
const isLogin = ref(true)
const isDarkMode = ref(false)

definePageMeta({
  layout: 'default'
})

// Redirect to settings if not logged in
onMounted(() => {
  if (!user.value) {
    router.push('/settings')
  }
})

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

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  // TODO: Implement dark mode functionality
}
</script> 