# Netlify Preview + Supabase Direction

This is the recommended path for solo mobile use when Tailscale on Android is inconvenient.

For the general storage policy, see `storage-policy.md`.

## Target shape

```text
Android Chrome
-> Netlify branch deploy or deploy preview
-> Supabase database
```

Use Netlify production only for real release work. Keep production locked and use branch deploys or deploy previews for personal testing.

## Netlify environment variables

Set these for the Netlify site:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

The build command in `netlify.toml` writes those values into `env.js` at deploy time. Without those values, the app falls back to local JSON files and browser `localStorage`.

For local static preview, `env.js` may contain public Supabase preview settings.
With the current default `allowRemoteWrites: false`, the app can read Supabase
but direct homepage edits are still stored in that browser's localStorage. Enable
official homepage writes only after Supabase Auth and RLS policies are ready.

## Supabase setup

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL editor.
3. Generate seed SQL from the current JSON files:

```bash
node scripts/build-supabase-seed.mjs > supabase/seed.sql
```

4. Run the generated `supabase/seed.sql` in the Supabase SQL editor.

## Security note

The current schema does not grant anonymous writes. It grants public reads and
reserves schedule, event, and discussion writes for the authenticated owner
account configured in the RLS policies.
