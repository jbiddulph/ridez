<template>
  <div class="min-h-screen bg-gray-100 dark:bg-gray-900 pb-16">
    <slot />
    <!-- Bottom Tab Navigation -->
    <nav class="fixed bottom-0 left-0 right-0 bg-gray-100 dark:bg-gray-900 border-t-2 border-gray-200 dark:border-gray-700 z-50">
      <div class="flex justify-around items-center h-[100px] max-w-screen-lg mx-auto">
        <NuxtLink 
          to="/trips" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 dark:hover:text-[#d8c856] hover:text-[#af9f29] border-r border-gray-200 dark:border-gray-700"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          <span class="text-sm mt-1">Trips</span>
        </NuxtLink>

        <NuxtLink 
          to="/about" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 dark:hover:text-[#d8c856] hover:text-[#af9f29]"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span class="text-sm mt-1">Info</span>
        </NuxtLink>

        <NuxtLink 
          to="/" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 dark:hover:text-[#d8c856] hover:text-[#af9f29] border-x-2 border-gray-200 dark:border-gray-700"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A2 2 0 013 15.382V5.618a2 2 0 011.553-1.946l5.447-2.724a2 2 0 011.894 0l5.447 2.724A2 2 0 0121 5.618v9.764a2 2 0 01-1.553 1.946L15 20m-6 0v-8m6 8v-8" />
          </svg>
          <span class="text-sm mt-1">Map</span>
        </NuxtLink>

        <NuxtLink 
          to="/reports" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 dark:hover:text-[#d8c856] hover:text-[#af9f29]"
          :class="{ 'pointer-events-none opacity-50': isTracking }"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2a4 4 0 018 0v2m-4 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span class="text-sm mt-1">Reports</span>
        </NuxtLink>

        <NuxtLink 
          to="/settings" 
          class="flex flex-col items-center justify-center w-full h-full text-gray-600 dark:hover:text-[#d8c856] hover:text-[#af9f29] border-l border-gray-200 dark:border-gray-700"
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
import { useDarkMode } from '~/composables/useDarkMode'
import { onMounted } from 'vue'

const { isTracking } = useTripTracking()
const { fetchDarkMode } = useDarkMode()

onMounted(() => {
  fetchDarkMode()
})
</script>

<style>
/* Add any layout-specific styles here */
.router-link-active {
  @apply text-[#6c6217];
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