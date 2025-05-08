import { ref } from 'vue'

const isTracking = ref(false)

export function useTripTracking() {
  const setTracking = (value) => {
    isTracking.value = value
  }

  return {
    isTracking,
    setTracking
  }
} 