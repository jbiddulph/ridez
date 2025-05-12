import { ref } from 'vue'
import { useSupabaseClient, useSupabaseUser } from '#imports'

const isDarkMode = ref(false)

export function useDarkMode() {
  const client = useSupabaseClient()
  const user = useSupabaseUser()

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
      updateHtmlClass()
    }
  }

  // Set dark mode and update DB
  const setDarkMode = async (value) => {
    isDarkMode.value = value
    updateHtmlClass()
    if (user.value) {
      await client.from('ridez_settings').upsert({
        user_id: user.value.id,
        dark_mode: value
      }, { onConflict: 'user_id' })
    }
  }

  // Update <html> class
  const updateHtmlClass = () => {
    if (isDarkMode.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  return { isDarkMode, fetchDarkMode, setDarkMode }
} 