from flask import Blueprint, render_template
from flask_login import login_required
import oracledb

home = Blueprint('home', __name__, url_prefix='/home')

# Establish connection to database server
try:
  db = oracledb.connect(user="danderson",
                        password="1234wasd",
                        dsn="localhost/ORCL")
  db.autocommit = True
  cur = db.cursor()
except oracledb.DatabaseError as e:
  print("There is a problem with Oracle", e)


@home.route('/', methods=['GET', 'POST'])
@login_required
def dash():
  return render_template('dash.html')


@home.route('/books', methods=['GET', 'POST'])
@login_required
def books():
  sql = "select * from book"
  cur.execute(sql)