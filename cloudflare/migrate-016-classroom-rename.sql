-- 教室命名：小教室N → N号小教室；大教室N → N号大教室
UPDATE classroom SET name = CAST(SUBSTR(name, 4, LENGTH(name) - 3) AS INTEGER) || '号小教室' WHERE size = 'SMALL' AND name LIKE '小教室%';
UPDATE classroom SET name = CAST(SUBSTR(name, 4, LENGTH(name) - 3) AS INTEGER) || '号大教室' WHERE size = 'LARGE' AND name LIKE '大教室%';
