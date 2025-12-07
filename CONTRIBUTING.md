# Contributing to DesktopBackground

Thank you for your interest in contributing!

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/kumarnitish378/DesktopBackground.git
    cd DesktopBackground
    ```

2.  **Set up the Environment**:
    We recomend using a virtual environment for Python.
    ```bash
    python -m venv venv
    .\venv\Scripts\Activate
    pip install -r requirements.txt
    ```

3.  **Database**:
    The database `todos.db` is auto-created when you run the server.
    ```bash
    python main.py
    ```

## Project Structure
*   `main.py`: Flask Server.
*   `webBasedWallPaper.ps1`: PowerShell Client.
*   `config.json`: Client configuration.
*   `assets/`: Images and static resources.

## Running Tests
Run the unit tests with:
```bash
python -m unittest discover tests
```

## Pull Requests
1.  Fork the repo and create your branch from `main`.
2.  Ensure your code lints correctly (see `.github/workflows/ci.yml`).
3.  Submit a Pull Request with a clear description of changes.
