import os

file_path = r"d:\LIGTAS_SYSTEM\web\components\inventory\inventory-dialog\use-inventory-form.ts"

with open(file_path, "r", encoding="utf-8") as f:
    original = f.read()

# I will recreate the file from scratch using the git file.
# First let's restore it perfectly from git.
import subprocess
try:
    subprocess.run(["git", "checkout", "HEAD", "--", "web/components/inventory/inventory-dialog/use-inventory-form.ts"], cwd=r"d:\LIGTAS_SYSTEM", check=True)
except Exception as e:
    print("git fail", e)

with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

print("File size:", len(text))
print("File lines:", len(text.split('\n')))
