-- Assign 8 roles using the hybrid system (same pattern as admin.admins)
-- Execute after implementing_8_roles_hybrid.sql

SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'a@a.com'), 'admin');
SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'b@b.com'), 'organizer');
SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'c@c.com'), 'sponsor');
SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'd@d.com'), 'agency');
SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'e@e.com'), 'production');
SELECT roles.assign_role((SELECT id FROM auth.users WHERE email = 'f@f.com'), 'secretariat');
