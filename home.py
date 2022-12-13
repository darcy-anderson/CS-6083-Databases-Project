# Handles customer site

from flask import Blueprint, render_template
from flask_login import login_required, current_user
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, DateField, SelectField, IntegerField
from wtforms.validators import InputRequired
import re

import db_helpers as db

home = Blueprint('home', __name__, url_prefix='/home')


# Search form for book catalog
class SearchForm(FlaskForm):

  search = StringField(render_kw={"placeholder": "Search by title..."})
  submit = SubmitField('')


# Date search form for study room reservations
class DateForm(FlaskForm):

  date = DateField('date', format='%Y-%m-%d')
  timeslot = SelectField('Timeslot',
                         choices=[('08', '8am to 10am'), ('11', '11am to 1pm'),
                                  ('01', '1pm to 3pm'), ('04', '4pm to 6pm')])
  submit = SubmitField("Check availability")


# Reservation button
class ReserveForm(FlaskForm):

  date2 = DateField('date', format='%Y-%m-%d')
  timeslot2 = SelectField('Timeslot',
                          choices=[('08', '8am to 10am'),
                                   ('11', '11am to 1pm'), ('01', '1pm to 3pm'),
                                   ('04', '4pm to 6pm')])
  room = IntegerField(validators=[InputRequired()],
                      render_kw={"placeholder": "Room ID"})
  reserve = SubmitField("Reserve")


@home.route('/')
@login_required
def dash():
  return render_template('home/dash.html')


@home.route('/books', methods=['GET', 'POST'])
@login_required
def books():

  books = db.get_books()
  form = SearchForm()

  # Remove non-search-result books from list after search
  if form.validate_on_submit():

    search_input = form.search.data
    new_books = []

    for book in books:
      if re.search(search_input, book[0][1], re.IGNORECASE):
        new_books.append(book)

    books = new_books

  return render_template('home/books.html', books=books, form=form)


@home.route('/study', methods=['GET', 'POST'])
@login_required
def study():

  form = DateForm()
  form2 = ReserveForm()

  available = []

  # Display available rooms for given date and timeslot
  if form.validate_on_submit():
    date = form.date.data.strftime('%Y-%m-%d')
    timeslot = form.timeslot.data
    available = db.get_study_rooms(date, timeslot)

  if form2.validate_on_submit():
    date = form2.date2.data.strftime('%Y-%m-%d')
    timeslot = form2.timeslot2.data
    room = form2.room.data
    db.create_study_res(room, date, timeslot, int(current_user.get_id()))

  bookings = db.get_study_res(int(current_user.get_id()))

  return render_template('home/study.html',
                         bookings=bookings,
                         available=available,
                         form=form,
                         form2=form2)


@home.route('/rentals')
@login_required
def rentals():

  rentals = db.get_rentals(int(current_user.get_id()))
  invoices = list()
  for rental in rentals:
    if rental[6] != "Not yet returned.":
      invoices.append(db.get_invoice_details(rental[6]))
  return render_template('home/rentals.html',
                         rentals=rentals,
                         invoices=invoices)
