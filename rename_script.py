import os

project_dir = r"c:\flutter_Dev\projects\we_chat"

replacements = [
    ("com.harshRajpurohit", "com.akshar"),
    ("HarshAndroid", "Akshar"),
    ("rajpurohitharsh2020", "akshar"),
    ("Harsh Rajpurohit", "Akshar"),
    ("HarshRajpurohit", "Akshar"),
    ("harsh", "akshar"),
    ("Harsh", "Akshar"),
]

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return

    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

for root, dirs, files in os.walk(project_dir):
    if any(skip in root for skip in [".git", "build", ".dart_tool", ".idea"]):
        continue
    for file in files:
        if file == "rename_script.py":
            continue
        filepath = os.path.join(root, file)
        replace_in_file(filepath)

old_dir = os.path.join(project_dir, "android", "app", "src", "main", "kotlin", "com", "harshRajpurohit")
new_dir = os.path.join(project_dir, "android", "app", "src", "main", "kotlin", "com", "akshar")

if os.path.exists(old_dir):
    os.rename(old_dir, new_dir)
    print("Renamed directory:", old_dir, "->", new_dir)
