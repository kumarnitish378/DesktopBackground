from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from flask import send_file
import sqlite3

app = Flask(__name__)
CORS(app)  # Allow all origins

def init_db():
    with sqlite3.connect("todos.db") as conn:
        conn.execute('''CREATE TABLE IF NOT EXISTS todos
                     (id INTEGER PRIMARY KEY AUTOINCREMENT,
                      task TEXT NOT NULL,
                      priority TEXT NOT NULL)''')
        
@app.route("/")
def index():
    # return render_template("index.html")
    return render_template("index.html", base_url=request.host_url)

@app.route("/todos", methods=["GET"])
def get_todos():
    with sqlite3.connect("todos.db") as conn:
        cursor = conn.execute("SELECT id, task, priority FROM todos")
        todos = [{"id": row[0], "task": row[1], "priority": row[2]} for row in cursor.fetchall()]
    return jsonify(todos)

@app.route("/todos", methods=["POST"])
def add_todo():
    data = request.get_json()
    with sqlite3.connect("todos.db") as conn:
        conn.execute("INSERT INTO todos (task, priority) VALUES (?, ?)", (data["task"], data.get("priority", "normal")))
    return jsonify({"status": "added"}), 201

@app.route("/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    with sqlite3.connect("todos.db") as conn:
        cursor = conn.execute("DELETE FROM todos WHERE id = ?", (todo_id,))
        if cursor.rowcount:
            return jsonify({"status": "deleted"})
    return jsonify({"error": "not found"}), 404


@app.route('/template.jpg')
def get_image():
    return send_file('2.png', mimetype='image/jpeg')


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
