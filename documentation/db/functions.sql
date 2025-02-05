
-- Function for showing product with category's name and image's url (one image)
CREATE OR REPLACE FUNCTION get_products_with_single_image(user_id_param INT)
RETURNS TABLE (
    productid INT,
    categoryid INT,
    category_name VARCHAR, 
    product_name VARCHAR,
    description TEXT,
    quantity INT,
    status BOOLEAN,
    userId INT,
    image_url TEXT
) AS $$ 
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (p.productid) 
        p.productid, 
        p.categoryid, 
        c.name,
        p.product_name, 
        p.description, 
        p.quantity, 
        p.status, 
        p."userId", 
        pi.url AS image_url
    FROM products p
    LEFT JOIN productimages pi ON pi.productid = p.productid
    LEFT JOIN categories c ON c.categoryid = p.categoryid  -- JOIN con la tabla category
    WHERE p."userId" = user_id_param
    ORDER BY p.productid, pi.productimageid;
END;
$$ LANGUAGE plpgsql;

-- Trigger for sum order's quantity when it insert one
    -- Function for sum it
CREATE OR REPLACE FUNCTION update_product_quantity()
RETURNS TRIGGER AS $$
BEGIN
    
    UPDATE products
    SET quantity = quantity + NEW.quantity
    WHERE productid = NEW.productid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
    -- Trigger
CREATE TRIGGER trg_after_insert_order
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity();




-- Trigger for min sale's quantity when insert one (remaining quantity (orders) and quantity (products))
    -- Function
CREATE OR REPLACE FUNCTION update_quantity_on_sale()
RETURNS TRIGGER AS $$
DECLARE
    v_productid INT;
BEGIN
    
    SELECT productid INTO v_productid
    FROM orders
    WHERE orderid = NEW.orderid;

    
    UPDATE products
    SET quantity = quantity - NEW.quantity
    WHERE productid = v_productid;

   
    UPDATE orders
    SET remaining_quantity = remaining_quantity - NEW.quantity
    WHERE orderid = NEW.orderid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

    -- Trigger
CREATE TRIGGER trg_after_insert_sale
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION update_quantity_on_sale();



-- Trigger when status is false in order (min product's quantity)
    -- Function
CREATE OR REPLACE FUNCTION update_product_quantity_on_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si el status ha cambiado a false
    IF NEW.status = false AND OLD.status = true THEN
        -- Restaurar la cantidad en la tabla products
        UPDATE products
        SET quantity = quantity - OLD.remaining_quantity
        WHERE productid = OLD.productid;
    END IF;
     IF NEW.status = true AND OLD.status = false THEN
        -- Restar la cantidad en la tabla products
        UPDATE products
        SET quantity = quantity + NEW.remaining_quantity
        WHERE productid = NEW.productid;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

    -- Trigger
CREATE or REPLACE TRIGGER trg_after_update_order_status
AFTER UPDATE ON orders
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status) -- Solo se activa si cambia el estado
EXECUTE FUNCTION update_product_quantity_on_order_status_change();





-- Trigger when status is false in sales (min product's quantity)
    -- Function
CREATE OR REPLACE FUNCTION update_quantities_on_sale_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el estado cambia a FALSE, sumar la cantidad a orders y products
    IF NEW.status = FALSE AND OLD.status = TRUE THEN
        -- Sumar la cantidad a remaining_quantity en orders
        UPDATE orders
        SET remaining_quantity = remaining_quantity + OLD.quantity
        WHERE orderid = OLD.orderid;

        -- Sumar la cantidad a quantity en products
        UPDATE products
        SET quantity = quantity + OLD.quantity
        WHERE productid = (SELECT productid FROM orders WHERE orderid = OLD.orderid);
    END IF;

    -- Si el estado cambia a TRUE, restar la cantidad a orders y products
    IF NEW.status = TRUE AND OLD.status = FALSE THEN
        -- Restar la cantidad a remaining_quantity en orders
        UPDATE orders
        SET remaining_quantity = remaining_quantity - NEW.quantity
        WHERE orderid = NEW.orderid;

        -- Restar la cantidad a quantity en products
        UPDATE products
        SET quantity = quantity - NEW.quantity
        WHERE productid = (SELECT productid FROM orders WHERE orderid = NEW.orderid);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

 -- Trigger
CREATE TRIGGER trg_after_update_sale_status
AFTER UPDATE ON sales
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status) -- Solo se activa si cambia el estado
EXECUTE FUNCTION update_quantities_on_sale_status_change();


