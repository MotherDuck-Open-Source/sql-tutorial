import re
import sys

def convert_myst_markdown(input_file, output_file):
    with open(input_file, 'r') as file:
        content = file.read()

    # 1. Add code cells after jupytext header
    jupytext_pattern = r'(---\njupytext:.*?\n---\n)'
    additional_cells = (
        "\n```{code-cell}\n"
        "!pip install --upgrade duckdb magic-duckdb --quiet\n"
        "```\n\n"
        "```{code-cell}\n"
        "%load_ext magic_duckdb\n"
        "```\n"
    )
    content = re.sub(jupytext_pattern, r'\1' + additional_cells, content, flags=re.DOTALL)

    # 2. Replace SQL code blocks
    content = content.replace("```SQL", "```{code-cell}\n%%dql")

    # 3. Replace Python and Bash code blocks
    content = content.replace("```python", "```{code-cell}")
    content = content.replace("```bash", "```{code-cell}")

    # 4. Replace download link and add wget command
    download_pattern = r'(\{Download\}`(.+?\.csv)<\./data/(.+?\.csv)>`)'
    def replace_download_and_add_wget(match):
        full_match, filename, _ = match.groups()
        replacement = f"[{filename}](https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/{filename})"
        wget_command = (
            f"\n\n```{{code-cell}}\n"
            f"!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/{filename}\n"
            f"```\n"
        )
        return replacement# + wget_command

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