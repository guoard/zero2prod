-- Add status as an optional column to subscriptions
ALTER TABLE subscriptions ADD COLUMN status TEXT NULL;
