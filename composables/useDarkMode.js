import { ref, watchEffect } from 'vue'
import { useSupabaseClient, useSupabaseUser } from '#imports'

const isDarkMode = ref(false)

export function useDarkMode() {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

  // Always keep <html> class in sync with isDarkMode
  watchEffect(() => {
    if (typeof window !== 'undefined') {
      if (isDarkMode.value) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    }
  })

  // Fetch dark mode from DB
  const fetchDarkMode = async () => {
    if (!user.value) return
    const { data, error } = await client
      .from('ridez_settings')
      .select('dark_mode')
      .eq('user_id', user.value.id)
      .single()
    if (!error && data) {
      isDarkMode.value = !!data.dark_mode
    }
  }

  // Set dark mode and update DB
  const setDarkMode = async (value) => {
    isDarkMode.value = value
    if (user.value) {
      await client.from('ridez_settings').upsert({
        user_id: user.value.id,
        dark_mode: value
      }, { onConflict: 'user_id' })
    }
  }

  return { isDarkMode, fetchDarkMode, setDarkMode }
} 