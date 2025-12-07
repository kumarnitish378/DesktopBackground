from flask import Flask, request, jsonify, render_template, session, redirect, url_for, send_file
from flask_cors import CORS
import sqlite3
import uuid
import os
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = os.urandom(24) # Secret key for sessions
CORS(app)

def get_db_path():
    return app.config.get('DATABASE', 'todos.db')

def init_db():
    with sqlite3.connect(get_db_path()) as conn:
        # Create Users Table
        conn.execute('''CREATE TABLE IF NOT EXISTS users
                     (id INTEGER PRIMARY KEY AUTOINCREMENT,
                      username TEXT NOT NULL UNIQUE,
                      password TEXT NOT NULL,
                      api_key TEXT NOT NULL UNIQUE)''')
        
        # Create Todos Table with foreign key
        conn.execute('''CREATE TABLE IF NOT EXISTS todos
                     (id INTEGER PRIMARY KEY AUTOINCREMENT,
                      task TEXT NOT NULL,
                      priority TEXT NOT NULL,
                      user_id INTEGER NOT NULL,
                      FOREIGN KEY(user_id) REFERENCES users(id))''')

@app.route("/")
def index():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    # Fetch user's API key
    with sqlite3.connect(get_db_path()) as conn:
        cursor = conn.execute("SELECT api_key FROM users WHERE id = ?", (session['user_id'],))
        row = cursor.fetchone()
        api_key = row[0] if row else "Error"

    return render_template("index.html", base_url=request.host_url, api_key=api_key)

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form['username']
        password = request.form['password']
        
        with sqlite3.connect(get_db_path()) as conn:
            cursor = conn.execute("SELECT id, password FROM users WHERE username = ?", (username,))
            user = cursor.fetchone()
            
            if user and check_password_hash(user[1], password):
                session['user_id'] = user[0]
                return redirect(url_for('index'))
            
            return render_template("login.html", error="Invalid credentials")
            
    return render_template("login.html")

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form['username']
        password = request.form['password']
        api_key = str(uuid.uuid4())
        hashed_pw = generate_password_hash(password)
        
        try:
            with sqlite3.connect(get_db_path()) as conn:
                conn.execute("INSERT INTO users (username, password, api_key) VALUES (?, ?, ?)", 
                             (username, hashed_pw, api_key))
            return redirect(url_for('login'))
        except sqlite3.IntegrityError:
            return render_template("login.html", error="Username already exists")
            
    return render_template("login.html")

@app.route("/logout")
def logout():
    session.pop('user_id', None)
    return redirect(url_for('login'))

@app.route("/todos", methods=["GET"])
def get_todos():
    user_id = None
    
    # 1. Check Session (Web UI)
    if 'user_id' in session:
        user_id = session['user_id']
    
    # 2. Check API Key (PowerShell Client)
    elif 'X-API-KEY' in request.headers:
        api_key = request.headers['X-API-KEY']
        with sqlite3.connect(get_db_path()) as conn:
            cursor = conn.execute("SELECT id FROM users WHERE api_key = ?", (api_key,))
            row = cursor.fetchone()
            if row:
                user_id = row[0]
    
    if user_id is None:
        return jsonify({"error": "Unauthorized"}), 401

    with sqlite3.connect(get_db_path()) as conn:
        cursor = conn.execute("SELECT id, task, priority FROM todos WHERE user_id = ?", (user_id,))
        todos = [{"id": row[0], "task": row[1], "priority": row[2]} for row in cursor.fetchall()]
    return jsonify(todos)

@app.route("/todos", methods=["POST"])
def add_todo():
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401
        
    data = request.get_json()
    with sqlite3.connect(get_db_path()) as conn:
        conn.execute("INSERT INTO todos (task, priority, user_id) VALUES (?, ?, ?)", 
                     (data["task"], data.get("priority", "normal"), session['user_id']))
    return jsonify({"status": "added"}), 201

@app.route("/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    if 'user_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    with sqlite3.connect(get_db_path()) as conn:
        cursor = conn.execute("DELETE FROM todos WHERE id = ? AND user_id = ?", (todo_id, session['user_id']))
        if cursor.rowcount:
            return jsonify({"status": "deleted"})
    return jsonify({"error": "not found"}), 404

@app.route('/template.jpg')
def get_image():
    # Public route, but could be authenticated if desired
    return send_file('assets/template.png', mimetype='image/jpeg')

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
