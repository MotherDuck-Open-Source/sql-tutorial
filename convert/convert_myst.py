import re
import sys

def convert_myst_markdown(input_file, output_file):
    with open(input_file, 'r') as file:
        content = file.read()

    # Replace download link
    download_pattern = r'(\{Download\}`(.+?\.csv)<\./data/(.+?\.csv)>`)'
    def replace_download_and_add_wget(match):
        full_match, filename, _ = match.groups()
        replacement = f"[{filename}](https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/{filename})"
        return replacement

    content = re.sub(download_pattern, replace_download_and_add_wget, content)

    # 5. Replace admonition blocks for exercises
    exercise_pattern = r'```\{admonition\} Exercise\n(.*?)```'
    replacement = r'+++ {"cell_type": "markdown"}\n\n**Exercise**\n\n\1\n+++ {"cell_type": "markdown"}\n'
    content = re.sub(exercise_pattern, replacement, content, flags=re.DOTALL)

    # 6. Replace admonition blocks for notes
    exercise_pattern = r'```\{Note\}\n(.*?)```'
    replacement = r'+++ {"cell_type": "markdown"}\n\n**Note**\n\n\1\n+++ {"cell_type": "markdown"}\n'
    content = re.sub(exercise_pattern, replacement, content, flags=re.DOTALL)

    with open(output_file, 'w') as file:
        file.write(content)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_myst.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    convert_myst_markdown(input_file, output_file)
    print(f"Converted {input_file} to {output_file}")