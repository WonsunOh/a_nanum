-- supabase/migrations/0042_create_promotions_table.sql

CREATE TABLE public.promotions (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    title TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    banner_image_url TEXT
);

ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to everyone"
ON public.promotions FOR SELECT USING (true);

CREATE POLICY "Allow full access to admin"
ON public.promotions FOR ALL
USING (auth.jwt() ->> 'user_role' = 'admin')
WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');