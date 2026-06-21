-- Wrap the trigger body in EXCEPTION so a notification failure
-- never rolls back the menu post INSERT.

CREATE OR REPLACE FUNCTION public.trigger_notify_menu_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
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
  EXCEPTION WHEN OTHERS THEN
    -- Log the error but never block the INSERT
    RAISE WARNING 'notify_menu_post trigger error: %', SQLERRM;
  END;
  RETURN NEW;
END;
$$;
