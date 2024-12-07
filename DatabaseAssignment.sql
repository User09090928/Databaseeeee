DROP DATABASE IF EXISTS cullinary_studio;
CREATE DATABASE cullinary_studio;
USE cullinary_studio;

CREATE TABLE client (
    client_id VARCHAR(8) NOT NULL,
    client_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),       
    email VARCHAR(50),
    birthdate DATE,
    PRIMARY KEY (client_id)
);
              
CREATE TABLE client_feedback (
    feedback_id VARCHAR(8) NOT NULL,
    client_id VARCHAR(8),
    rating INT NOT NULL,
    review VARCHAR(1000),
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id) 
);

CREATE TABLE chef (
	chef_id VARCHAR(8) NOT NULL,
    name VARCHAR(100) NOT NULL, 
    phone_number VARCHAR(15),
    email VARCHAR(50),
    specialization VARCHAR(50),
    PRIMARY KEY (chef_id)
);
    
CREATE TABLE certification (
    cert_id INT NOT NULL AUTO_INCREMENT, 
    chef_id VARCHAR(8) NOT NULL, 
    cert_name VARCHAR(100) NOT NULL, 
    cert_date DATE, 
    PRIMARY KEY (cert_id),
    UNIQUE (chef_id, cert_name), 
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id)
);

CREATE TABLE class (
	class_id VARCHAR(8) NOT NULL,
	name VARCHAR(100),
	date DATE,
	start_time TIME,
	end_time TIME,
    revenue INT,
	class_type VARCHAR(30) CHECK (class_type IN ('seminar','workshop','private_session' )),
    chef_id VARCHAR(8),
    PRIMARY KEY (class_id),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id));
    
CREATE TABLE attendance (
    attendance_id VARCHAR(8) NOT NULL,
    class_id VARCHAR(8) NOT NULL,
    class_type VARCHAR(20) NOT NULL,
    client_id VARCHAR(8)NOT NULL,
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id)
);

DELIMITER $$

CREATE TRIGGER validate_class_type
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM class
        WHERE class_id = NEW.class_id AND class_type = NEW.class_type
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Class type does not match the class ID.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validate_private_session
BEFORE INSERT ON class
FOR EACH ROW
BEGIN
    IF NEW.class_type = 'private_session' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM certification
            WHERE chef_id = NEW.chef_id AND cert_id IS NOT NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only chefs with a certification can teach private sessions';
        END IF;
    END IF;
END$$

DELIMITER ;

CREATE TABLE seminar (
    class_id VARCHAR(8) NOT NULL, 
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    activity_type VARCHAR(100) 
    CHECK (activity_type IN 
    ('cooking demonstrations', 'ingredient testing', 'recipes analysis', 'culinary education',
    'skills', 'food presentation', 'sustainability in cooking', 'health and nutrition talk', 
    'flavour pairing talk'))
);

CREATE TABLE workshop (
	class_id VARCHAR(8) NOT NULL,
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id) ,
    workshop_type VARCHAR(100) CHECK 
    (workshop_type IN ('baking', 'italian cuisine', 'sushi making', 'indian cuisine', 'chinese cuisine', 'malay cuisine')),
    difficulty_level VARCHAR(10) CHECK 
    (difficulty_level IN ('easy','medium','hard'))
);
    
CREATE TABLE private_session (
	class_id VARCHAR(8) NOT NULL,
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id) ,
    client_special_request VARCHAR(100)
);


CREATE TABLE advertainment (
	adv_id VARCHAR(8) NOT NULL,
    adv_type VARCHAR (50),
    platform VARCHAR(50),
	PRIMARY KEY (adv_id)
);
    
CREATE TABLE promote(
	class_id VARCHAR(8) NOT NULL,
    adv_id VARCHAR(8) NOT NULL,
    FOREIGN KEY (class_id) REFERENCES seminar(class_id),
    FOREIGN KEY (adv_id) REFERENCES advertainment(adv_id)
);
	
CREATE TABLE equipment (
	equipment_id VARCHAR(8) NOT NULL,
    equipment_name VARCHAR(50),
    quantity INT NOT NULL,
    PRIMARY KEY (equipment_id));
    
CREATE TABLE renting (
	renting_id VARCHAR(8) NOT NULL,
	start_date DATE,
    end_date DATE,
    client_id VARCHAR(8) NOT NULL,
    equipment_id VARCHAR(8) NOT NULL,
    PRIMARY KEY (renting_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);
    
CREATE TABLE membership(
	member_id VARCHAR(8) NOT NULL,
    client_id VARCHAR(8) NOT NULL,
    exclusive_chef VARCHAR(3) CHECK (exclusive_chef IN ('yes','no')) NOT NULL,
    membership_type VARCHAR(50),
    PRIMARY KEY (member_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id)
);
    
CREATE TABLE chef_meet_n_greet (
	cmg_id VARCHAR(8) NOT NULL,
    chef_id VARCHAR(8) NOT NULL,
    date DATE,
    start_time TIME,
    end_time TIME,
    PRIMARY KEY (cmg_id),
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id)
);
    
CREATE TABLE cmg_participants(
	cmg_id VARCHAR(8) NOT NULL,
    participant_id VARCHAR(8) NOT NULL, 
	PRIMARY KEY (cmg_id , participant_id),
    FOREIGN KEY (participant_id) REFERENCES membership(member_id),
    FOREIGN KEY (cmg_id) REFERENCES chef_meet_n_greet (cmg_id)
);

DELIMITER $$

CREATE TRIGGER validate_exclusive_chef_participation
BEFORE INSERT ON cmg_participants
FOR EACH ROW
BEGIN
    -- Check if the participant is eligible to participate (i.e., has 'yes' under exclusive_chef)
    IF NOT EXISTS (
        SELECT 1
        FROM membership
        WHERE member_id = NEW.participant_id AND exclusive_chef = 'yes'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only members with exclusive_chef = ''yes'' can participate in Chef Meet and Greet';
    END IF;
END$$

DELIMITER ;

CREATE TABLE group_membership (
	group_id VARCHAR(8) NOT NULL,
    holder_id VARCHAR(8) NOT NULL,
    no_of_pax INT,
    PRIMARY KEY (group_id),
    FOREIGN KEY (holder_id) REFERENCES membership(member_id)
);
    
CREATE TABLE group_info (
	group_id VARCHAR(8),
    client_id VARCHAR(8),
    PRIMARY KEY (group_id, client_id),
    FOREIGN KEY (group_id) REFERENCES group_membership(group_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id)
);

CREATE TABLE challenge (
	challenge_id VARCHAR(8) NOT NULL,
    challenge_name VARCHAR(100),
    PRIMARY KEY (challenge_id)
);
     
CREATE TABLE badge (
	badges_id VARCHAR(8) NOT NULL,
    member_id VARCHAR(8) NOT NULL, 
    challenge_id VARCHAR(8) NOT NULL,
    PRIMARY KEY (badges_id),
    FOREIGN KEY (member_id) REFERENCES membership(member_id),
    FOREIGN KEY (challenge_id) REFERENCES challenge(challenge_id));

-- newwww:
CREATE TABLE brand (
	brand_id VARCHAR(8) NOT NULL,
	brand_type ENUM('Gourmet Gurus', 'Master Chef Club') NOT NULL,
    PRIMARY KEY(brand_id)
);

CREATE TABLE b_benefits (
	benefit_id VARCHAR(8) NOT NULL,
    brand_id VARCHAR(8) NOT NULL,
    details VARCHAR(100),
    PRIMARY KEY (benefit_id),
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id) ON DELETE CASCADE
);

CREATE TABLE client_brand(
	client_id VARCHAR(8) NOT NULL,
    brand_id VARCHAR(8) NOT NULL,
    PRIMARY KEY (client_id, brand_id),
    FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE,
    FOREIGN KEY(brand_id) REFERENCES brand(brand_id) ON DELETE CASCADE
);

CREATE TABLE bday_redeem(
	redemption_id INT NOT NULL AUTO_INCREMENT,
    member_id VARCHAR(8) NOT NULL,
	status ENUM('redeemed', 'unclaimed'),
    gift VARCHAR(50),
    redeem_date DATE,
    PRIMARY KEY (redemption_id),
    FOREIGN KEY(member_id) REFERENCES membership(member_id) ON DELETE CASCADE
);

CREATE TABLE merchandise (
    merch_id VARCHAR(8) NOT NULL,
    merch_name VARCHAR(100),
    price DECIMAL(8,2),
    category VARCHAR(100),
    PRIMARY KEY (merch_id)
);

CREATE TABLE merch_purchase (
    purchase_id VARCHAR(8) NOT NULL,
    client_id VARCHAR(8) ,
    merch_id VARCHAR(8),
    date DATE,
    quantity INT,
    total_price DECIMAL(8,2),
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE,
    FOREIGN KEY (merch_id) REFERENCES merchandise(merch_id) ON DELETE CASCADE
);

INSERT INTO client VALUES 
('C001', 'Ahmad Ali', '012-345-6789', 'ahmad.ali@example.com', '1990-01-01'),
('C002', 'Siti Aisyah', '013-456-7890', 'siti.aisyah@example.com', '1985-02-02'),
('C003', 'Lim Wei', '014-567-8901', 'lim.wei@example.com', '1992-03-03'),
('C004', 'Mohd Amin', '015-678-9012', 'mohd.amin@example.com', '1988-04-04'),
('C005', 'Nurul Hassan', '016-789-0123', 'nurul.hassan@example.com', '1995-05-05'),
('C006', 'Tan Cheng', '017-890-1234', 'tan.cheng@example.com', '1991-06-06'),
('C007', 'Adam Lee', '018-901-2345', 'adam.lee@example.com', '1987-07-07'),
('C008', 'Farah Zain', '019-012-3456', 'farah.zain@example.com', '1993-08-08'),
('C009', 'Ahmad George', '012-123-4567', 'ahmad.george@example.com', '1986-09-09'),
('C010', 'Hana Idris', '013-234-5678', 'hana.idris@example.com', '1994-10-10'),
('C011', 'Ismail Rahman', '014-345-6789', 'ismail.rahman@example.com', '1989-11-11'),
('C012', 'Julia Wong', '015-456-7890', 'julia.wong@example.com', '1990-12-12'),
('C013', 'Kevin Lim', '016-567-8901', 'kevin.lim@example.com', '1985-01-13'),
('C014', 'Lee Min', '017-678-9012', 'lee.min@example.com', '1992-02-14'),
('C015', 'Mike Ng', '018-789-0123', 'mike.ng@example.com', '1988-03-15'),
('C016', 'Nina Tan', '019-890-1234', 'nina.tan@example.com', '1991-04-16'),
('C017', 'Oscar Yusof', '012-901-2345', 'oscar.yusof@example.com', '1987-05-17'),
('C018', 'Paula Rahimi', '013-012-3456', 'paula.rahimi@example.com', '1993-06-18'),
('C019', 'Quentin Sharif', '014-123-4567', 'quentin.sharif@example.com', '1986-07-19'),
('C020', 'Rashid Sam', '015-234-5678', 'rashid.sam@example.com', '1994-08-20'),
('C021', 'Steve Lim', '016-345-6789', 'steve.lim@example.com', '1989-09-21'),
('C022', 'Tina Kumar', '017-456-7890', 'tina.kumar@example.com', '1990-10-22'),
('C023', 'Umar Vance', '018-567-8901', 'umar.vance@example.com', '1985-11-23'),
('C024', 'Victor Tan', '019-678-9012', 'victor.tan@example.com', '1992-12-24'),
('C025', 'Wendy Soh', '012-789-0123', 'wendy.soh@example.com', '1988-01-25'),
('C026', 'Xavier Lim', '013-890-1234', 'xavier.lim@example.com', '1991-02-26'),
('C027', 'Yusof Zain', '014-901-2345', 'yusof.zain@example.com', '1987-03-27'),
('C028', 'Zach Tan', '015-012-3456', 'zach.tan@example.com', '1993-04-28'),
('C029', 'Amy Lee', '016-123-4567', 'amy.lee@example.com', '1986-05-29'),
('C030', 'Brian Ng', '017-234-5678', 'brian.ng@example.com', '1994-06-30'),
('C031', 'Cathy Wong', '018-345-6789', 'cathy.wong@example.com', '1989-07-31'),
('C032', 'Daniel Khoo', '019-456-7890', 'daniel.khoo@example.com', '1990-08-01'),
('C033', 'Eva Tan', '012-567-8901', 'eva.tan@example.com', '1985-09-02'),
('C034', 'Frank Yusri', '013-678-9012', 'frank.yusri@example.com', '1992-10-03'),
('C035', 'Grace Lim', '014-789-0123', 'grace.lim@example.com', '1988-11-04'),
('C036', 'Henry Lee', '015-890-1234', 'henry.lee@example.com', '1991-12-05'),
('C037', 'Isla Tan', '016-901-2345', 'isla.tan@example.com', '1987-01-06'),
('C038', 'Jack Wong', '017-012-3456', 'jack.wong@example.com', '1993-02-07'),
('C039', 'Kathy Rahman', '018-123-4567', 'kathy.rahman@example.com', '1986-03-08'),
('C040', 'Liam Mok', '019-234-5678', 'liam.mok@example.com', '1994-04-09'),
('C041', 'Mia Yap', '012-345-6789', 'mia.yap@example.com', '1989-05-10'),
('C042', 'Noah Aziz', '013-456-7890', 'noah.aziz@example.com', '1990-06-11'),
('C043', 'Olivia Tan', '014-567-8901', 'olivia.tan@example.com', '1985-07-12'),
('C044', 'Paul Rahimi', '015-678-9012', 'paul.rahimi@example.com', '1992-08-13'),
('C045', 'Quincy Yong', '016-789-0123', 'quincy.yong@example.com', '1988-09-14'),
('C046', 'Rita Soh', '017-890-1234', 'rita.soh@example.com', '1991-10-15'),
('C047', 'Sam Lim', '018-901-2345', 'sam.lim@example.com', '1987-11-16'),
('C048', 'Tina Lee', '019-012-3456', 'tina.lee@example.com', '1993-12-17'),
('C049', 'Ulysses Tan', '012-123-4567', 'ulysses.tan@example.com', '1986-01-18'),
('C050', 'Vera Lim', '013-234-5678', 'vera.lim@example.com', '1994-02-19'),
('C051', 'Ahmad Zulkifli', '012-345-6784', 'ahmad.zulkifli@example.com', '1995-03-04'),
('C052', 'Siti Aisyah', '013-456-7895', 'siti.aisyah@example.com', '1994-04-05'),
('C053', 'Lim Wei Jie', '014-567-8906', 'lim.wei.jie@example.com', '1992-05-06'),
('C054', 'Nurul Huda', '015-678-9017', 'nurul.huda@example.com', '1989-06-07'),
('C055', 'Mohd Faris', '016-789-0128', 'mohd.faris@example.com', '1991-07-08'),
('C056', 'Leong Ming', '017-890-1239', 'leong.ming@example.com', '1993-08-09'),
('C057', 'Priya Kumar', '018-901-2340', 'priya.kumar@example.com', '1987-09-10'),
('C058', 'Zainab Rahman', '019-012-3451', 'zainab.rahman@example.com', '1990-10-11'),
('C059', 'Chong Wei Lun', '016-123-4562', 'chong.weilun@example.com', '1985-11-12'),
('C060', 'Hassan Ali', '017-234-5673', 'hassan.ali@example.com', '1988-12-13'),
('C061', 'Lina Jasmine', '018-345-6784', 'lina.jasmine@example.com', '1991-01-14'),
('C062', 'Fadilah Karim', '019-456-7895', 'fadilah.karim@example.com', '1992-02-15'),
('C063', 'Aminah Yusuf', '012-567-8906', 'aminah.yusuf@example.com', '1994-03-16'),
('C064', 'Arif Ismail', '013-678-9017', 'arif.ismail@example.com', '1987-04-17'),
('C065', 'Wei Xuan Tan', '014-789-0128', 'weixuan.tan@example.com', '1993-05-18'),
('C066', 'Hani Salim', '015-890-1239', 'hani.salim@example.com', '1985-06-19'),
('C067', 'Kumar Raj', '016-901-2340', 'kumar.raj@example.com', '1989-07-20'),
('C068', 'Farah Jamil', '017-012-3451', 'farah.jamil@example.com', '1992-08-21'),
('C069', 'Tengku Sofia', '018-123-4562', 'tengku.sofia@example.com', '1991-09-22'),
('C070', 'Ahmad Amir', '019-234-5673', 'ahmad.amir@example.com', '1993-10-23'),
('C071', 'Selina Chong', '012-345-6784', 'selina.chong@example.com', '1988-11-24'),
('C072', 'Rashid Abdullah', '013-456-7895', 'rashid.abdullah@example.com', '1994-12-25'),
('C073', 'Khalid Nordin', '014-567-8906', 'khalid.nordin@example.com', '1989-01-26'),
('C074', 'Sally Tan', '015-678-9017', 'sally.tan@example.com', '1992-02-27'),
('C075', 'Arifuddin Saleh', '016-789-0128', 'arifuddin.saleh@example.com', '1985-03-28'),
('C076', 'Mira Aziz', '017-890-1239', 'mira.aziz@example.com', '1990-04-29'),
('C077', 'Vijay Kapoor', '018-901-2340', 'vijay.kapoor@example.com', '1987-05-30'),
('C078', 'Nabilah Mohd', '019-012-3451', 'nabilah.mohd@example.com', '1991-06-20'),
('C079', 'Sean Yap', '012-123-4562', 'sean.yap@example.com', '1989-07-01'),
('C080', 'Rina Abdul', '013-234-5673', 'rina.abdul@example.com', '1992-08-02'),
('C081', 'Faisal Amir', '014-345-6784', 'faisal.amir@example.com', '1988-09-03'),
('C082', 'Wei Teng', '015-456-7895', 'wei.teng@example.com', '1994-10-04'),
('C083', 'Huda Osman', '016-567-8906', 'huda.osman@example.com', '1993-11-05'),
('C084', 'Rohan Patel', '017-678-9017', 'rohan.patel@example.com', '1987-12-06'),
('C085', 'Maya Zain', '018-789-0128', 'maya.zain@example.com', '1991-01-07'),
('C086', 'Nora Halim', '019-890-1239', 'nora.halim@example.com', '1992-02-08'),
('C087', 'Zul Azad', '012-901-2340', 'zul.azad@example.com', '1988-03-09'),
('C088', 'Rachel Tan', '013-012-3451', 'rachel.tan@example.com', '1991-04-10'),
('C089', 'Akmal Firdaus', '014-123-4562', 'akmal.firdaus@example.com', '1994-05-11'),
('C090', 'Syed Arif', '015-234-5673', 'syed.arif@example.com', '1993-06-12'),
('C091', 'Daniel Lee', '016-345-6784', 'daniel.lee@example.com', '1992-07-13'),
('C092', 'Fadilah Yusof', '017-456-7895', 'fadilah.yusof@example.com', '1988-08-14'),
('C093', 'Alia Rahim', '018-567-8906', 'alia.rahim@example.com', '1994-09-15'),
('C094', 'Suresh Nair', '019-678-9017', 'suresh.nair@example.com', '1987-10-16'),
('C095', 'Melissa Wong', '012-789-0128', 'melissa.wong@example.com', '1992-11-17'),
('C096', 'Zaid Ibrahim', '013-890-1239', 'zaid.ibrahim@example.com', '1993-12-18'),
('C097', 'Hannah Lee', '014-901-2340', 'hannah.lee@example.com', '1988-01-19'),
('C098', 'Arif Salleh', '015-012-3451', 'arif.salleh@example.com', '1994-02-20'),
('C099', 'Elina Rahman', '016-123-4562', 'elina.rahman@example.com', '1993-03-21'),
('C100', 'Rahmat Omar', '017-234-5673', 'rahmat.omar@example.com', '1989-04-22');

INSERT INTO client_feedback (feedback_id, client_id, rating, review) VALUES
(2001, 'C001', 3, 'I enjoyed this workshop a lot.'),
(2002, 'C002', 4, 'I benefited from the pastry workshop and made some new friends.'),
(2003, 'C003', 2, 'The chef is not as good as expected.');

INSERT INTO chef (chef_id, name, phone_number, email, specialization) VALUES 
('CF001', 'Ahmad Hakim', '0123456789', 'ahmad.hakim@example.my', 'Pastry'),
('CF002', 'Rachel Tan', '0133456789', 'rachel.tan@example.my', 'Baking'),
('CF003', 'Lim Wei Han', '0143456789', 'lim.weihan@example.my', 'Sushi Making'),
('CF004', 'Ravi Kumar', '0153456789', 'ravi.kumar@example.my', 'Healthy Meals'),
('CF005', 'Sophia Wong', '0163456789', 'sophia.wong@example.my', 'Japanese Cuisine'),
('CF006', 'Syafiq Zainal', '0173456789', 'syafiq.zainal@example.my', 'Malay Cuisine'),
('CF007', 'Nor Hidayah', '0183456789', 'nor.hidayah@example.my', 'Fine Dining'),
('CF008', 'Cheong Kai Ming', '0193456789', 'cheong.kaiming@example.my', 'Sushi Making'),
('CF009', 'George Lee', '0113456789', 'george.lee@example.my', 'Italian Cuisine'),
('CF010', 'Wong Li Xin', '0124456789', 'wong.lixin@example.my', 'Chinese Cuisine'),
('CF011', 'Azlan Rahim', '0134456789', 'azlan.rahim@example.my', 'Grilling & BBQ'),
('CF012', 'Hannah Davis', '0144456789', 'hannah.davis@example.my', 'Baking'),
('CF013', 'Chan Wei Jie', '0154456789', 'chan.weijie@example.my', 'Seafood Specialties'),
('CF014', 'Amar Singh', '0164456789', 'amar.singh@example.my', 'Healthy Meals'),
('CF015', 'Ella Khoo', '0174456789', 'ella.khoo@example.my', 'Vegan Cooking'),
('CF016', 'Nina Othman', '0184456789', 'nina.othman@example.my', 'Fusion Cuisine'),
('CF017', 'James Parker', '0194456789', 'james.parker@example.my', 'Grilling & BBQ'),
('CF018', 'Yap Jia En', '0115456789', 'yap.jiaen@example.my', 'Sushi Making'),
('CF019', 'Ramesh Rajan', '0125456789', 'ramesh.rajan@example.my', 'Indian Cuisine'),
('CF020', 'Lisa George', '0135456789', 'lisa.george@example.my', 'Italian Cuisine'),
('CF021', 'Siti Khadijah', '0145456789', 'siti.khadijah@example.my', 'Malay Cuisine'),
('CF022', 'Emily Underwood', '0155456789', 'emily.underwood@example.my', 'Baking'),
('CF023', 'Goh Kai Xiang', '0165456789', 'goh.kaixiang@example.my', 'Chinese Cuisine'),
('CF024', 'Thivya Selvaraj', '0175456789', 'thivya.selvaraj@example.my', 'Mediterranean Cuisine'),
('CF025', 'Mazlina Ahmad', '0185456789', 'mazlina.ahmad@example.my', 'French Cuisine');

INSERT INTO certification (chef_id, cert_name, cert_date) VALUES
('CF001', 'Culinary Arts', '2023-01-15'),
('CF001', 'Pastry Chef', '2023-02-20'),
('CF001', 'Food Safety', '2023-03-10'),
('CF002', 'Culinary Arts', '2023-01-18'),
('CF002', 'Food Safety', '2023-04-05'),
('CF003', 'Culinary Arts', '2023-01-22'),
('CF003', 'Pastry Chef', '2023-02-25'),
('CF004', 'Culinary Arts', '2023-01-30'),
('CF004', 'Food Safety', '2023-03-15'),
('CF004', 'Wine Pairing', '2023-05-01'),
('CF005', 'Culinary Arts', '2023-02-01'),
('CF005', 'Food Safety', '2023-03-20'),
('CF006', 'Culinary Arts', '2023-02-10'),
('CF006', 'Pastry Chef', '2023-04-10'),
('CF007', 'Culinary Arts', '2023-02-15'),
('CF007', 'Food Safety', '2023-03-25'),
('CF007', 'Wine Pairing', '2023-05-05'),
('CF008', 'Culinary Arts', '2023-02-20'),
('CF008', 'Pastry Chef', '2023-04-15'),
('CF009', 'Culinary Arts', '2023-02-25'),
('CF009', 'Food Safety', '2023-03-30'),
('CF010', 'Culinary Arts', '2023-03-01'),
('CF010', 'Pastry Chef', '2023-04-20'),
('CF010', 'Food Safety', '2023-05-10'),
('CF010', 'Wine Pairing', '2023-05-15');

INSERT INTO class (class_id, name, date, start_time, end_time, revenue, class_type, chef_id) VALUES
('WS001', 'Baking Basics', '2023-01-10', '10:00:00', '12:00:00', 105, 'workshop', 'CF002'),
('WS002', 'Italian Cuisine Mastery', '2023-01-15', '14:00:00', '16:00:00', 120, 'workshop', 'CF009'),
('WS003', 'Sushi Making 101', '2023-01-20', '11:00:00', '13:00:00', 115, 'workshop', 'CF003'),
('WS004', 'Indian Cuisine Essentials', '2023-01-25', '09:00:00', '11:00:00', 90, 'workshop', 'CF019'),
('WS005', 'Chinese Cuisine Techniques', '2023-02-01', '10:00:00', '12:00:00', 100, 'workshop', 'CF010'),
('WS006', 'Malay Cuisine Delights', '2023-02-05', '14:00:00', '16:00:00', 115, 'workshop', 'CF006'),
('WS007', 'Advanced Baking', '2023-02-10', '10:00:00', '12:00:00', 95, 'workshop', 'CF005'),
('WS008', 'Sushi Artistry', '2023-02-15', '11:00:00', '13:00:00', 120, 'workshop', 'CF008'),
('WS009', 'Italian Pasta Making', '2023-02-20', '09:00:00', '11:00:00', 110, 'workshop', 'CF020'),
('WS010', 'Healthy Indian Cooking', '2023-02-25', '10:00:00', '12:00:00', 90, 'workshop', 'CF019'),
('WS011', 'Chinese Dumpling Workshop', '2023-03-01', '14:00:00', '16:00:00', 105, 'workshop', 'CF023'),
('WS012', 'Malay Nasi Lemak', '2023-03-05', '10:00:00', '12:00:00', 115, 'workshop', 'CF021'),
('WS013', 'Vegan Baking', '2023-03-10', '11:00:00', '13:00:00', 90, 'workshop', 'CF015'),
('WS014', 'Fusion Cuisine Workshop', '2023-03-15', '09:00:00', '11:00:00', 110, 'workshop', 'CF016'),
('WS015', 'Mediterranean Flavors', '2023-03-20', '10:00:00', '12:00:00', 100, 'workshop', 'CF024'),
('WS016', 'French Pastry Techniques', '2023-03-25', '14:00:00', '16:00:00', 105, 'workshop', 'CF025'),
('WS017', 'Sushi Rolling Masterclass', '2023-04-01', '10:00:00', '12:00:00', 115, 'workshop', 'CF018'),
('WS018', 'Healthy Meal Prep', '2023-04-05', '11:00:00', '13:00:00', 95, 'workshop', 'CF004'),
('WS019', 'Baking for Beginners', '2023-04-10', '09:00:00', '11:00:00', 120, 'workshop', 'CF012'),
('WS020', 'Italian Sauces and Pastas', '2023-04-15', '10:00:00', '12:00:00', 90, 'workshop', 'CF020'),
('WS021', 'Sushi and Sashimi', '2023-04-20', '14:00:00', '16:00:00', 105, 'workshop', 'CF003'),
('WS022', 'Indian Street Food', '2023-04-25', '10:00:00', '12:00:00', 115, 'workshop', 'CF019'),
('WS023', 'Chinese Stir-Fry Techniques', '2023-05-01', '11:00:00', '13:00:00', 90, 'workshop', 'CF010'),
('WS024', 'Malay Traditional Dishes', '2023-05-05', '09:00:00', '11:00:00', 110, 'workshop', 'CF006'),
('WS025', 'Vegan Cooking Essentials', '2023-05-10', '10:00:00', '12:00:00', 100, 'workshop', 'CF015'),
('WS026', 'Fusion Cooking Techniques', '2023-05-15', '14:00:00', '16:00:00', 95, 'workshop', 'CF016'),
('WS027', 'Mediterranean Cooking', '2023-05-20', '10:00:00', '12:00:00', 115, 'workshop', 'CF024'),
('WS028', 'French Cuisine Basics', '2023-05-25', '11:00:00', '13:00:00', 120, 'workshop', 'CF025');


INSERT INTO seminar (class_id, activity_type) VALUES
('SS001', 'cooking demonstrations'),
('SS002', 'ingredient testing'),
('SS003', 'recipes analysis');

INSERT INTO workshop (class_id, workshop_type, difficulty_level) VALUES
('WS001', 'baking', 'medium'),
('WS002', 'italian cuisine', 'hard'),
('WS003', 'sushi making', 'easy');

INSERT INTO private_session (class_id, client_special_request) VALUES
('PS001', 'special request for vegetarian sushi'),
('PS002', 'request for custom fusion dishes'),
('PS003', 'client interested in learning authentic Chinese stir fry');

INSERT INTO attendance (attendance_id, class_id, class_type, client_id) VALUES
(6001, 'WS001', 'workshop', 'C001'),
(6002, 'SS001', 'seminar', 'C001'),
(6003, 'PS001', 'private_session', 'C001'),
(6004, 'WS001', 'workshop', 'C002'),
(6005, 'SS001', 'seminar', 'C003'),
(6006, 'PS001', 'private_session', 'C004'),
(6007, 'SS001', 'seminar', 'C005'),
(6008, 'WS001', 'workshop', 'C006'),
(6009, 'PS001', 'private_session','C006'),
(6010, 'SS001', 'seminar', 'C007');

INSERT INTO advertainment (adv_id, adv_type, platform) VALUES
('ADV001', 'Video Advertisement', 'YouTube'),
('ADV002', 'Banner Advertisement', 'Google Ads'),
('ADV003', 'Sponsored Post', 'Instagram'),
('ADV004', 'Pop-up Ad', 'Facebook'),
('ADV005', 'Audio Ad', 'Spotify'),
('ADV006', 'Carousel Ad', 'Instagram'),
('ADV007', 'Search Ad', 'Google'),
('ADV008', 'Story Ad', 'Snapchat'),
('ADV009', 'In-App Ad', 'Mobile Games'),
('ADV010', 'Native Advertisement', 'Web Blogs');

INSERT INTO promote (class_id, adv_id) VALUES
('SS001', 'ADV002'),
('SS002', 'ADV007'),
('SS003', 'ADV003');

INSERT INTO equipment (equipment_id, equipment_name, quantity) VALUES
('E001', 'Oven', 5),
('E002', 'Mixer', 10),
('E003', 'Knives', 20),
('E004', 'Cooking Pot', 15),
('E005', 'Rolling Pin', 12),
('E006', 'Measuring Cups', 25),
('E007', 'Cutting Board', 30),
('E009', 'Spatula', 40),
('E010', 'Whisk', 50),
('E008', 'Baking Tray', 10);

INSERT INTO membership (member_id, client_id, exclusive_chef) VALUES
('M001', 'C001', 'yes'),
('M002', 'C002', 'yes'),
('M003', 'C003', 'no'),
('M004', 'C004', 'yes'),
('M005', 'C005', 'no'),
('M006', 'C006', 'yes');

INSERT INTO renting (renting_id, start_date, end_date, client_id, equipment_id) VALUES
(10001, '2024-01-10', '2024-01-15', 'C001', 'E001'),
(10002, '2024-02-05', '2024-02-10', 'C002', 'E002'),
(10003, '2024-03-01', '2024-03-07', 'C003', 'E003'),
(10004, '2024-04-12', '2024-04-18', 'C004', 'E004'),
(10005, '2024-05-03', '2024-05-08', 'C005', 'E005'),
(10006, '2024-06-07', '2024-06-14', 'C006', 'E007'),
(10007, '2024-07-20', '2024-07-25', 'C007', 'E008'),
(10008, '2024-08-13', '2024-08-18', 'C008', 'E002'),
(10009, '2024-09-04', '2024-09-10', 'C009', 'E001'),
(10010, '2024-10-01', '2024-10-07', 'C010', 'E004');

INSERT INTO chef_meet_n_greet (cmg_id, date, start_time, end_time, chef_id) VALUES
(20001, '2024-01-20', '10:00:00', '12:00:00', 'CF001'),
(20002, '2024-02-15', '14:00:00', '16:00:00', 'CF003'),
(20003, '2024-03-10', '18:00:00', '20:00:00', 'CF002'),
(20004, '2024-04-25', '11:00:00', '13:00:00', 'CF003'),
(20005, '2024-05-18', '09:00:00', '11:00:00', 'CF004'),
(20006, '2024-06-23', '17:00:00', '19:00:00', 'CF005'),
(20007, '2024-07-30', '12:00:00', '14:00:00', 'CF008'),
(20008, '2024-08-22', '15:00:00', '17:00:00', 'CF001'),
(20009, '2024-09-14', '10:00:00', '12:00:00', 'CF003'),
(20010, '2024-10-05', '13:00:00', '15:00:00', 'CF004');

INSERT INTO cmg_participants (cmg_id, participant_id) VALUES
('CF001','M001'),
('CF003''M001'),
('CF002''M001'),
('CF003''M002'),
('CF004''M001'),
('CF005''M004'),
('CF008''M006'),
('CF001''M006'),
('CF003','M004'),
('CF004','M006');

INSERT INTO group_membership (group_id, holder_id, no_of_pax) VALUES
('GM001', 'M001', 4),
('GM002', 'M002', 3);


INSERT INTO group_info (group_id, client_id) VALUES
('GM001', 'C001'),
('GM001', 'C002'),
('GM001', 'C003'),
('GM001', 'C004'),
('GM001', 'C005'),
('GM002', 'C006'),
('GM002', 'C007'),
('GM002', 'C008'),
('GM002', 'C009');

INSERT INTO challenge (challenge_id, challenge_name) VALUES
(11001, 'Best Dessert'),
(11002, 'Creative Sushi'),
(11003, 'Perfect Pasta'),
(11004, 'Artistic Plating'),
(11005, 'Healthy Cooking Challenge'),
(11006, 'Fusion Fiesta'),
(11007, 'Fine Dining Skills'),
(11008, 'Ingredient Mastery'),
(11009, 'Food Presentation Pro'),
(11010, 'Baking Excellence');

INSERT INTO badge (badges_id, member_id, challenge_id) VALUES
(12001, 'M001', 11001),
(12002, 'M002', 11002),
(12003, 'M003', 11003),
(12004, 'M004', 11004),
(12005, 'M005', 11005),
(12006, 'M006', 11006),
(12007, 'M002', 11007),
(12008, 'M003', 11008),
(12009, 'M001', 11009),
(12010, 'M004', 11010);

INSERT INTO brand VALUES 
(1,'Gourmet Gurus'),
(2,'Master Chef Club');

INSERT INTO b_benefits VALUES
(101, 1,'Fitness Meal Recipe'),
(102, 1,'Digital Meal Planner Subscription'),
(103, 1,'Pastry Recipe Book'),
(104, 2,'Digital Healthy & Nutrition Guides'),
(105, 2,'Nutritious Meal Recipe'),
(106, 2,'Virtual COoking Tutorials for Easy Recipes');

INSERT INTO client_brand VALUES
('C001',1),
('C002',2),
('C003',1),
('C004',1),
('C005',2),
('C006',1),
('C007',2),
('C001',2);

INSERT INTO bday_redeem (member_id, status, gift, redeem_date) VALUES
('M001', 'redeemed', 'Gift Card', '2023-10-01'),
('M002', 'unclaimed', NULL, NULL),
('M003', 'redeemed', 'Birthday Cake', '2023-10-02'),
('M004', 'unclaimed', NULL, NULL),
('M005', 'redeemed', 'Gift Voucher', '2023-10-03'),
('M006', 'unclaimed', NULL, NULL);

INSERT INTO merchandise VALUES
('MCD001', 'Chef Knife', 49.99, 'Kitchen Tools'),
('MCD002', 'Cutting Board', 25.50, 'Kitchen Tools'),
('MCD003', 'Mixing Bowl Set', 15.75, 'Baking Supplies'),
('MCD004', 'Measuring Cups', 10.00, 'Baking Supplies'),
('MCD005', 'Whisk', 8.25, 'Kitchen Tools'),
('MCD006', 'Apron', 19.99, 'Apparel'),
('MCD007', 'Spatula', 5.50, 'Kitchen Tools'),
('MCD008', 'Cookbook', 29.95, 'Literature'),
('MCD009', 'Food Processor', 199.99, 'Appliances'),
('MCD010', 'Blender', 89.99, 'Appliances'),
('MCD011', 'Baking Sheet', 12.00, 'Baking Supplies'),
('MCD012', 'Rolling Pin', 14.50, 'Baking Supplies'),
('MCD013', 'Tongs', 7.75, 'Kitchen Tools'),
('MCD014', 'Grater', 9.99, 'Kitchen Tools'),
('MCD015', 'Oven Mitts', 11.50, 'Apparel'),
('MCD016', 'Pasta Maker', 79.99, 'Appliances'),
('MCD017', 'Salad Spinner', 18.00, 'Kitchen Tools'),
('MCD018', 'Knife Sharpener', 15.00, 'Kitchen Tools'),
('MCD019', 'Cast Iron Skillet', 39.99, 'Cookware'),
('MCD020', 'Non-Stick Frying Pan', 34.50, 'Cookware'),
('MCD021', 'Steamer Basket', 12.99, 'Cookware'),
('MCD022', 'Meat Thermometer', 20.00, 'Kitchen Tools'),
('MCD023', 'Silicone Baking Mat', 10.50, 'Baking Supplies'),
('MCD024', 'Coffee Maker', 49.99, 'Appliances'),
('MCD025', 'Tea Kettle', 25.00, 'Appliances'),
('MCD026', 'Ice Cream Maker', 99.99, 'Appliances'),
('MCD027', 'Mandoline Slicer', 35.00, 'Kitchen Tools'),
('MCD028', 'Food Scale', 22.50, 'Kitchen Tools'),
('MCD029', 'Blow Torch', 29.99, 'Kitchen Tools'),
('MCD030', 'Sous Vide Cooker', 149.99, 'Appliances');

INSERT INTO merch_purchase VALUES
('C001', 'MCD001', '2023-10-01', 2, 99.98),
('C002', 'MCD002', '2023-10-02', 1, 25.50),
('C003', 'MCD003', '2023-10-03', 3, 47.25),
('C004', 'MCD004', '2023-10-04', 5, 50.00),
('C005', 'MCD005', '2023-10-05', 4, 33.00),
('C006', 'MCD006', '2023-10-06', 1, 19.99),
('C007', 'MCD007', '2023-10-07', 6, 33.00),
('C008', 'MCD008', '2023-10-08', 2, 59.90),
('C009', 'MCD009', '2023-10-09', 1, 199.99),
('C010', 'MCD010', '2023-10-10', 1, 89.99),
('C011', 'MCD011', '2023-10-11', 3, 36.00),
('C012', 'MCD012', '2023-10-12', 2, 29.00),
('C013', 'MCD013', '2023-10-13', 5, 38.75),
('C014', 'MCD014', '2023-10-14', 4, 39.96),
('C015', 'MCD015', '2023-10-15', 3, 34.50),
('C016', 'MCD016', '2023-10-16', 1, 79.99),
('C017', 'MCD017', '2023-10-17', 2, 36.00),
('C018', 'MCD018', '2023-10-18', 1, 15.00),
('C019', 'MCD019', '2023-10-19', 2, 79.98),
('C020', 'MCD020', '2023-10-20', 1, 34.50),
('C021', 'MCD021', '2023-10-21', 3, 38.97),
('C022', 'MCD022', '2023-10-22', 2, 40.00),
('C023', 'MCD023', '2023-10-23', 1, 10.50),
('C024', 'MCD024', '2023-10-24', 2, 99.98),
('C025', 'MCD025', '2023-10-25', 1, 25.00),
('C026', 'MCD026', '2023-10-26', 1, 99.99),
('C027', 'MCD027', '2023-10-27', 2, 70.00),
('C028', 'MCD028', '2023-10-28', 3, 67.50),
('C029', 'MCD029', '2023-10-29', 1, 29.99),
('C030', 'MCD030', '2023-10-30', 1, 149.99),
('C031', 'MCD001', '2023-10-01', 2, 99.98),
('C032', 'MCD002', '2023-10-02', 1, 25.50),
('C033', 'MCD003', '2023-10-03', 3, 47.25),
('C034', 'MCD004', '2023-10-04', 5, 50.00),
('C035', 'MCD005', '2023-10-05', 4, 33.00),
('C036', 'MCD006', '2023-10-06', 1, 19.99),
('C037', 'MCD007', '2023-10-07', 6, 33.00),
('C038', 'MCD008', '2023-10-08', 2, 59.90),
('C039', 'MCD009', '2023-10-09', 1, 199.99),
('C040', 'MCD010', '2023-10-10', 1, 89.99),
('C041', 'MCD011', '2023-10-11', 3, 36.00),
('C042', 'MCD012', '2023-10-12', 2, 29.00),
('C043', 'MCD013', '2023-10-13', 5, 38.75),
('C044', 'MCD014', '2023-10-14', 4, 39.96),
('C045', 'MCD015', '2023-10-15', 3, 34.50),
('C046', 'MCD016', '2023-10-16', 1, 79.99),
('C047', 'MCD017', '2023-10-17', 2, 36.00),
('C048', 'MCD018', '2023-10-18', 1, 15.00),
('C049', 'MCD019', '2023-10-19', 2, 79.98),
('C050', 'MCD020', '2023-10-20', 1, 34.50),
('C051', 'MCD021', '2023-10-21', 3, 38.97),
('C052', 'MCD022', '2023-10-22', 2, 40.00),
('C053', 'MCD023', '2023-10-23', 1, 10.50),
('C054', 'MCD024', '2023-10-24', 2, 99.98),
('C055', 'MCD025', '2023-10-25', 1, 25.00),
('C056', 'MCD026', '2023-10-26', 1, 99.99),
('C057', 'MCD027', '2023-10-27', 2, 70.00),
('C058', 'MCD028', '2023-10-28', 3, 67.50),
('C059', 'MCD029', '2023-10-29', 1, 29.99),
('C060', 'MCD030', '2023-10-30', 1, 149.99);


