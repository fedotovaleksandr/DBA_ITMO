CREATE FUNCTION add_category(category_name CHARACTER VARYING)
  RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE NOTICE 'Adding Category.';
  IF EXISTS(SELECT 1
            FROM category
            WHERE name = category_name OR UPPER(name) = UPPER(category_name))
  THEN
    RAISE NOTICE 'Category exist.';
    RETURN 0;
  END IF;
  INSERT INTO category (name) VALUES (category_name);
  RAISE NOTICE 'Category added.';
  RETURN 1;
END;
$$;

