from flask import Flask, render_template, url_for, redirect, flash
import oracledb
from flask_login import login_user, LoginManager, logout_user, current_user
from flask_wtf import FlaskForm
from flask_bcrypt import Bcrypt
from wtforms import StringField, PasswordField, SubmitField, EmailField, SelectField
from wtforms.validators import InputRequired, Length, ValidationError

from home import home

# Configure flask
app = Flask(__name__)
app.register_blueprint(home)
app.secret_key = '43d23d8ceafbba0828658a49072098379701a5635b9d0b7abe1478f07921c2c2'

# Establish connection to database server
try:
  db = oracledb.connect(user="danderson",
                        password="1234wasd",
                        dsn="localhost/ORCL")
  db.autocommit = True
  cur = db.cursor()
except oracledb.DatabaseError as e:
  print("There is a problem with Oracle", e)

# Configure login manager
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "/login"
bcrypt = Bcrypt(app)


# User object for flask_login
class User():

  def __init__(self, id, username, type, active=True):
    self.id = id
    self.username = username
    self.type = type
    self.active = active

  def is_active(self):
    return self.active

  def is_anonymouse(self):
    return False

  def is_authenticated(self):
    return True

  def get_id(self):
    return str(self.id)

  def get_username(self):
    return self.username


# User loader for flask_login, called every time new page is visited
@login_manager.user_loader
def load_user(id):

  id = int(id)
  sql = "select * from web_user where user_id=:num"
  user_data = cur.execute(sql, num=id).fetchone()
  return User(user_data[0], user_data[1], user_data[3])


# Form for registration page
class RegisterForm(FlaskForm):

  username = StringField(validators=[InputRequired(),
                                     Length(min=4, max=20)],
                         render_kw={"placeholder": "Username"})
  password = PasswordField(validators=[InputRequired(),
                                       Length(min=4, max=20)],
                           render_kw={"placeholder": "Password"})
  fname = StringField(validators=[InputRequired(),
                                  Length(min=3, max=30)],
                      render_kw={"placeholder": "First Name"})
  mname = StringField(validators=[Length(min=0, max=30)],
                      render_kw={"placeholder": "Middle Name"})
  lname = StringField(validators=[InputRequired(),
                                  Length(min=3, max=30)],
                      render_kw={"placeholder": "Last Name"})
  street = StringField(validators=[InputRequired(),
                                   Length(min=3, max=30)],
                       render_kw={"placeholder": "Street"})
  city = StringField(validators=[InputRequired(),
                                 Length(min=3, max=30)],
                     render_kw={"placeholder": "City"})
  state = StringField(validators=[InputRequired(),
                                  Length(min=2, max=2)],
                      render_kw={"placeholder": "State"})
  zip = StringField(validators=[InputRequired(),
                                Length(min=5, max=5)],
                    render_kw={"placeholder": "Zipcode"})
  email = EmailField(validators=[InputRequired(),
                                 Length(min=3, max=30)],
                     render_kw={"placeholder": "Email Address"})
  phone = StringField(validators=[InputRequired(),
                                  Length(min=10, max=10)],
                      render_kw={"placeholder": "Phone Number"})
  id_type = SelectField('ID Type',
                        choices=[('P', 'Passport'), ('S', 'Social Security'),
                                 ('D', "Driver's License")])
  id_no = StringField(validators=[InputRequired(),
                                  Length(min=3, max=10)],
                      render_kw={"placeholder": "ID Number"})
  submit = SubmitField("Register")

  def validate_username(self, username):
    sql = "select * from web_user where usrname=:usr"
    cur.execute(sql, usr=username.data)
    cur.fetchall()
    if cur.rowcount > 0:
      flash('That username already exists. Please pick a different username.')
      raise ValidationError("That username already exists.")


# Form for login page
class LoginForm(FlaskForm):

  username = StringField(validators=[InputRequired(),
                                     Length(min=4, max=20)],
                         render_kw={"placeholder": "Username"})
  password = PasswordField(validators=[InputRequired(),
                                       Length(min=4, max=20)],
                           render_kw={"placeholder": "Password"})
  submit = SubmitField("Sign In")


@app.route('/')
def index():
  return render_template('index.html')


@app.route('/login', methods=['GET', 'POST'])
def login():

  # Incase already logged in user navigates to login page
  if current_user.is_authenticated:
    return redirect(url_for('home.dash'))

  form = LoginForm()
  if form.validate_on_submit():

    # Query database to find data for entered username
    sql = "select * from web_user where usrname=:usr"
    user_data = cur.execute(sql, usr=form.username.data).fetchone()

    # If user doesn't exist or password is incorrect, flash message
    if not user_data or not bcrypt.check_password_hash(user_data[2],
                                                       form.password.data):
      flash('Invalid username or password.')
      return redirect(url_for('login'))

    user = User(user_data[0], user_data[1], user_data[3])
    login_user(user)
    db.close()
    return redirect(url_for('home.dash'))

  return render_template('login.html', form=form)


@app.route('/logout')
def logout():
  logout_user()
  return redirect(url_for('index'))


@app.route('/register', methods=['GET', 'POST'])
def register():
  form = RegisterForm()

  if form.validate_on_submit():
    # Insert new web user to db
    user = form.username.data
    hash_pass = bcrypt.generate_password_hash(form.password.data)
    emp = 'C'
    sql = "insert into web_user (usrname, password, type) values (:u, :p, :e)"
    cur.execute(sql, u=user, p=hash_pass, e=emp)

    # Insert new associated customer to db
    sql = "select user_id from web_user where usrname=:u"
    cur.execute(sql, u=user)
    user_id = cur.fetchone()[0]
    user_data = [
        form.fname.data, form.mname.data, form.lname.data, form.street.data,
        form.city.data, form.state.data, form.zip.data, form.email.data,
        form.phone.data, form.id_type.data, form.id_no.data, user_id
    ]
    sql = "insert into customer (cust_fname,cust_mname,cust_lname,cust_street,cust_city,cust_state,cust_zip,cust_email,cust_phone,id_type,id_number,user_id) values (:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l)"
    cur.execute(sql,
                a=user_data[0],
                b=user_data[1],
                c=user_data[2],
                d=user_data[3],
                e=user_data[4],
                f=user_data[5],
                g=user_data[6],
                h=user_data[7],
                i=user_data[8],
                j=user_data[9],
                k=user_data[10],
                l=user_data[11])
    return redirect(url_for('login'))

  return render_template('register.html', form=form)


if __name__ == '__main__':
  app.run(debug=True)