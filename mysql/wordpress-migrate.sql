SET @o = "https://bcg.xyz/portfolio";
SET @n = "https://rp.bcg.xyz/portfolio";

UPDATE wp_posts p
SET p.post_content = REPLACE(p.post_content, @o, @n)
, p.guid = REPLACE(p.guid, @o, @n);

UPDATE wp_postmeta pm
SET pm.meta_value = REPLACE(pm.meta_value, @o, @n);

UPDATE wp_options o
SET o.option_value = REPLACE(o.option_value, @o, @n);
