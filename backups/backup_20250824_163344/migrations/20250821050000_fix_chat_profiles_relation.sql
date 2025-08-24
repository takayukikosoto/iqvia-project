-- Fix chat_messages and profiles relationship for proper JOIN operations

-- Step 1: Ensure profiles table exists for all auth.users
-- This is already handled by existing triggers, but let's make sure

-- Step 2: Update Chat.tsx query approach - use left join instead of inner join
-- to handle cases where profiles might not exist yet

-- Step 3: Add foreign key constraint for better referential integrity (optional)
-- Only add if we want strict referential integrity

-- For now, let's create a view that makes the JOIN easier and more reliable
create or replace view public.chat_messages_with_profiles as
select 
  cm.id,
  cm.project_id,
  cm.user_id,
  cm.content,
  cm.created_at,
  coalesce(p.display_name, 'User ' || left(cm.user_id::text, 8)) as display_name,
  coalesce(p.company, '会社名未設定') as company
from chat_messages cm
left join profiles p on cm.user_id = p.user_id;

-- Grant necessary permissions
grant select on public.chat_messages_with_profiles to authenticated;

-- Add RLS policy for the view (inherits from chat_messages policies)
alter view public.chat_messages_with_profiles set (security_invoker = true);
