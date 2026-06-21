-- Webhook trigger: fires the notify-menu-post Edge Function on menu post insert.
-- Uses pg_net (enabled by default on all Supabase projects).
-- Authentication uses a WEBHOOK_SECRET stored as a Postgres setting.

CREATE OR REPLACE FUNCTION public.trigger_notify_menu_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  project_url    TEXT := 'https://mslvfnbggfjcrxbvdvhf.supabase.co';
  webhook_secret TEXT := current_setting('app.settings.webhook_secret', true);
BEGIN
  PERFORM net.http_post(
    url     := project_url || '/functions/v1/notify-menu-post',
    headers := jsonb_build_object(
      'Content-Type',       'application/json',
      'x-webhook-secret',   webhook_secret
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

DROP TRIGGER IF EXISTS on_menu_post_inserted ON public.daily_menu_posts;

CREATE TRIGGER on_menu_post_inserted
  AFTER INSERT ON public.daily_menu_posts
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_notify_menu_post();
