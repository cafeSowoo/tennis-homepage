# Netlify Preview + Supabase Direction

This is the recommended path for solo mobile use when Tailscale on Android is inconvenient.

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

For local static preview, `env.js` contains the same public Supabase preview settings so `http://127.0.0.1:4173/` writes to the preview database as well. The key is a publishable browser key, not a service-role secret.

## Supabase setup

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL editor.
3. Generate seed SQL from the current JSON files:

```bash
node scripts/build-supabase-seed.mjs > supabase/seed.sql
```

4. Run the generated `supabase/seed.sql` in the Supabase SQL editor.

## Security note

The initial schema allows anon writes to schedules and discussions so the personal preview can work without login. This is acceptable only for a private preview URL used by one person.

Before sharing with club members, replace the preview write policies with authenticated admin-only policies.
