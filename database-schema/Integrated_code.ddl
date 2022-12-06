
--create tables

CREATE TABLE web_user (
    user_id     NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    usrname     VARCHAR2(20) NOT NULL,
    password    RAW(60) NOT NULL,
    type        CHAR(1) NOT NULL
);

ALTER TABLE web_user ADD CONSTRAINT web_user_pk PRIMARY KEY ( user_id );
ALTER TABLE web_user ADD CONSTRAINT usrname_unique UNIQUE (usrname);

CREATE TABLE author (
    author_id     NUMBER(9) NOT NULL,
    author_fname  VARCHAR2(30) NOT NULL,
    author_mname  VARCHAR2(30),
    author_lname  VARCHAR2(30) NOT NULL,
    author_street VARCHAR2(30),
    author_city   VARCHAR2(30),
    author_state  CHAR(2),
    author_zip    CHAR(5),
    author_email  VARCHAR2(30)
);

ALTER TABLE author ADD CONSTRAINT author_pk PRIMARY KEY ( author_id );

CREATE TABLE book (
    book_id    NUMBER(9) NOT NULL,
    book_title VARCHAR2(100) NOT NULL,
    book_topic VARCHAR2(30) NOT NULL
);

ALTER TABLE book ADD CONSTRAINT book_pk PRIMARY KEY ( book_id );

CREATE TABLE book_author (
    book_id   NUMBER(9) NOT NULL,
    author_id NUMBER(9) NOT NULL
);

ALTER TABLE book_author ADD CONSTRAINT book_author_pk PRIMARY KEY ( book_id,
                                                                    author_id );

CREATE TABLE book_copy (
    copy_id     NUMBER(9) NOT NULL,
    copy_status CHAR(1) NOT NULL,
    book_id     NUMBER(9) NOT NULL
);

ALTER TABLE book_copy ADD CONSTRAINT book_copy_pk PRIMARY KEY ( copy_id );

CREATE TABLE book_rental (
    rental_id       NUMBER(9) NOT NULL,
    rental_status   CHAR(1) NOT NULL,
    borrow_date     DATE NOT NULL,
    exp_return_date DATE NOT NULL,
    return_date     DATE,
    copy_id         NUMBER(9) NOT NULL,
    invoice_id      NUMBER(9),
    cust_id         NUMBER(9) NOT NULL
);

CREATE UNIQUE INDEX book_rental__idx ON
    book_rental (
        invoice_id
    ASC );

ALTER TABLE book_rental ADD CONSTRAINT book_rental_pk PRIMARY KEY ( rental_id );

CREATE TABLE customer (
    cust_id     NUMBER(9) NOT NULL,
    cust_fname  VARCHAR2(30) NOT NULL,
    cust_mname  VARCHAR2(30),
    cust_lname  VARCHAR2(30) NOT NULL,
    cust_street VARCHAR2(30) NOT NULL,
    cust_city   VARCHAR2(30) NOT NULL,
    cust_state  CHAR(2) NOT NULL,
    cust_zip    CHAR(5) NOT NULL,
    cust_email  VARCHAR2(30) NOT NULL,
    cust_phone  VARCHAR2(10) NOT NULL,
    id_type     VARCHAR2(14) NOT NULL,
    id_number   NUMBER(9) NOT NULL
);

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( cust_id );

CREATE TABLE event (
    event_id    NUMBER(9) NOT NULL,
    event_name  VARCHAR2(30) NOT NULL,
    event_topic VARCHAR2(30) NOT NULL,
    start_time  DATE NOT NULL,
    end_time    DATE NOT NULL,
    event_type  CHAR(1) NOT NULL
);

ALTER TABLE event
    ADD CONSTRAINT ch_inh_event CHECK ( event_type IN ( 'E', 'EVENT', 'S' ) );

ALTER TABLE event ADD CONSTRAINT event_pk PRIMARY KEY ( event_id );

CREATE TABLE exhib_expense (
    expense_id       NUMBER(9) NOT NULL,
    expense_amount   NUMBER(13, 2) NOT NULL,
    expense_descript VARCHAR2(100) NOT NULL,
    event_id         NUMBER(9) NOT NULL
);

ALTER TABLE exhib_expense ADD CONSTRAINT exhib_expense_pk PRIMARY KEY ( expense_id );

CREATE TABLE exhibition (
    event_id NUMBER(9) NOT NULL
);

ALTER TABLE exhibition ADD CONSTRAINT exhibition_pk PRIMARY KEY ( event_id );

CREATE TABLE exhibition_attendee (
    registration_id NUMBER(9) NOT NULL,
    cust_id       NUMBER(9) NOT NULL,
    event_id      NUMBER(9) NOT NULL
);

ALTER TABLE exhibition_attendee ADD CONSTRAINT exhibition_attendee_pk PRIMARY KEY ( registration_id );

CREATE TABLE individual (
    sponsor_id    NUMBER(9) NOT NULL,
    sponsor_fname VARCHAR2(30) NOT NULL,
    sponsor_mname VARCHAR2(30),
    sponsor_lname VARCHAR2(30) NOT NULL
);

ALTER TABLE individual ADD CONSTRAINT individual_pk PRIMARY KEY ( sponsor_id );

CREATE TABLE organization (
    sponsor_id NUMBER(9) NOT NULL,
    org_name   VARCHAR2(30) NOT NULL
);

ALTER TABLE organization ADD CONSTRAINT organization_pk PRIMARY KEY ( sponsor_id );

CREATE TABLE rental_invoice (
    invoice_id     NUMBER(9) GENERATED ALWAYS AS IDENTITY,
    invoice_date   DATE NOT NULL,
    invoice_status CHAR(1) NOT NULL,
    invoice_amount NUMBER(13, 2)
);

ALTER TABLE rental_invoice ADD CONSTRAINT rental_invoice_pk PRIMARY KEY ( invoice_id );

CREATE TABLE rental_payment (
    payment_id     NUMBER(9) NOT NULL,
    payment_date   DATE NOT NULL,
    payment_method VARCHAR2(30) NOT NULL,
    payment_amount NUMBER(13, 2) NOT NULL,
    card_fname     VARCHAR2(30),
    card_mname     VARCHAR2(30),
    card_lname     VARCHAR2(30),
    invoice_id     NUMBER(9) NOT NULL
);

ALTER TABLE rental_payment ADD CONSTRAINT rental_payment_pk PRIMARY KEY ( payment_id );

CREATE TABLE room_reservation (
    res_date     DATE NOT NULL,
    res_timeslot CHAR(2) NOT NULL,
    room_id      NUMBER(9) NOT NULL,
    cust_id      NUMBER(9) NOT NULL
);

ALTER TABLE room_reservation
    ADD CONSTRAINT room_reservation_pk PRIMARY KEY ( res_date,
                                                     room_id,
                                                     res_timeslot );

CREATE TABLE seminar (
    event_id NUMBER(9) NOT NULL
);

ALTER TABLE seminar ADD CONSTRAINT seminar_pk PRIMARY KEY ( event_id );

CREATE TABLE seminar_attendee (
    invitation_id NUMBER(9) NOT NULL,
    author_id       NUMBER(9) NOT NULL,
    event_id        NUMBER(9) NOT NULL
);

ALTER TABLE seminar_attendee ADD CONSTRAINT seminar_attendee_pk PRIMARY KEY ( invitation_id );

CREATE TABLE seminar_sponsor (
    event_id       NUMBER(9) NOT NULL,
    sponsor_id     NUMBER(9) NOT NULL,
    sponsor_amount NUMBER(13, 2) NOT NULL
);

ALTER TABLE seminar_sponsor ADD CONSTRAINT seminar_sponsor_pk PRIMARY KEY ( sponsor_id,
                                                                            event_id );

CREATE TABLE sponsor (
    sponsor_id    NUMBER(9) NOT NULL,
    sponsor_email VARCHAR2(30),
    sponsor_phone VARCHAR2(10),
    sponsor_type  CHAR(1) NOT NULL
);

ALTER TABLE sponsor
    ADD CONSTRAINT ch_inh_sponsor CHECK ( sponsor_type IN ( 'I', 'O', 'SPONSOR' ) );

ALTER TABLE sponsor ADD CONSTRAINT sponsor_pk PRIMARY KEY ( sponsor_id );

CREATE TABLE study_room (
    room_id  NUMBER(9) NOT NULL,
    capacity NUMBER(2) NOT NULL
);

ALTER TABLE study_room ADD CONSTRAINT study_room_pk PRIMARY KEY ( room_id );

ALTER TABLE book_author
    ADD CONSTRAINT book_author_author_fk FOREIGN KEY ( author_id )
        REFERENCES author ( author_id );

ALTER TABLE book_author
    ADD CONSTRAINT book_author_book_fk FOREIGN KEY ( book_id )
        REFERENCES book ( book_id );

ALTER TABLE book_copy
    ADD CONSTRAINT book_copy_book_fk FOREIGN KEY ( book_id )
        REFERENCES book ( book_id );

ALTER TABLE book_rental
    ADD CONSTRAINT book_rental_book_copy_fk FOREIGN KEY ( copy_id )
        REFERENCES book_copy ( copy_id );

ALTER TABLE book_rental
    ADD CONSTRAINT book_rental_customer_fk FOREIGN KEY ( cust_id )
        REFERENCES customer ( cust_id );

ALTER TABLE book_rental
    ADD CONSTRAINT book_rental_rental_invoice_fk FOREIGN KEY ( invoice_id )
        REFERENCES rental_invoice ( invoice_id );

ALTER TABLE exhib_expense
    ADD CONSTRAINT exhib_expense_exhibition_fk FOREIGN KEY ( event_id )
        REFERENCES exhibition ( event_id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE exhibition_attendee
    ADD CONSTRAINT exhibition_attendee_customer_fk FOREIGN KEY ( cust_id )
        REFERENCES customer ( cust_id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE exhibition_attendee
    ADD CONSTRAINT exhibition_attendee_exhibition_fk FOREIGN KEY ( event_id )
        REFERENCES exhibition ( event_id );

ALTER TABLE exhibition
    ADD CONSTRAINT exhibition_event_fk FOREIGN KEY ( event_id )
        REFERENCES event ( event_id );

ALTER TABLE individual
    ADD CONSTRAINT individual_sponsor_fk FOREIGN KEY ( sponsor_id )
        REFERENCES sponsor ( sponsor_id );

ALTER TABLE organization
    ADD CONSTRAINT organization_sponsor_fk FOREIGN KEY ( sponsor_id )
        REFERENCES sponsor ( sponsor_id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE rental_payment
    ADD CONSTRAINT rental_payment_rental_invoice_fk FOREIGN KEY ( invoice_id )
        REFERENCES rental_invoice ( invoice_id );

ALTER TABLE room_reservation
    ADD CONSTRAINT room_reservation_customer_fk FOREIGN KEY ( cust_id )
        REFERENCES customer ( cust_id );

ALTER TABLE room_reservation
    ADD CONSTRAINT room_reservation_study_room_fk FOREIGN KEY ( room_id )
        REFERENCES study_room ( room_id );

ALTER TABLE seminar_attendee
    ADD CONSTRAINT seminar_attendee_author_fk FOREIGN KEY ( author_id )
        REFERENCES author ( author_id );

ALTER TABLE seminar_attendee
    ADD CONSTRAINT seminar_attendee_seminar_fk FOREIGN KEY ( event_id )
        REFERENCES seminar ( event_id );

ALTER TABLE seminar
    ADD CONSTRAINT seminar_event_fk FOREIGN KEY ( event_id )
        REFERENCES event ( event_id );

ALTER TABLE seminar_sponsor
    ADD CONSTRAINT seminar_sponsor_seminar_fk FOREIGN KEY ( event_id )
        REFERENCES seminar ( event_id );

ALTER TABLE seminar_sponsor
    ADD CONSTRAINT seminar_sponsor_sponsor_fk FOREIGN KEY ( sponsor_id )
        REFERENCES sponsor ( sponsor_id );

CREATE OR REPLACE TRIGGER arc_fkarc_3_seminar BEFORE
    INSERT OR UPDATE OF event_id ON seminar
    FOR EACH ROW
DECLARE
    d CHAR(1);
BEGIN
    SELECT
        a.event_type
    INTO d
    FROM
        event a
    WHERE
        a.event_id = :new.event_id;

    IF ( d IS NULL OR d <> 'S' ) THEN
        raise_application_error(-20223, 'FK SEMINAR_EVENT_FK in Table SEMINAR violates Arc constraint on Table EVENT - discriminator column Event_Type doesn''t have value ''S'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_3_exhibition BEFORE
    INSERT OR UPDATE OF event_id ON exhibition
    FOR EACH ROW
DECLARE
    d CHAR(1);
BEGIN
    SELECT
        a.event_type
    INTO d
    FROM
        event a
    WHERE
        a.event_id = :new.event_id;

    IF ( d IS NULL OR d <> 'E' ) THEN
        raise_application_error(-20223, 'FK EXHIBITION_EVENT_FK in Table EXHIBITION violates Arc constraint on Table EVENT - discriminator column Event_Type doesn''t have value ''E'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_4_individual BEFORE
    INSERT OR UPDATE OF sponsor_id ON individual
    FOR EACH ROW
DECLARE
    d CHAR(1);
BEGIN
    SELECT
        a.sponsor_type
    INTO d
    FROM
        sponsor a
    WHERE
        a.sponsor_id = :new.sponsor_id;

    IF ( d IS NULL OR d <> 'I' ) THEN
        raise_application_error(-20223, 'FK INDIVIDUAL_SPONSOR_FK in Table INDIVIDUAL violates Arc constraint on Table SPONSOR - discriminator column Sponsor_Type doesn''t have value ''I'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_4_organization BEFORE
    INSERT OR UPDATE OF sponsor_id ON organization
    FOR EACH ROW
DECLARE
    d CHAR(1);
BEGIN
    SELECT
        a.sponsor_type
    INTO d
    FROM
        sponsor a
    WHERE
        a.sponsor_id = :new.sponsor_id;

    IF ( d IS NULL OR d <> 'O' ) THEN
        raise_application_error(-20223, 'FK ORGANIZATION_SPONSOR_FK in Table ORGANIZATION violates Arc constraint on Table SPONSOR - discriminator column Sponsor_Type doesn''t have value ''O'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/



--check Constraints DDL Code

ALTER TABLE WEB_USER ADD CONSTRAINT user_type
CHECK (
    (type = 'C') OR
    (type = 'E')
);
ALTER TABLE CUSTOMER ADD CONSTRAINT id_type
CHECK (
  (ID_Type = 'P') OR
  (ID_Type = 'S') OR
  (ID_Type = 'D')
);
ALTER TABLE BOOK_COPY ADD CONSTRAINT COPY_STATUS
CHECK (
  (Copy_Status = 'A') OR
  (Copy_Status = 'N')
);
ALTER TABLE BOOK_RENTAL ADD CONSTRAINT RENTAL_STATUS
CHECK (
  (Rental_Status = 'B') OR
  (Rental_Status = 'R') OR
  (Rental_Status = 'L')
);
ALTER TABLE ROOM_RESERVATION ADD CONSTRAINT RES_TIMESLOT
CHECK (
  (Res_Timeslot = '08') OR
  (Res_Timeslot = '11') OR
  (Res_Timeslot = '01')OR
  (Res_Timeslot = '04')
);
ALTER TABLE RENTAL_INVOICE ADD CONSTRAINT INVOICE_STATUS
CHECK (
  (Invoice_Status = 'O') OR
  (Invoice_Status = 'C')
);





--Rental Return Trigger Code

CREATE TRIGGER CREATE_INVOICE BEFORE UPDATE ON BOOK_RENTAL FOR EACH ROW
BEGIN
  IF (:OLD.Return_Date IS NULL) THEN
    IF (:NEW.Return_Date IS NOT NULL) THEN
      IF (:NEW.Return_Date <= :OLD.Exp_Return_Date) THEN
        INSERT INTO RENTAL_INVOICE(Invoice_Date, Invoice_Status, Invoice_Amount)
     VALUES (:NEW.Return_Date, 'O', ((:NEW.Return_Date-:OLD.Borrow_Date)*0.2));
      ELSE
        INSERT INTO RENTAL_INVOICE(Invoice_Date, Invoice_Status, Invoice_Amount)
        VALUES (
          :NEW.Return_Date,
          'O',
          (((:OLD.Exp_Return_Date - :OLD.Borrow_Date) * 0.2) +
          ((:NEW.Return_Date - :OLD.Exp_Return_Date) * 0.4))
        );
      END IF;
    END IF;
  END IF;
END;
/


--insert data

INSERT ALL
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (1, 'Into the Wild', 'Biography')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (2, 'The Shadow of the Wind', 'Mystery')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (3, 'The Handmaid''s Tale', 'Dystopia')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (4, 'The Shining', 'Horror')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (5, 'Dune', 'Science Fiction')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (6, 'The Lord of the Rings: The Fellowship of the Ring', 'Fantasy')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (7, 'The Lord of the Rings: The Two Towers', 'Fantasy')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (8, 'Database System Concepts', 'Educational')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (9, 'The Lord of the Rings: The Return of the King', 'Fantasy')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (10, 'The Iliad', 'Epic Poetry')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (11, 'The Odyssey', 'Epic Poetry')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (12, 'Pride and Prejudice', 'Romance')
INTO BOOK(Book_ID, Book_Title, Book_Topic) VALUES (13, 'The Talisman', 'Horror')
SELECT * FROM dual;




INSERT ALL
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (1, 'Jon', 'Krakauer')
INTO AUTHOR(Author_ID, Author_FName, Author_MName, Author_LName) VALUES (2, 'Carlos', 'Ruiz', 'Zaf贸n')
INTO AUTHOR(Author_ID, Author_FName, Author_LName, Author_Street, Author_City, Author_State, Author_ZIP) VALUES (3, 'Stephen', 'King', '47 W Broadway', 'Bangor', 'ME', 04401)
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (4, 'Margaret', 'Atwood')
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (5, 'Frank', 'Herbert')
INTO AUTHOR(Author_ID, Author_FName, Author_MName, Author_LName) VALUES (6, 'John', 'Ronald Reuel', 'Tolkien')
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (7, 'S.', 'Sudarshan')
INTO AUTHOR(Author_ID, Author_FName, Author_MName, Author_LName) VALUES (8, 'Henry', 'Francis', 'Korth')
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (9, 'Avi', 'Silberschatz')
INTO AUTHOR(Author_ID, Author_FName, Author_LName, Author_Email) VALUES (10, 'Homer', 'Unknown', 'homer@ancientgreece.gr')
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (11, 'Jane', 'Austin')
INTO AUTHOR(Author_ID, Author_FName, Author_LName) VALUES (12, 'Peter', 'Straub')
SELECT * FROM dual;



INSERT ALL
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (1,3)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (2,1)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (3,3)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (3,9)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (3,2)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (4,8)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (5,7)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (5,1)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (6,4)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (7,2)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (8,3)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (9,12)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (9,11)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (10,7)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (11,8)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (12,4)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (12,1)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (13,5)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (13,7)
INTO BOOK_AUTHOR(Book_ID, Author_ID) VALUES (13,9)
SELECT * FROM dual;

INSERT ALL
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(1,'A',1)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(2,'N',1)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(3,'A',2)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(4,'N',2)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(5,'N',2)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(6,'N',3)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(7,'A',4)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(8,'N',5)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(9,'N',6)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(10,'N',6)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(11,'A',6)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(12,'N',6)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(13,'A',7)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(14,'N',8)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(15,'A',9)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(16,'N',10)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(17,'N',11)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(18,'A',12)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(19,'A',12)
INTO BOOK_COPY(Copy_ID,Copy_Status,Book_ID) VALUES(20,'A',13)
SELECT * FROM dual;




INSERT ALL
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(1,'Meandering Pathway','Photography',DATE '2019-01-23',DATE '2019-01-25','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(2,'Rider on the Horizon','Arts',DATE '2019-02-17',DATE '2019-02-20','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(3,'Features of Greek Sculpture','Arts',DATE '2019-03-02',DATE '2019-03-03','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(4,'Asia etiquette','Culture',DATE '2019-05-11',DATE '2019-05-25','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(5,'How do children see the world?','Children',DATE '2019-05-27',DATE '2019-05-28','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(6,'Look back at American history','History',DATE '2019-06-07',DATE '2019-06-11','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(7,'XXXXXXXXXX','Math',DATE '2019-06-12',DATE '2019-06-13','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(8,'XXXXXXXX','History',DATE '2019-07-07',DATE '2019-07-11','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(9,'XXXXXXXX','Art',DATE '2019-07-09',DATE '2019-07-14','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(10,'XXXXXXXX','History',DATE '2019-06-07',DATE '2019-06-11','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(11,'XXXXXXXX','Music',DATE '2019-08-07',DATE '2019-08-11','E')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(12,'XXXXXXXX','History',DATE '2019-08-12',DATE '2019-08-13','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(13,'XXXXXXXX','Arts',DATE '2019-10-07',DATE '2019-10-11','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(14,'XXXXXXXX','Children',DATE '2019-10-09',DATE '2019-10-13','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(15,'XXXXXXXX','Math',DATE '2019-10-15',DATE '2019-10-16','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(16,'XXXXXXXX','History',DATE '2019-10-16',DATE '2019-10-17','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(17,'XXXXXXXX','Photography',DATE '2019-10-17',DATE '2019-10-18','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(18,'XXXXXX','History',DATE '2019-10-18',DATE '2019-10-19','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(19,'XXXXXXX','Photography',DATE '2019-10-19',DATE '2019-10-20','S')
INTO EVENT(Event_ID,Event_NAME,Event_Topic,Start_Time,End_Time,Event_Type) VALUES(20,'XXXXXXXX','History',DATE '2019-11-07',DATE '2019-11-15','S')
SELECT * FROM dual;




INSERT ALL
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(1,'123@123.COM',12345678,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(2,'asndoiu24@123.COM',192837881,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(3,'asdhjku@123.COM',120195678,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(4,'asdlwqueD@123.COM',094172849,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(5,'DFG@123.COM',101947128,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(6,'ERT@123.COM',190128478,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(7,'98234JT@123.COM',123312938,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(8,'kasduon32@123.COM',193249012,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(9,'alskdui3@123.COM',184615478,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(10,'234890jsad@123.COM',190119462,'I')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(11,'asjdklwuqe@123.COM',190974318,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(12,'jienf676@123.COM',109345478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(13,'jisadhu2@123.COM',156738478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(14,'jasodiu3@123.COM',103726195,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(15,'sjdiui225@123.COM',153838478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(16,'herry222@123.COM',144338478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(17,'EsadT@123.COM',112338478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(18,'09asjewiur@123.COM',123838478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(19,'nasiodu8@123.COM',1092348478,'O')
INTO SPONSOR(Sponsor_ID,Sponsor_Email,Sponsor_Phone,Sponsor_Type) VALUES(20,'asndklsfui42@123.COM',1023138478,'O')
SELECT * FROM dual;



INSERT ALL
INTO SEMINAR(Event_ID) VALUES(3)
INTO SEMINAR(Event_ID) VALUES(5)
INTO SEMINAR(Event_ID) VALUES(12)
INTO SEMINAR(Event_ID) VALUES(13)
INTO SEMINAR(Event_ID) VALUES(14)
INTO SEMINAR(Event_ID) VALUES(15)
INTO SEMINAR(Event_ID) VALUES(16)
INTO SEMINAR(Event_ID) VALUES(17)
INTO SEMINAR(Event_ID) VALUES(18)
INTO SEMINAR(Event_ID) VALUES(19)
INTO SEMINAR(Event_ID) VALUES(20)
SELECT * FROM dual;




INSERT ALL
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(3,1,1000)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(5,2,2000)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(12,4,500)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(13,6,3000)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(14,5,1500)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(15,3,700)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(15,4,4000)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(15,11,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(16,16,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(16,20,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(17,17,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(18,9,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(18,13,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(19,13,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(20,2,2100)
INTO SEMINAR_SPONSOR(Event_ID,Sponsor_ID,Sponsor_Amount) VALUES(20,8,2100)
SELECT * FROM dual;




INSERT ALL
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(1,'Peter','Eason')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_MName,Sponsor_LName) VALUES(2,'Frank','Herbert','Jack')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(3,'Alex','Aaron')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(4,'Aggie','georgia')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(5,'Adelina','coral')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(6,'Peter','betsy')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(7,'Peter','Aggie')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(8,'betsy','Adelina')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(9,'coral','Eason')
INTO INDIVIDUAL(Sponsor_ID,Sponsor_FName,Sponsor_LName) VALUES(10,'georgia','Eason')
SELECT * FROM dual;





INSERT ALL
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(11,'ORG_A')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(12,'ORG_B')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(13,'ORG_C')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(14,'ORG_D')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(15,'ORG_E')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(16,'ORG_F')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(17,'ORG_G')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(18,'ORG_H')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(19,'ORG_I')
INTO ORGANIZATION(Sponsor_ID,Org_Name) VALUES(20,'ORG_J')
SELECT * FROM dual;



INSERT ALL
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(1,1,3)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(2,3,5)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(3,6,12)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(4,7,15)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(5,12,13)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(6,1,15)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(7,2,17)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(8,4,19)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(9,9,20)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(10,2,5)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(11,4,3)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(12,5,12)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(13,3,16)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(14,11,14)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(15,7,18)
INTO SEMINAR_ATTENDEE(invitation_id,Author_ID,Event_ID) VALUES(16,9,20)
SELECT * FROM dual;




INSERT ALL
INTO EXHIBITION(Event_ID) VALUES(1)
INTO EXHIBITION(Event_ID) VALUES(2)
INTO EXHIBITION(Event_ID) VALUES(4)
INTO EXHIBITION(Event_ID) VALUES(6)
INTO EXHIBITION(Event_ID) VALUES(7)
INTO EXHIBITION(Event_ID) VALUES(8)
INTO EXHIBITION(Event_ID) VALUES(9)
INTO EXHIBITION(Event_ID) VALUES(10)
INTO EXHIBITION(Event_ID) VALUES(11)
SELECT * FROM dual;





INSERT ALL
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(1,'Jack','Peter','Street A','City A','A',07302,'234@345.com',12456789,'P',123467)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(2,'Alex','Eason','Street B','City B','B',07513,'983@481.com',12996789,'P',0813794)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(3,'Mona','k','Street c','City c','c',09202,'ko3@345.com',09712739,'S',1297197)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(4,'Jack','Edison','Street d','City d','d',07912,'972@345.com',1818129,'D',0912478)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(5,'Frank','Dick','Street E','City E','E',91745,'90D@345.com',189127889,'P',1917237)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(6,'Jack','Peter','Street F','City F','F',07102,'JK3SN4@345.com',12812379,'S',9812767)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(7,'AAA','TTT','Street A','City A','A',09162,'9ASHDUB@345.com',29812389,'P',1612367)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(8,'Aaron','Peter','Street A','City A','A',07395,'koansd@345.com',19356789,'P',162365)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(9,'LLL','Eason','Street E','City A','A',05302,'2AJSKDUI4@345.com',1236789,'P',1212367)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(10,'LLL','Eason','Street E','City A','A',05302,'2AJSKDUI4@345.com',1236789,'P',1212367)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(11,'xxx','Pdfger','Street R','City A','T',03302,'KJASDI@345.com',1256789,'S',9123467)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(12,'xxx','Piwqor','Street R','City R','A',03342,'OIUAHYR@345.com',12523469,'D',9123467)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(13,'Jkas','sadsar','Street R','City F','B',91302,'OIUAYF@345.com',129182379,'P',9192467)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(14,'qjklaj','Peter','Street R','City A','C',60402,'OAKIHI@345.com',1252349629,'D',9123843)
INTO CUSTOMER(Cust_ID,Cust_FName,Cust_LName,Cust_Street,Cust_City,Cust_State,Cust_ZIP,Cust_Email,Cust_Phone,ID_Type,ID_Number) VALUES(15,'asdnqwur','psiojd','Street R','City A','A',94202,'KJFEADI@345.com',12234789,'D',9894267)

SELECT * FROM dual;





INSERT ALL
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(1,2,1)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(2,3,4)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(3,5,6)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(4,7,7)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(5,5,7)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(6,7,8)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(7,9,8)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(8,3,9)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(9,6,9)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(10,1,10)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(11,8,11)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(12,9,11)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(13,9,9)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(14,9,9)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(15,15,9)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(16,13,4)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(17,12,7)
INTO EXHIBITION_ATTENDEE(registration_id,Cust_ID,Event_ID) VALUES(18,11,8)
SELECT * FROM dual;





INSERT ALL
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(1,4000,'FOR XXX',1)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(2,2000,'FOR XXXX',1)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(3,4100,'FOR XX',1)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(4,9000,'FOR XXX',2)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(5,1300,'FOR XXX',2)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(6,4700,'FOR XXX',4)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(7,3600,'FOR XXX',4)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(8,4100,'FOR XXX',4)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(9,900,'FOR XXX',6)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(10,3000,'FOR XXX',6)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(11,2700,'FOR XXX',6)
INTO EXHIB_EXPENSE(Expense_ID,Expense_Amount,Expense_Descript,Event_ID) VALUES(12,3500,'FOR XXX',6)
SELECT * FROM dual;


INSERT ALL
INTO STUDY_ROOM(Room_id,Capacity) VALUES(1,2)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(2,2)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(3,2)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(4,3)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(5,3)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(6,3)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(7,4)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(8,4)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(9,6)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(10,6)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(11,8)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(12,8)
INTO STUDY_ROOM(Room_id,Capacity) VALUES(13,12)
SELECT * FROM dual;


INSERT ALL
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-03','08',1,2)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-04','11',3,10)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-04','01',12,2)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-05','08',2,4)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-05','01',9,7)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-05','04',5,4)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-06','08',13,9)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-06','11',12,3)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-07','08',9,1)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-08','08',4,7)
INTO ROOM_RESERVATION(Res_Date,Res_Timeslot,Room_Id,Cust_Id) VALUES(DATE'2019-02-09','11',7,5)
SELECT * FROM dual;



INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-08','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-01','O');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-23','O');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-22','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-09','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-10','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-11','O');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-12','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-13','O');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-14','C');
INSERT INTO RENTAL_INVOICE(Invoice_Date,Invoice_Status) VALUES(DATE'2019-02-27','O');




INSERT ALL
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(1,'B',DATE'2019-01-09',DATE'2019-02-09',1,2)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(2,'B',DATE'2019-01-21',DATE'2019-02-21',9,10)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(3,'B',DATE'2019-02-27',DATE'2019-03-27',3,6)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(4,'B',DATE'2019-01-20',DATE'2019-03-20',16,9)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(5,'L',DATE'2019-01-16',DATE'2019-02-16',14,3)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(6,'L',DATE'2019-01-02',DATE'2019-02-02',11,5)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(7,'L',DATE'2019-01-09',DATE'2019-02-09',7,6)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Copy_Id,Cust_id)VALUES(8,'L',DATE'2019-02-09',DATE'2019-03-09',5,4)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Return_Date,Copy_Id,Invoice_Id,Cust_id)VALUES(9,'R',DATE'2018-03-09',DATE'2018-04-09',DATE'2019-04-09',3,7,3)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Return_Date,Copy_Id,Invoice_Id,Cust_id)VALUES(10,'R',DATE'2018-04-09',DATE'2018-05-09',DATE'2019-05-09',2,8,1)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Return_Date,Copy_Id,Invoice_Id,Cust_id)VALUES(11,'R',DATE'2018-05-09',DATE'2018-06-09',DATE'2019-06-09',4,9,9)
INTO BOOK_RENTAL(Rental_Id,Rental_Status,Borrow_Date,Exp_Return_Date,Return_Date,Copy_Id,Invoice_Id,Cust_id)VALUES(12,'R',DATE'2018-06-09',DATE'2018-07-09',DATE'2019-07-09',8,10,7)
SELECT * FROM dual;



INSERT ALL
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(1,DATE'2019-02-08','PAYPAL',10,1)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(2,DATE'2019-02-01','CASH',30,1)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Card_FName,Card_LName,Invoice_Id) VALUES(3,DATE'2019-02-22','CREDIT CARD',100,'Peter','Jack',2)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Card_FName,Card_LName,Invoice_Id) VALUES(4,DATE'2019-02-22','CREDIT CARD',100,'Eason','Frank',3)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(5,DATE'2019-02-22','CREDIT CARD',5,3)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(6,DATE'2019-02-23','CASH',10,4)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(7,DATE'2019-02-09','CASH',20,5)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(8,DATE'2019-02-09','CASH',40,6)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(9,DATE'2019-02-09','CASH',13,7)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(10,DATE'2019-02-09','PAYPAL',15,8)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(11,DATE'2018-02-09','CASH',10,8)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(12,DATE'2018-02-09','CASH',30,9)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(13,DATE'2018-02-09','CASH',20,10)
INTO RENTAL_PAYMENT(Payment_Id,Payment_Date,Payment_Method,Payment_Amount,Invoice_Id) VALUES(14,DATE'2018-02-09','PAYPAL',20,11)
SELECT * FROM dual;



