// Supabase Edge Function: notify-menu-post
// Uses FCM v1 API with a service account + topic messaging.
// One request to FCM reaches all subscribed customers via the 'all_customers' topic.
//
// Secrets required (supabase secrets set KEY=value):
//   FIREBASE_SERVICE_ACCOUNT_JSON  — full service account JSON (from Firebase Console)
//   WEBHOOK_SECRET                 — shared secret verified on every DB trigger call

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

// ── JWT helper to get a Google OAuth2 access token ───────────────────────────
async function getAccessToken(serviceAccount: Record<string, string>): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const b64url = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');

  const header  = b64url({ alg: 'RS256', typ: 'JWT' });
  const payload = b64url({
    iss:   serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud:   'https://oauth2.googleapis.com/token',
    iat:   now,
    exp:   now + 3600,
  });

  const toSign = `${header}.${payload}`;

  const pemContents = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\n/g, '');

  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(toSign),
  );

  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  const jwt = `${toSign}.${sigB64}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const data = await res.json();
  return data.access_token as string;
}

// ── Main handler ─────────────────────────────────────────────────────────────
Deno.serve(async (req) => {
  const secret = req.headers.get('x-webhook-secret');
  if (secret !== Deno.env.get('WEBHOOK_SECRET')) {
    return new Response('Unauthorized', { status: 401 });
  }

  try {
    const payload = await req.json();
    const post = payload.record as {
      id: string;
      restaurant_id: string;
      meal_type: string;
      delivery_window: string | null;
    };

    // Fetch restaurant name
    const { data: restaurant } = await supabase
      .from('restaurants')
      .select('name')
      .eq('id', post.restaurant_id)
      .single();

    // Fetch item names for this post
    const { data: postItems } = await supabase
      .from('daily_menu_post_items')
      .select('menu_items(name)')
      .eq('post_id', post.id);

    const itemNames = (postItems ?? [])
      .map((pi: any) => pi.menu_items?.name)
      .filter(Boolean)
      .join(', ');

    const mealLabel = post.meal_type.charAt(0).toUpperCase() + post.meal_type.slice(1);
    const title = `${restaurant?.name ?? 'Restaurant'} — ${mealLabel} Menu`;
    const body  = itemNames
      ? `${itemNames}${post.delivery_window ? ' · ' + post.delivery_window : ''}`
      : post.delivery_window ?? 'Menu posted. Tap to view.';

    // Get service account and access token
    const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')!);
    const accessToken     = await getAccessToken(serviceAccount);

    // Send one FCM v1 topic message — reaches all subscribed customers instantly
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method:  'POST',
        headers: {
          'Content-Type':  'application/json',
          Authorization:   `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            topic:        'all_customers',
            notification: { title, body },
            data: {
              type:          'menu_post',
              post_id:       post.id,
              restaurant_id: post.restaurant_id,
              meal_type:     post.meal_type,
            },
            android: { priority: 'high' },
            apns:    { headers: { 'apns-priority': '10' } },
          },
        }),
      },
    );

    const result = await fcmRes.json();
    return new Response(JSON.stringify(result), { status: fcmRes.status });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
