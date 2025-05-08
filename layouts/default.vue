<template>
  <div class="min-h-screen bg-gray-100 pb-16">
    <slot />
    <!-- Bottom Tab Navigation -->
    <nav class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50">
      <div class="flex justify-around items-center h-20 max-w-screen-lg mx-auto">
        <NuxtLink 
          to="/" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 hover:text-blue-600"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
          <span class="text-sm mt-1">Home</span>
        </NuxtLink>

        <NuxtLink 
          to="/about" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 hover:text-blue-600"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span class="text-sm mt-1">About</span>
        </NuxtLink>

        <NuxtLink 
          to="/trips" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 hover:text-blue-600"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          <span class="text-sm mt-1">Trips</span>
        </NuxtLink>

        <NuxtLink 
          to="/faqs" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 hover:text-blue-600"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span class="text-sm mt-1">FAQs</span>
        </NuxtLink>

        <NuxtLink 
          to="/settings" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 hover:text-blue-600"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <span class="text-sm mt-1">Settings</span>
        </NuxtLink>
      </div>
    </nav>
  </div>
</template>

<script setup>
import { useTripTracking } from '~/composables/useTripTracking'

const { isTracking } = useTripTracking()
</script>

<style>
/* Add any layout-specific styles here */
.router-link-active {
  @apply text-blue-600;
}

/* Ensure the navigation is visible on mobile devices */
@media (max-width: 640px) {
  nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
  }
}
</style> 