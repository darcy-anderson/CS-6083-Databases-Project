from flask import Blueprint, render_template
from flask_login import login_required
from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, EmailField, SubmitField, SelectField, DateField
from wtforms.validators import InputRequired, Length

import db_helpers as db

admin = Blueprint('admin', __name__, url_prefix='/admin')


class AuthorEntryForm(FlaskForm):

  id = IntegerField(validators=[InputRequired()],
                    render_kw={"placeholder": "Author ID"})
  fname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "First Name"})
  mname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "Middle Name"})
  lname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "Last Name"})
  street = StringField(validators=[Length(min=0, max=30)],
                       render_kw={"placeholder": "Street"})
  city = StringField(validators=[Length(min=0, max=30)],
                     render_kw={"placeholder": "City"})
  state = StringField(validators=[Length(min=0, max=2)],
                      render_kw={"placeholder": "State"})
  zip = StringField(validators=[Length(min=0, max=5)],
                    render_kw={"placeholder": "Zipcode"})
  email = EmailField(validators=[Length(min=0, max=30)],
                     render_kw={"placeholder": "Email Address"})
  submit = SubmitField("Submit")


class CustomerEntryForm(FlaskForm):

  id = IntegerField(validators=[InputRequired()],
                    render_kw={"placeholder": "Customer ID"})
  fname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "First Name"})
  mname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "Middle Name"})
  lname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "Last Name"})
  street = StringField(validators=[Length(min=0, max=30)],
                       render_kw={"placeholder": "Street"})
  city = StringField(validators=[Length(min=0, max=30)],
                     render_kw={"placeholder": "City"})
  state = StringField(validators=[Length(min=0, max=2)],
                      render_kw={"placeholder": "State"})
  zip = StringField(validators=[Length(min=0, max=5)],
                    render_kw={"placeholder": "Zipcode"})
  email = EmailField(validators=[Length(min=0, max=30)],
                     render_kw={"placeholder": "Email Address"})
  phone = StringField(validators=[Length(min=0, max=10)],
                      render_kw={"placeholder": "Phone Number"})
  id_type = SelectField('ID Type',
                        choices=[('', ''), ('P', 'Passport'),
                                 ('S', 'Social Security'),
                                 ('D', "Driver's License")])
  id_no = StringField(validators=[Length(min=0, max=10)],
                      render_kw={"placeholder": "ID Number"})
  submit = SubmitField("Submit")


class StudyDeleteForm(FlaskForm):

  date = DateField('date', validators=[InputRequired()], format='%Y-%m-%d')
  timeslot = SelectField('timeslot',
                         validators=[InputRequired()],
                         choices=[('08', '8-10'), ('11', '11-1'),
                                  ('01', "1-3"), ('04', "4-6")])
  room_id = IntegerField(validators=[InputRequired()],
                         render_kw={"placeholder": "Room ID"})
  submit = SubmitField("Delete")


class RentalReturnForm(FlaskForm):

  rental_id = IntegerField(validators=[InputRequired()],
                           render_kw={"placeholder": "Rental ID"})
  submit = SubmitField("Return")


@admin.route('/')
@login_required
def dash():
  return render_template('admin/dash.html')


@admin.route('/authors', methods=['GET', 'POST'])
@login_required
def authors():

  form = AuthorEntryForm()

  if form.validate_on_submit():
    author_info = [
        form.id.data, form.fname.data, form.mname.data, form.lname.data,
        form.street.data, form.city.data, form.state.data, form.zip.data,
        form.email.data
    ]
    if not db.author_exists(author_info[0]):
      db.create_author(author_info)
    else:
      db.update_author(author_info)

  authors = db.get_authors()

  return render_template('admin/authors.html', authors=authors, form=form)


@admin.route('/customers', methods=['GET', 'POST'])
@login_required
def customers():

  form = CustomerEntryForm()

  if form.validate_on_submit():
    cust_info = [
        form.id.data, form.fname.data, form.mname.data, form.lname.data,
        form.street.data, form.city.data, form.state.data, form.zip.data,
        form.email.data, form.phone.data, form.id_type.data, form.id_no.data
    ]
    db.update_customer(cust_info)

  customers = db.get_customers()

  return render_template('admin/customers.html',
                         customers=customers,
                         form=form)


@admin.route('/study', methods=['GET', 'POST'])
@login_required
def study():

  form = StudyDeleteForm()

  if form.validate_on_submit():
    date = form.date.data.strftime('%Y-%m-%d')
    db.delete_study_res(date, form.timeslot.data, form.room_id.data)

  bookings = db.get_all_study_res()

  return render_template('admin/study.html',
                         customers=customers,
                         form=form,
                         bookings=bookings)


@admin.route('/rentals', methods=['GET', 'POST'])
@login_required
def rentals():

  form = RentalReturnForm()

  if form.validate_on_submit():
    db.return_rental(form.rental_id.data)

  rentals = db.get_all_rentals()

  return render_template('admin/rentals.html', rentals=rentals, form=form)
