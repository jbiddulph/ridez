import { defineEventHandler, readBody, getHeader } from 'h3'
import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  console.log('[delete-account] Route hit');

  // Get JWT from Authorization header
  const authHeader = getHeader(event, 'authorization');
  if (!authHeader) {
    console.log('[delete-account] No auth header');
    return { error: 'No auth header' };
  }
  const token = authHeader.replace('Bearer ', '');

  // Create Supabase client with anon key for user verification
  const anonKey = process.env.SUPABASE_ANON_KEY;
  const supabaseUrl = process.env.SUPABASE_URL;
  if (!anonKey || !supabaseUrl) {
    console.log('[delete-account] Missing anon key or supabase url');
    return { error: 'Missing anon key or supabase url' };
  }
  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } }
  });

  // Get user from token
  const { data: { user }, error: userError } = await supabase.auth.getUser();
  if (userError || !user) {
    console.log('[delete-account] Invalid user', userError);
    return { error: 'Invalid user' };
  }

  // Read user_id from body
  const { user_id } = await readBody(event);
  if (user.id !== user_id) {
    console.log('[delete-account] Unauthorized: user mismatch', user.id, user_id);
    return { error: 'Unauthorized' };
  }

  // Check service role key for admin actions
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    console.log('[delete-account] Missing service role key');
    return { error: 'Missing service role key' };
  }
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false }
  });

  try {
    // Delete user from Supabase Auth
    const { error } = await adminClient.auth.admin.deleteUser(user_id);
    if (error) {
      console.error('[delete-account] Supabase deleteUser error:', error);
      return { error: error.message || 'Failed to delete user from auth', details: error };
    }
    console.log('[delete-account] User deleted successfully from Supabase Auth');
    return { success: true };
  } catch (err) {
    const error = err instanceof Error ? err : new Error(String(err));
    console.error('[delete-account] Exception:', error);
    return { error: error.message || 'Unknown error deleting user', details: error };
  }
}); 