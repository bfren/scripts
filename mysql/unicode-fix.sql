UPDATE wp_posts p
SET
 p.post_content = REPLACE( p.post_content, "â€¦", "..."),
 p.post_content = REPLACE( p.post_content, "â€“", "—"),
 p.post_content = REPLACE( p.post_content, "â€”", "–"),
 p.post_content = REPLACE( p.post_content, "â€™", "'"),
 p.post_content = REPLACE( p.post_content, "â€˜", "'"),
 p.post_content = REPLACE( p.post_content, "â€ ", "†")
