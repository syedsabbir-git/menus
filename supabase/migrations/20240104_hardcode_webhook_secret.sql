-- Supabase blocks ALTER DATABASE for custom settings.
-- Hardcode the webhook secret directly in the trigger function instead.
-- This is safe — the function runs server-side and is never exposed to clients.

CREATE OR REPLACE FUNCTION public.trigger_notify_menu_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM net.http_post(
    url     := 'https://mslvfnbggfjcrxbvdvhf.supabase.co/functions/v1/notify-menu-post',
    headers := jsonb_build_object(
      'Content-Type',     'application/json',
      'x-webhook-secret', 'c0ffc4aa15d9743c30fbb44ad16a6168'
    ),
    body    := jsonb_build_object(
      'type',   TG_OP,
      'table',  TG_TABLE_NAME,
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$;
