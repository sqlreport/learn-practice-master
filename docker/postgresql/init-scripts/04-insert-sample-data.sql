-- 04-insert-sample-data.sql
-- Insert sample data for testing and development

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Technology', 'Posts about technology and programming'),
('Lifestyle', 'Posts about lifestyle and personal experiences'),
('Travel', 'Posts about travel and destinations'),
('Food', 'Posts about food and recipes'),
('Health', 'Posts about health and wellness'),
('Business', 'Posts about business and entrepreneurship'),
('Education', 'Posts about education and learning'),
('Entertainment', 'Posts about entertainment and media');

-- Insert sample users (passwords should be hashed in real application)
-- For development, these are example bcrypt hashes for 'password123'
INSERT INTO users (username, email, password_hash) VALUES
('john_doe', 'john@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewohOOiOYVFJl/0m'),
('jane_smith', 'jane@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewohOOiOYVFJl/0m'),
('admin_user', 'admin@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewohOOiOYVFJl/0m'),
('developer', 'dev@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewohOOiOYVFJl/0m'),
('blogger', 'blogger@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewohOOiOYVFJl/0m');

-- Insert sample posts
INSERT INTO posts (title, content, user_id, is_published) VALUES
('Getting Started with React TypeScript', 'This is a comprehensive guide to React with TypeScript. React TypeScript combines the power of React with the type safety of TypeScript, making your applications more robust and maintainable.', 1, TRUE),
('My Travel Experience in Japan', 'Last month I visited Japan and had an amazing experience. From the bustling streets of Tokyo to the serene temples of Kyoto, Japan offers a perfect blend of modern technology and traditional culture.', 2, TRUE),
('Healthy Cooking Tips for Busy Professionals', 'Here are some practical tips for healthy cooking when you have a busy schedule. Meal prep, quick recipes, and smart shopping can help you maintain a healthy diet.', 2, TRUE),
('Advanced PostgreSQL Techniques', 'This post covers advanced PostgreSQL features including stored procedures, triggers, and performance optimization techniques for large-scale applications.', 1, FALSE),
('Building Scalable Web Applications', 'Learn how to build web applications that can handle millions of users. This guide covers architecture patterns, caching strategies, and database optimization.', 4, TRUE),
('The Future of Remote Work', 'Remote work has transformed how we think about employment. This article explores the benefits, challenges, and future trends in remote work culture.', 3, TRUE),
('Introduction to Machine Learning', 'Machine learning is revolutionizing various industries. This beginner-friendly guide introduces key concepts and practical applications.', 4, TRUE),
('Travel Photography Tips', 'Capture stunning photos during your travels with these professional photography tips and techniques for different environments and lighting conditions.', 5, TRUE),
('Sustainable Business Practices', 'How modern businesses can adopt sustainable practices while maintaining profitability. A guide to green business strategies.', 3, TRUE),
('Home Workout Routines', 'Stay fit without a gym membership. These effective home workout routines require minimal equipment and can be done in small spaces.', 5, FALSE);

-- Link posts to categories
INSERT INTO post_categories (post_id, category_id) VALUES
(1, 1), -- React post -> Technology
(2, 3), -- Japan travel -> Travel
(3, 4), -- Cooking tips -> Food
(3, 5), -- Cooking tips -> Health
(4, 1), -- PostgreSQL -> Technology
(5, 1), -- Scalable apps -> Technology
(5, 6), -- Scalable apps -> Business
(6, 6), -- Remote work -> Business
(6, 2), -- Remote work -> Lifestyle
(7, 1), -- Machine learning -> Technology
(7, 7), -- Machine learning -> Education
(8, 3), -- Photography -> Travel
(8, 8), -- Photography -> Entertainment
(9, 6), -- Sustainable business -> Business
(10, 5), -- Home workout -> Health
(10, 2); -- Home workout -> Lifestyle

-- Insert some sample user sessions (for testing session cleanup)
INSERT INTO user_sessions (user_id, session_token, expires_at) VALUES
(1, 'session_token_1_active', CURRENT_TIMESTAMP + INTERVAL '1 hour'),
(2, 'session_token_2_active', CURRENT_TIMESTAMP + INTERVAL '2 hours'),
(3, 'session_token_3_expired', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
(1, 'session_token_1_expired', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(4, 'session_token_4_active', CURRENT_TIMESTAMP + INTERVAL '30 minutes');

-- Log sample data insertion
DO $$
BEGIN
    RAISE NOTICE 'Sample data inserted successfully';
    RAISE NOTICE 'Users: % records', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Categories: % records', (SELECT COUNT(*) FROM categories);
    RAISE NOTICE 'Posts: % records', (SELECT COUNT(*) FROM posts);
    RAISE NOTICE 'Post-Category links: % records', (SELECT COUNT(*) FROM post_categories);
    RAISE NOTICE 'User sessions: % records', (SELECT COUNT(*) FROM user_sessions);
END $$;