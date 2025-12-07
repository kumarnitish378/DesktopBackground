# Feature Proposals & Suggested Edits

Based on the current architecture, here are the recommended next steps to improve the project.

## 1. 🔧 Refactor: Configuration File (Recommended First Step)
Currently, all layout coordinates (`x=1217`, `y=140`), font sizes (`48`), and colors are **hardcoded** in the PowerShell script.
*   **The Edit**: Move these values to a `config.json` file.
*   **Benefit**: You can tweak the design (move text, change colors) without editing the code.
*   **Complexity**: Low.

## 2. 📅 Feature: Due Dates & Urgency
Add a deadline to tasks.
*   **Server**: Update `todos.db` to store a `due_date`.
*   **Client**: PowerShell calculates "Days Left".
    *   *If passing due date*: Render in **Bold Red**.
    *   *If due tomorrow*: Render in **Orange**.
*   **Benefit**: Makes the wallpaper a true productivity tool with urgency.
*   **Complexity**: Medium.

## 3. 🛡️ Security: Basic Authentication
Currently, anyone on your network (if exposed) could delete your todos.
*   **The Edit**: Add a simple password or API Key check to the Flask server and PowerShell client.
*   **Benefit**: Prevents unauthorized access.
*   **Complexity**: Low/Medium.

## 4. 🖥️ Feature: Multi-Monitor / Resolution Support
The current script assumes a specific 1920x1080 (or similar) aspect ratio template.
*   **The Edit**: Detect screen resolution and scale the template/text accordingly.
*   **Benefit**: Looks good on any screen (Laptop vs Monitor).
*   **Complexity**: High.

## 5. 🔁 Automation: One-Click Installer
Create a batch file or improved PowerShell script that:
1.  Installs Python dependencies.
2.  Sets up the Registry Key.
3.  Creates the Scheduled Task.
*   **Benefit**: Easier for others to use your tool.
