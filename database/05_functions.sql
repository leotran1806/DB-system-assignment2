-- ============================================================================
-- 05_functions.sql | Stored functions for shipper metrics
-- MySQL 8.0.16+
-- ============================================================================
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parcel_delivery;

DROP FUNCTION IF EXISTS fn_ShipperBonus;
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

CREATE FUNCTION fn_ShipperBonus(
    p_ShipperID INT,
    p_FromDate DATE,
    p_ToDate DATE
)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_delivery_fee DECIMAL(15,2) DEFAULT 0;
    DECLARE v_commission DECIMAL(15,2) DEFAULT 0;
    DECLARE v_total_net DECIMAL(15,2) DEFAULT 0;
    DECLARE v_bonus_rate DECIMAL(4,3) DEFAULT 0;

    DECLARE earning_cursor CURSOR FOR
        SELECT DeliveryFee, PlatformCommission
        FROM SHIPPER_EARNING
        WHERE ShipperID = p_ShipperID
          AND EarningDate >= p_FromDate
          AND EarningDate < DATE_ADD(p_ToDate, INTERVAL 1 DAY);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    IF p_ShipperID IS NULL OR p_ShipperID <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipper ID must be a positive integer.';
    END IF;
    IF p_FromDate IS NULL OR p_ToDate IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Start date and end date are required.';
    END IF;
    IF p_FromDate > p_ToDate THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Start date cannot be after end date.';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM SHIPPER
    WHERE UserID = p_ShipperID;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipper does not exist.';
    END IF;

    OPEN earning_cursor;
    earning_loop: LOOP
        FETCH earning_cursor INTO v_delivery_fee, v_commission;
        IF v_done = 1 THEN
            LEAVE earning_loop;
        END IF;
        SET v_total_net = v_total_net + (v_delivery_fee - v_commission);
    END LOOP;
    CLOSE earning_cursor;

    -- Business policy: 5% from VND 5,000,000 net earnings; 10% from VND 10,000,000.
    IF v_total_net >= 100000 THEN
        SET v_bonus_rate = 0.10;
    ELSEIF v_total_net >= 50000 THEN
        SET v_bonus_rate = 0.05;
    ELSE
        SET v_bonus_rate = 0.00;
    END IF;

    RETURN ROUND(v_total_net * v_bonus_rate, 0);
END$$

DELIMITER ;
