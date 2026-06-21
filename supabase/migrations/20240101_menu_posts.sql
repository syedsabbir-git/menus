-- Daily menu posts feature
-- Run this in the Supabase SQL editor or via supabase db push

-- ── 1. meal_type enum ────────────────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE meal_type AS ENUM ('breakfast', 'lunch', 'dinner');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ── 2. daily_menu_posts ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_menu_posts (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID        NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  meal_type     meal_type   NOT NULL,
  delivery_window TEXT,
  note          TEXT,
  posted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  posted_by     UUID        NOT NULL REFERENCES profiles(id)
);

ALTER TABLE daily_menu_posts ENABLE ROW LEVEL SECURITY;

-- Anyone can read posts (customers browse)
CREATE POLICY "public read menu posts"
  ON daily_menu_posts FOR SELECT USING (true);

-- Only the vendor who owns the restaurant can insert
CREATE POLICY "vendor insert menu post"
  ON daily_menu_posts FOR INSERT
  WITH CHECK (
    posted_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM restaurants
      WHERE restaurants.id = restaurant_id
        AND restaurants.owner_id = auth.uid()
    )
  );

-- Vendor can delete their own posts
CREATE POLICY "vendor delete own posts"
  ON daily_menu_posts FOR DELETE
  USING (posted_by = auth.uid());

-- ── 3. daily_menu_post_items ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_menu_post_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id      UUID NOT NULL REFERENCES daily_menu_posts(id) ON DELETE CASCADE,
  menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE
);

ALTER TABLE daily_menu_post_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read post items"
  ON daily_menu_post_items FOR SELECT USING (true);

CREATE POLICY "vendor insert post items"
  ON daily_menu_post_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM daily_menu_posts dp
      JOIN restaurants r ON r.id = dp.restaurant_id
      WHERE dp.id = post_id AND r.owner_id = auth.uid()
    )
  );

-- ── 4. device_tokens ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS device_tokens (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  fcm_token  TEXT        NOT NULL,
  platform   TEXT        NOT NULL CHECK (platform IN ('android', 'ios')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, fcm_token)
);

ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Users manage their own tokens
CREATE POLICY "user manage own tokens"
  ON device_tokens FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Service role (Edge Function) can read all tokens to send notifications
-- This is handled by the service_role key used in Edge Functions — no policy needed.

-- ── 5. Index for fast "today's posts" queries ────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_menu_posts_restaurant_posted
  ON daily_menu_posts (restaurant_id, posted_at DESC);
