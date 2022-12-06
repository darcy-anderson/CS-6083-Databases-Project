from flask import Flask, render_template, url_for, redirect, flash
import oracledb
from flask_login import UserMixin, login_user, LoginManager, login_required, logout_user, current_user
from flask_wtf import FlaskForm
from flask_bcrypt import Bcrypt
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import InputRequired, Length, ValidationError

# Configure flask
app = Flask(__name__)
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


# User loaded for flask_login, called every time new page is visited
@login_manager.user_loader
def load_user(id):

  id = int(id)
  sql = "select * from web_user where user_id=:num"
  user_data = cur.execute(sql, num=id).fetchone()
  return User(user_data[0], user_data[1], user_data[3])


class RegisterForm(FlaskForm):

  username = StringField(validators=[InputRequired(),
                                     Length(min=4, max=20)],
                         render_kw={"placeholder": "Username"})
  password = PasswordField(validators=[InputRequired(),
                                       Length(min=4, max=20)],
                           render_kw={"placeholder": "Password"})
  checkbox = BooleanField("Are you you an employee?")
  submit = SubmitField("Register")

  def validate_username(self, username):
    sql = "select * from web_user where usrname=:usr"
    cur.execute(sql, usr=username.data)
    cur.fetchall()
    if cur.rowcount > 0:
      flash('That username already exists. Please pick a different username.')
      raise ValidationError("That username already exists.")


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
    return redirect(url_for('home'))

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
    return redirect(url_for('home'))

  return render_template('login.html', form=form)


@app.route('/logout')
def logout():
  logout_user()
  return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST'])
def register():
  form = RegisterForm()

  if form.validate_on_submit():
    user = form.username.data
    hash_pass = bcrypt.generate_password_hash(form.password.data)
    if form.checkbox.data:
      emp = 'E'
    else:
      emp = 'C'
    sql = "insert into web_user (usrname, password, type) values (:u, :p, :e)"
    cur.execute(sql, u=user, p=hash_pass, e=emp)
    return redirect(url_for('login'))

  return render_template('register.html', form=form)


@app.route('/home', methods=['GET', 'POST'])
@login_required
def home():
  return render_template('home.html')


if __name__ == '__main__':
  app.run(debug=True)