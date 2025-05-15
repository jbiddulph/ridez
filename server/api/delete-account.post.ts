import { defineEventHandler, readBody } from 'h3'
import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  // Only allow POST
  if (event.method !== 'POST') {
    return { error: 'Method not allowed' }
  }

  // Read user_id from body
  const body = await readBody(event)
  const { user_id } = body || {}
  if (!user_id) {
    return { error: 'Missing user_id' }
  }

  // Get Supabase service role key and project URL from env
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  const supabaseUrl = process.env.SUPABASE_URL
  if (!serviceRoleKey || !supabaseUrl) {
    return { error: 'Supabase service role key or URL not configured' }
  }

  // Create Supabase admin client
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false }
  })

  try {
    // Delete user from Supabase Auth
    const { error } = await adminClient.auth.admin.deleteUser(user_id)
    if (error) {
      return { error: error.message || 'Failed to delete user from auth' }
    }
    return { success: true }
  } catch (err) {
    const error = err instanceof Error ? err : new Error(String(err))
    return { error: error.message || 'Unknown error deleting user' }
  }
})