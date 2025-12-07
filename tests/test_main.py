import unittest
import os
import json
from main import app, init_db

class DesktopBackgroundTestCase(unittest.TestCase):
    def setUp(self):
        # Configure app for testing
        app.config['TESTING'] = True
        self.app = app.test_client()
        self.db_name = "test_todos.db"
        
        # Patch the database filename in main.py logic (if it weren't hardcoded)
        # Since it's hardcoded to 'todos.db' in main.py, we have to be careful.
        # Ideally main.py should accept a config. For now, we test the endpoints 
        # knowing it might create a local DB.
        
        init_db()

    def test_index(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_auth_and_todos(self):
        # 1. Register
        rv = self.app.post('/register', data=dict(username='testuser', password='password'))
        self.assertEqual(rv.status_code, 302) # Redirects to login
        
        # 2. Login
        with self.app as c:
            rv = c.post('/login', data=dict(username='testuser', password='password'))
            self.assertEqual(rv.status_code, 302) # Redirects to index
            self.assertIn('user_id', session)
            
            # 3. Add Todo (Authenticated via Session)
            rv = c.post('/todos', 
                       data=json.dumps({"task": "Test Task", "priority": "high"}),
                       content_type='application/json')
            self.assertEqual(rv.status_code, 201)
            
            # 4. Get Todo (Authenticated via Session)
            rv = c.get('/todos')
            data = json.loads(rv.data)
            self.assertEqual(len(data), 1)
            self.assertEqual(data[0]['task'], "Test Task")
            
    def test_api_access(self):
        # Register to get API Key (mocking DB access to get it)
        try:
            os.remove(self.db_name)
        except OSError:
            pass
        init_db()
        
        with self.app as c:
             c.post('/register', data=dict(username='apiuser', password='password'))
             # Manually fetch API key since we can't scrape it easily from HTML in unit test
             import sqlite3
             with sqlite3.connect("todos.db") as conn:
                 cursor = conn.execute("SELECT api_key FROM users WHERE username='apiuser'")
                 api_key = cursor.fetchone()[0]
        
        # Access with Header
        rv = self.app.get('/todos', headers={'X-API-KEY': api_key})
        self.assertEqual(rv.status_code, 200)
        
        # Access without Header
        rv = self.app.get('/todos')
        self.assertEqual(rv.status_code, 401)

if __name__ == '__main__':
    unittest.main()
