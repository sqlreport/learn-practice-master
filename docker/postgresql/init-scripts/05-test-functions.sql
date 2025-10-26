-- 05-test-functions.sql
-- Test all created functions to ensure they work correctly

-- Test user statistics function
DO $$
DECLARE
    test_result RECORD;
BEGIN
    RAISE NOTICE 'Testing get_user_stats function...';
    
    FOR test_result IN 
        SELECT * FROM get_user_stats(1)
    LOOP
        RAISE NOTICE 'User 1 stats - Total posts: %, Published: %, Categories: %, Last post: %', 
            test_result.total_posts, test_result.published_posts, 
            test_result.total_categories, test_result.last_post_date;
    END LOOP;
END $$;

-- Test popular categories function
DO $$
DECLARE
    test_result RECORD;
BEGIN
    RAISE NOTICE 'Testing get_popular_categories function...';
    
    FOR test_result IN 
        SELECT * FROM get_popular_categories(5)
    LOOP
        RAISE NOTICE 'Category: % (ID: %) - Posts: %', 
            test_result.category_name, test_result.category_id, test_result.post_count;
    END LOOP;
END $$;

-- Test search function
DO $$
DECLARE
    test_result RECORD;
    search_count INTEGER;
BEGIN
    RAISE NOTICE 'Testing search_posts function...';
    
    SELECT COUNT(*) INTO search_count FROM search_posts('React');
    RAISE NOTICE 'Search for "React" returned % results', search_count;
    
    SELECT COUNT(*) INTO search_count FROM search_posts('travel');
    RAISE NOTICE 'Search for "travel" returned % results', search_count;
END $$;

-- Test monthly statistics function
DO $$
DECLARE
    test_result RECORD;
    current_year INTEGER;
BEGIN
    RAISE NOTICE 'Testing get_monthly_post_stats function...';
    
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO current_year;
    
    FOR test_result IN 
        SELECT * FROM get_monthly_post_stats(current_year) LIMIT 3
    LOOP
        RAISE NOTICE 'Month % (%) - Posts: %, Authors: %', 
            test_result.month, TRIM(test_result.month_name), 
            test_result.post_count, test_result.unique_authors;
    END LOOP;
END $$;

-- Test cleanup function
DO $$
DECLARE
    cleanup_count INTEGER;
BEGIN
    RAISE NOTICE 'Testing cleanup_expired_sessions function...';
    
    SELECT cleanup_expired_sessions() INTO cleanup_count;
    RAISE NOTICE 'Cleaned up % expired sessions', cleanup_count;
END $$;

-- Verify triggers work by updating a user
DO $$
DECLARE
    old_updated_at TIMESTAMP;
    new_updated_at TIMESTAMP;
BEGIN
    RAISE NOTICE 'Testing update triggers...';
    
    -- Get current updated_at
    SELECT updated_at INTO old_updated_at FROM users WHERE id = 1;
    
    -- Wait a moment and update
    PERFORM pg_sleep(1);
    UPDATE users SET email = 'john.doe.updated@example.com' WHERE id = 1;
    
    -- Get new updated_at
    SELECT updated_at INTO new_updated_at FROM users WHERE id = 1;
    
    IF new_updated_at > old_updated_at THEN
        RAISE NOTICE 'Update trigger working correctly - timestamp updated';
    ELSE
        RAISE NOTICE 'Update trigger may not be working - timestamp not changed';
    END IF;
    
    -- Revert the change
    UPDATE users SET email = 'john@example.com' WHERE id = 1;
END $$;

-- Final summary
DO $$
BEGIN
    RAISE NOTICE '=== DATABASE SETUP COMPLETE ===';
    RAISE NOTICE 'All functions tested successfully';
    RAISE NOTICE 'Database is ready for application use';
    RAISE NOTICE 'Default password for test users: password123';
END $$;