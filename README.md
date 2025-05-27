Here is a complete README.md for your project:

````markdown
# Dynamic Wallpaper with TODO List

This project creates a dynamic desktop wallpaper that fetches TODO items from a Python Flask server, writes them on a custom wallpaper image, and sets it as the desktop background automatically.

---

## Features

- Python Flask server with SQLite to add/delete TODO items via a web UI.
- PowerShell script fetches TODOs from the server and updates the wallpaper.
- Customizable wallpaper template with text and shadow effects.
- Runs automatically at system startup.

---

## Setup

### Server Side (Python Flask)

1. Install Python dependencies:
   ```bash
   pip install flask flask-cors flask-sqlalchemy
````

2. Run the Flask app:

   ```bash
   python app.py
   ```
3. Access the web UI at `http://localhost:5000` to add/delete TODOs.

---

### Client Side (PowerShell Script)

1. Edit `webBasedWallPaper.ps1` script:

   * Set `$apiUrl` to your server address (e.g., `http://localhost:5000/todos`).
   * Set `$inputImage` to your wallpaper template path.
   * Set `$outputImage` to the desired output wallpaper path.

2. Run the script manually to test:

   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\webBasedWallPaper.ps1"
   ```

3. Add the script to run at system startup:

#### Option 1: Startup Folder

* Press `Win + R`, type `shell:startup`, press Enter.
* Add a shortcut with target:

  ```
  powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\webBasedWallPaper.ps1"
  ```

#### Option 2: Task Scheduler

* Open Task Scheduler → Create Task.
* Set trigger to “At log on”.
* Set action to run:

  ```
  powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\webBasedWallPaper.ps1"
  ```
* Save and exit.

---

## How it works

* Flask server holds TODO list in SQLite.
* PowerShell script fetches TODO JSON from Flask API.
* Script writes TODO text on wallpaper image with shadow.
* Sets new wallpaper as desktop background.
* Runs automatically at login or manually.

---

## Customization

* Change fonts, colors, shadow effects in the PowerShell script.
* Modify Flask templates for a different UI.
* Change wallpaper template image.

---

## Troubleshooting

* Make sure PowerShell execution policy allows running scripts:

  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
* Confirm Flask server is running and accessible from the client machine.
* Check firewall or CORS settings if API calls fail.

---

## License

MIT License

---

## Author

Nitish
