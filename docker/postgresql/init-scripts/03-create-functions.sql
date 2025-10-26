-- 03-create-functions.sql
-- Create stored procedures and functions

-- Function to update user's updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at 
    BEFORE UPDATE ON posts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Function to get user statistics
CREATE OR REPLACE FUNCTION get_user_stats(user_id_param INTEGER)
RETURNS TABLE(
    total_posts INTEGER,
    published_posts INTEGER,
    total_categories INTEGER,
    last_post_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(p.id)::INTEGER as total_posts,
        COUNT(CASE WHEN p.is_published THEN 1 END)::INTEGER as published_posts,
        COUNT(DISTINCT pc.category_id)::INTEGER as total_categories,
        MAX(p.created_at) as last_post_date
    FROM posts p
    LEFT JOIN post_categories pc ON p.id = pc.post_id
    WHERE p.user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to clean expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions 
    WHERE expires_at < CURRENT_TIMESTAMP;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get popular categories
CREATE OR REPLACE FUNCTION get_popular_categories(limit_param INTEGER DEFAULT 10)
RETURNS TABLE(
    category_id INTEGER,
    category_name VARCHAR(100),
    post_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        COUNT(pc.post_id) as post_count
    FROM categories c
    LEFT JOIN post_categories pc ON c.id = pc.category_id
    LEFT JOIN posts p ON pc.post_id = p.id AND p.is_published = TRUE
    GROUP BY c.id, c.name
    ORDER BY post_count DESC
    LIMIT limit_param;
END;
$$ LANGUAGE plpgsql;

-- Function for full-text search across posts
CREATE OR REPLACE FUNCTION search_posts(search_term TEXT)
RETURNS TABLE(
    id INTEGER,
    title VARCHAR(200),
    content TEXT,
    username VARCHAR(80),
    created_at TIMESTAMP,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.content,
        u.username,
        p.created_at,
        ts_rank(to_tsvector('english', p.title || ' ' || COALESCE(p.content, '')), 
                plainto_tsquery('english', search_term)) as rank
    FROM posts p
    JOIN users u ON p.user_id = u.id
    WHERE p.is_published = TRUE
    AND to_tsvector('english', p.title || ' ' || COALESCE(p.content, '')) 
        @@ plainto_tsquery('english', search_term)
    ORDER BY rank DESC, p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get monthly post statistics
CREATE OR REPLACE FUNCTION get_monthly_post_stats(year_param INTEGER)
RETURNS TABLE(
    month INTEGER,
    month_name TEXT,
    post_count BIGINT,
    unique_authors BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXTRACT(MONTH FROM p.created_at)::INTEGER as month,
        TO_CHAR(p.created_at, 'Month') as month_name,
        COUNT(p.id) as post_count,
        COUNT(DISTINCT p.user_id) as unique_authors
    FROM posts p
    WHERE EXTRACT(YEAR FROM p.created_at) = year_param
    AND p.is_published = TRUE
    GROUP BY EXTRACT(MONTH FROM p.created_at), TO_CHAR(p.created_at, 'Month')
    ORDER BY month;
END;
$$ LANGUAGE plpgsql;

-- Log functions creation
DO $$
BEGIN
    RAISE NOTICE 'Database functions and triggers created successfully';
END $$;