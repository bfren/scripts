SET @o = ""; -- URL to search for
SET @n = ""; -- URL to replace with

UPDATE wp_posts p
SET p.post_content = REPLACE(p.post_content, @o, @n);

UPDATE wp_postmeta pm
SET pm.meta_value = REPLACE(pm.meta_value, @o, @n);

UPDATE wp_options o
SET o.option_value = REPLACE(o.option_value, @o, @n);
