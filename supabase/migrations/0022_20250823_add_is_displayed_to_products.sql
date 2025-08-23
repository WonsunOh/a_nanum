-- a_nanum/supabase/migrations/20250823_add_is_displayed_to_products.sql

ALTER TABLE public.products
ADD COLUMN is_displayed BOOLEAN NOT NULL DEFAULT true;