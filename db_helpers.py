# TODO: create_study_res() doesnt work, bind variable error

import oracledb

# Establish connection to database server
try:
  db = oracledb.connect(user="danderson",
                        password="1234wasd",
                        dsn="localhost/ORCL")
  db.autocommit = True
  cur = db.cursor()
except oracledb.DatabaseError as e:
  print("There is a problem with Oracle", e)


# Return list of all books with authors and number of copies
def get_books():
  cur.execute("select * from book order by book_title asc")
  books = cur.fetchall()
  # Add authors to each book
  for i in range(len(books)):
    authors = get_book_authors(books[i][0])
    # Concatenate author names
    for j in range(len(authors)):
      if authors[j][1]:
        mname = authors[j][1]
      else:
        mname = ""
      if not authors[j][2] == 'Unknown':
        lname = authors[j][2]
      else:
        lname = ""
      authors[j] = f'{authors[j][0]} {mname} {lname}'
    authors = ', '.join(authors)
    copies = get_book_copies(books[i][0])
    books[i] = (books[i], authors, copies)
  return books


# Find authors for a given book
def get_book_authors(book_id):
  sql = """select c.author_fname, c.author_mname, c.author_lname
           from book a full join book_author b on a.book_id = b.book_id
           full join author c on b.author_id = c.author_id
           where a.book_id = :book_id"""
  cur.execute(sql, book_id=book_id)
  return cur.fetchall()


# Find number of available copies for a given book
def get_book_copies(book_id):
  sql = """select b.copy_id
           from book a full join book_copy b on a.book_id = b.book_id
           where a.book_id = :book_id and b.copy_status = 'A'"""
  cur.execute(sql, book_id=book_id)
  return len(cur.fetchall())


# Find available study rooms for given timeslot (date string in yyyy-mm-dd format)
def get_study_rooms(res_date, timeslot):
  print(res_date, timeslot)
  sql = """select room_id, capacity from study_room where room_id not in
              (select a.room_id 
              from study_room a left join room_reservation b on a.room_id = b.room_id
              where b.res_timeslot = :timeslot and trunc(b.res_date) = to_date(:res_date, 'yyyy/mm/dd') )"""
  cur.execute(sql, timeslot=timeslot, res_date=res_date)
  rooms = cur.fetchall()
  return rooms


# Find existing reservations for given user
def get_study_res(user_id):
  sql = 'select cust_id from customer where user_id = :user_id'
  cust_id = cur.execute(sql, user_id=user_id).fetchone()[0]
  sql = """select a.res_date, a.res_timeslot, a.room_id, b.capacity
           from room_reservation a left join study_room b on a.room_id = b.room_id
           where cust_id = :cust_id"""
  cur.execute(sql, cust_id=cust_id)
  bookings = cur.fetchall()
  # Convert dates from datetime to string
  for i in range(len(bookings)):
    date_string = bookings[i][0].strftime('%Y-%m-%d')
    if (bookings[i][1] == '08'):
      timeslot_full = '8am to 10am'
    elif (bookings[i][1] == '11'):
      timeslot_full = '11am to 1pm'
    elif (bookings[i][1] == '01'):
      timeslot_full = '1pm to 3pm'
    else:
      timeslot_full = '4pm to 6pm'
    bookings[i] = (date_string, timeslot_full, bookings[i][2], bookings[i][3])
  print(bookings)
  return bookings


def get_all_study_res():
  sql = """select a.*, b.cust_fname, b.cust_lname, b.cust_phone
           from room_reservation a left join customer b on a.cust_id = b.cust_id
           order by a.res_date"""
  bookings = cur.execute(sql).fetchall()
  bookings = list(bookings)
  for i in range(len(bookings)):
    bookings[i] = list(bookings[i])
    bookings[i][0] = bookings[i][0].strftime('%Y-%m-%d')
  return bookings


# Create new reservation for given room, date, timeslot, and user
def create_study_res(room_id, date, timeslot, user_id):
  sql = 'select cust_id from customer where user_id = :user_id'
  cust_id = cur.execute(sql, user_id=user_id).fetchone()[0]
  sql = "insert into room_reservation values (to_date(:res_date, 'yyyy/mm/dd'), :timeslot, :room_id, :cust_id)"
  cur.execute(sql,
              res_date=date,
              timeslot=timeslot,
              room_id=room_id,
              cust_id=cust_id)


def delete_study_res(res_date, timeslot, room_id):
  sql = """delete from room_reservation where res_date=to_date(:res_date, 'yyyy/mm/dd') and res_timeslot=:timeslot and room_id=:room_id"""
  cur.execute(sql, [res_date, timeslot, room_id])


def get_authors():
  authors = cur.execute("select * from author").fetchall()
  authors = list(authors)
  for i in range(len(authors)):
    authors[i] = list(authors[i])
    if authors[i][2] == None:
      authors[i][2] = '-'
    if authors[i][4] == None:
      authors[i][4] = '-'
    if authors[i][5] == None:
      authors[i][5] = '-'
    if authors[i][6] == None:
      authors[i][6] = '-'
    if authors[i][7] == None:
      authors[i][7] = '-'
    if authors[i][8] == None:
      authors[i][8] = '-'
  return authors


def author_exists(author_id):
  sql = 'select * from author where author_id = :author_id'
  row = cur.execute(sql, author_id=author_id).fetchone()
  if row:
    return True
  else:
    return False


def create_author(author_info):
  for item in author_info:
    if item == "":
      item = None
  a = author_info
  sql = """insert into author values (:a,:b,:c,:d,:e,:f,:g,:h,:i)"""
  cur.execute(sql, [a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]])


def update_author(author_info):
  current_info = cur.execute('select * from author where author_id=:id',
                             id=author_info[0]).fetchone()
  for i in range(len(author_info)):
    if author_info[i] == "":
      author_info[i] = current_info[i]
  a = author_info
  sql = """update author set author_fname=:a,author_mname=:b,author_lname=:c,
           author_street=:d,author_city=:e,author_state=:f,
           author_zip=:g,author_email=:h
           where author_id=:id"""
  cur.execute(sql, [a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[0]])


def get_customers():
  customers = cur.execute(
      "select a.*, b.usrname from customer a left join web_user b on a.user_id = b.user_id"
  ).fetchall()
  customers = list(customers)
  for i in range(len(customers)):
    customers[i] = list(customers[i])
    if customers[i][2] == None:
      customers[i][2] = '-'
  return customers


def update_customer(cust_info):
  current_info = cur.execute('select * from customer where cust_id=:id',
                             id=cust_info[0]).fetchone()
  for i in range(len(cust_info)):
    if cust_info[i] == "":
      cust_info[i] = current_info[i]
  a = cust_info
  sql = """update customer set cust_fname=:a,cust_mname=:b,cust_lname=:c,
           cust_street=:d,cust_city=:e,cust_state=:f,
           cust_zip=:g,cust_email=:h,cust_phone=:i,id_type=:j,id_number=:j
           where cust_id=:id"""
  cur.execute(sql, [
      a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[0]
  ])


def get_rentals(user_id):
  sql = 'select cust_id from customer where user_id = :user_id'
  cust_id = cur.execute(sql, user_id=user_id).fetchone()[0]
  sql = """select a.rental_id, a.rental_status, a.borrow_date, a.exp_return_date,
           c.book_title, a.return_date, d.invoice_id
           from book_rental a left join book_copy b on a.copy_id = b.copy_id
           left join book c on b.book_id = c.book_id
           left join rental_invoice d on a.rental_id = d.rental_id
           where a.cust_id = :cust_id
           """
  rentals = cur.execute(sql, cust_id=cust_id).fetchall()
  rentals = list(rentals)
  for i in range(len(rentals)):
    rentals[i] = list(rentals[i])
    rentals[i][2] = rentals[i][2].strftime('%Y-%m-%d')
    rentals[i][3] = rentals[i][3].strftime('%Y-%m-%d')
    if rentals[i][1] == 'B':
      rentals[i][1] = 'On time.'
    if rentals[i][1] == 'L':
      rentals[i][1] = 'Late. '
    if rentals[i][1] == 'R':
      rentals[i][1] = 'Returned.'
    if rentals[i][5]:
      rentals[i][5] = rentals[i][5].strftime('%Y-%m-%d')
    else:
      rentals[i][5] = "Not yet returned."
    if not rentals[i][6]:
      rentals[i][6] = "Not yet returned."
  return rentals


def get_all_rentals():
  sql = """select a.rental_id, a.rental_status, a.borrow_date, a.exp_return_date, a.return_date, a.copy_id, e.invoice_id, a.cust_id, c.book_title, d.cust_fname,  d.cust_lname, d.cust_phone
           from book_rental a left join book_copy b on a.copy_id = b.copy_id
           left join book c on b.book_id = c.book_id
           left join customer d on a.cust_id = d.cust_id
           left join rental_invoice e on a.rental_id = e.rental_id
           order by a.borrow_date"""
  rentals = cur.execute(sql).fetchall()
  rentals = list(rentals)
  for i in range(len(rentals)):
    rentals[i] = list(rentals[i])
    rentals[i][2] = rentals[i][2].strftime('%Y-%m-%d')
    rentals[i][3] = rentals[i][3].strftime('%Y-%m-%d')
    if rentals[i][4] != None:
      rentals[i][4] = rentals[i][4].strftime('%Y-%m-%d')
    else:
      rentals[i][4] = '-'
    if rentals[i][6] == None:
      rentals[i][6] = '-'
  return rentals


def return_rental(rental_id):
  sql = "update book_rental set rental_status = 'R', return_date = sysdate where rental_id = :rental_id"
  cur.execute(sql, rental_id=rental_id)


def get_invoice_details(invoice_id):
  sql = "select * from rental_invoice where invoice_id = :invoice_id"
  invoice = cur.execute(sql, invoice_id=invoice_id).fetchone()
  invoice = list(invoice)
  invoice[1] = invoice[1].strftime('%Y-%m-%d')
  if invoice[2] == 'O':
    invoice[2] = 'Open - Not Fully Paid'
  else:
    invoice[2] = 'Closed - Fully Paid'
  return invoice