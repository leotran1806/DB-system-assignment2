-- ============================================================================
-- 05_functions.sql | A2 - Section 2.4 (1 point)
-- STARTER FILE: implement two MySQL stored functions.
-- Both functions must use input parameters, input validation, queries, cursors,
-- and IF and/or LOOP statements. Demo them using SELECT function_name(...).
-- ============================================================================
USE parcel_delivery;

-- TODO function 1: fn_ShipperReputation(p_ShipperID INT)
-- Suggested return type: DECIMAL(3,2).
-- Required implementation steps:
-- 1. Validate p_ShipperID is not NULL and is a positive integer.
-- 2. Query SHIPPER to confirm the ID exists; SIGNAL a meaningful message if not.
-- 3. Declare a cursor selecting Rating from FEEDBACK for this ShipperID where
--    FeedbackType='customer'. Do NOT include feedback written by the shipper.
-- 4. Declare a NOT FOUND handler to stop cursor iteration.
-- 5. OPEN the cursor; FETCH ratings inside a LOOP; use IF to exit when done;
--    accumulate rating total and count.
-- 6. CLOSE the cursor. Return 0.00 when there are no ratings, otherwise return
--    the rounded average.
-- 7. Add a test SELECT calling this function for a shipper with and without ratings.

-- TODO function 2: fn_ShipperBonus(p_ShipperID INT, p_FromDate DATE, p_ToDate DATE)
-- Suggested return type: DECIMAL(12,2).
-- Required implementation steps:
-- 1. Validate positive ShipperID; both dates are present; FromDate <= ToDate.
-- 2. Query SHIPPER to confirm the ID exists.
-- 3. Declare a cursor that selects the shipper's SHIPPER_EARNING rows in the
--    requested period. Select DeliveryFee and PlatformCommission (or a justified
--    NetEarning column if your schema stores it).
-- 4. OPEN cursor; FETCH each earning; accumulate DeliveryFee - Commission.
--    Use LOOP and an IF condition plus a NOT FOUND handler.
-- 5. CLOSE cursor; use IF / ELSEIF / ELSE to select the bonus rate.
-- 6. Thresholds and rates are NOT specified by A1. Agree on values as a team,
--    document the assumption in the report, and use the same values in sample data.
-- 7. Return the calculated bonus and add SELECT tests for lower/middle/upper tiers.
DELIMITER $$
CREATE FUNCTION fn_ShipperBonus(shipperID INT, fromDate DATE, toDate DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE exist INT DEFAULT 1;
    DECLARE fee DECIMAL(12,2);
    DECLARE commission DECIMAL (12,2);
    DECLARE net DECIMAL(12,2) DEFAULT 0;
    DECLARE rate DECIMAL(2,1) DEFAULT 0;
    DECLARE shipperCursor CURSOR FOR
        SELECT DeliveryFee, PlatformCommission FROM SHIPPER_EARNING
        WHERE ShipperID = shipperID
        AND EarningDate >= fromDate
        AND EarningDate < DATE_ADD(toDate, INTERVAL 1 DAY);
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = 1;
    
    IF shipperID IS NULL OR shipperID < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This field cannot be empty';
    END IF;
    IF fromDate IS NULL OR toDate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This field cannot be empty';
    END IF;
    IF fromDate > toDate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'From date cannot be after to date';
    END IF;
    
    SELECT COUNT(*) INTO exist FROM SHIPPER WHERE UserID = shipperID;
    IF exist = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot find the corresponding shipper';
    END IF;

    OPEN shipperCursor;
    earn_loop: LOOP
        FETCH shipperCursor INTO fee, commission;
        IF done = 1 THEN
            LEAVE earn_loop;
        END IF;
        SET net = net + (fee - commission);
    END LOOP;
    CLOSE shipperCursor;

    IF net >= POWER(10, 7) THEN
        SET rate = 0.1;
    ELSEIF net >= 5 * POWER(10, 6) THEN
        SET rate = 0.05;
    ELSE
        SET rate = 0;
    END IF;
    RETURN ROUND(net * rate, 0);
END$$
DELIMITER ;
-- Template skeleton (uncomment and complete):
-- DELIMITER $$
-- CREATE FUNCTION fn_ShipperReputation(p_ShipperID INT)
-- RETURNS DECIMAL(3,2)
-- READS SQL DATA
-- BEGIN
--     DECLARE v_done INT DEFAULT 0;
--     DECLARE v_rating INT;
--     DECLARE v_total INT DEFAULT 0;
--     DECLARE v_count INT DEFAULT 0;
--     DECLARE rating_cursor CURSOR FOR
--         SELECT Rating FROM FEEDBACK
--          WHERE ShipperID = p_ShipperID AND FeedbackType = 'customer';
--     DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
--     -- TODO: validate input and existence before OPEN.
--     -- TODO: OPEN cursor; LOOP/FETCH; IF v_done=1 THEN LEAVE; END IF;
--     -- TODO: accumulate; CLOSE cursor; handle zero ratings; RETURN average.
-- END$$
--
-- CREATE FUNCTION fn_ShipperBonus(
--     p_ShipperID INT, p_FromDate DATE, p_ToDate DATE
-- ) RETURNS DECIMAL(12,2)
-- READS SQL DATA
-- BEGIN
--     DECLARE v_done INT DEFAULT 0;
--     DECLARE v_delivery_fee DECIMAL(12,2);
--     DECLARE v_commission DECIMAL(12,2);
--     DECLARE v_total_net DECIMAL(14,2) DEFAULT 0;
--     DECLARE earning_cursor CURSOR FOR
--         SELECT DeliveryFee, PlatformCommission FROM SHIPPER_EARNING
--          WHERE ShipperID=p_ShipperID
--            AND EarningDate >= p_FromDate
--            AND EarningDate < DATE_ADD(p_ToDate, INTERVAL 1 DAY);
--     DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
--     -- TODO: validate parameters and shipper existence.
--     -- TODO: OPEN; LOOP/FETCH; IF done LEAVE; accumulate fee - commission.
--     -- TODO: CLOSE; IF/ELSEIF selects agreed rate; RETURN bonus.
-- END$$
-- DELIMITER ;

DROP FUNCTION IF EXISTS fn_ShipperReputation;

DELIMITER $$
CREATE FUNCTION fn_ShipperReputation(p_ShipperID INT)
RETURNS DECIMAL(3,2)
READS SQL DATA
BEGIN
    DECLARE v_done     INT           DEFAULT 0;
    DECLARE v_exists   INT           DEFAULT 0;
    DECLARE v_rating   INT;
    DECLARE v_created  DATETIME;
    DECLARE v_latest   DATE          DEFAULT NULL;
    DECLARE v_weight   INT           DEFAULT 1;
    DECLARE v_sum      DECIMAL(14,2) DEFAULT 0;
    DECLARE v_weights  INT           DEFAULT 0;

    DECLARE rating_cursor CURSOR FOR
        SELECT Rating, CreatedDate
          FROM FEEDBACK
         WHERE ShipperID = p_ShipperID
           AND FeedbackType = 'customer';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- 1) Validate input
    IF p_ShipperID IS NULL OR p_ShipperID <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ShipperID must be a positive integer.';
    END IF;

    -- 2) Shipper phải tồn tại (COUNT(*) luôn trả về 1 dòng -> không kích hoạt NOT FOUND)
    SELECT COUNT(*) INTO v_exists FROM SHIPPER WHERE UserID = p_ShipperID;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipper does not exist.';
    END IF;

    -- 3) Mốc thời gian để xác định "đánh giá gần đây"
    SELECT MAX(DATE(CreatedDate)) INTO v_latest
      FROM FEEDBACK
     WHERE ShipperID = p_ShipperID
       AND FeedbackType = 'customer';

    -- 4) Duyệt từng đánh giá, cộng dồn theo trọng số
    OPEN rating_cursor;
    read_loop: LOOP
        FETCH rating_cursor INTO v_rating, v_created;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        IF DATEDIFF(v_latest, DATE(v_created)) <= 30 THEN
            SET v_weight = 2;
        ELSE
            SET v_weight = 1;
        END IF;

        SET v_sum     = v_sum + (v_rating * v_weight);
        SET v_weights = v_weights + v_weight;
    END LOOP;
    CLOSE rating_cursor;

    -- 5) Chưa có đánh giá -> 0.00
    IF v_weights = 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND(v_sum / v_weights, 2);
END$$
DELIMITER ;
