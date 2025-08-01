import os
import argparse

# --- Configuration ---

# A set of file extensions to include in the context file (leading dot is required).
# Using a set provides fast lookups.
INCLUDE_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".gdshader", ".shader", ".project", ".godot",
    ".import", ".cfg", ".json", ".xml", ".txt", ".md", ".glsl", ".gdignore",
    ".gitignore", ".gdns", ".gdextension"
}

# A set of directory names to completely exclude (case-insensitive on Windows).
# Any path containing these names as a directory segment will be skipped.
EXCLUDE_DIRS = {
    ".godot", "export_builds", "addons/gut", ".build", ".git", ".vscode", ".vs"
}

# --- Script Logic ---

def generate_project_context(project_root, output_file):
    """
    Recursively scans a project directory and compiles the content of specified
    file types into a single output file.

    Args:
        project_root (str): The absolute or relative path to the Godot project's root directory.
        output_file (str): The name of the file to save the context to.
    """
    print("Generating project context...")
    print(f"Project Root: {os.path.abspath(project_root)}")
    print(f"Output File:  {output_file}")
    print("-" * 20)

    # Overwrite the output file if it already exists
    with open(output_file, 'w', encoding='utf-8', errors='ignore') as outfile:
        # Recursively walk through the directory tree
        for root, dirs, files in os.walk(project_root):
            # Modify the list of directories in-place to prevent os.walk from descending into them
            dirs[:] = [d for d in dirs if d.lower() not in EXCLUDE_DIRS]

            for filename in files:
                file_ext = os.path.splitext(filename)[1].lower()

                # Check if the file extension is in our include list
                if file_ext in INCLUDE_EXTENSIONS:
                    file_path = os.path.join(root, filename)
                    relative_path = os.path.relpath(file_path, project_root)
                    
                    print(f"Adding: {relative_path}")
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as infile:
                            content = infile.read()

                        # Write file header, content, and footer to the output
                        outfile.write("\n")
                        outfile.write(f"=== FILE: {relative_path} ===\n")
                        outfile.write("\n")
                        outfile.write(content)
                        outfile.write("\n")
                        outfile.write(f"=== END OF FILE: {relative_path} ===\n")
                        outfile.write("\n\n")

                    except Exception as e:
                        print(f"  -> Error reading file {relative_path}: {e}")

    print("-" * 20)
    print("Context generation complete!")
    print(f"Output written to: {output_file}")
    print(f"Please review '{output_file}' for any sensitive information before sharing.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a single context file from a Godot project for analysis.",
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument(
        '--root',
        type=str,
        default=os.path.dirname(os.path.abspath(__file__)),
        help="The root directory of your Godot project.\n"
             "If not provided, defaults to the script's location."
    )
    
    parser.add_argument(
        '--output',
        type=str,
        default="godot_project_context.txt",
        help="The name of the output file.\n"
             "Defaults to 'godot_project_context.txt'."
    )
    
    args = parser.parse_args()

    generate_project_context(args.root, args.output)

    # The 'PAUSE' equivalent for cross-platform compatibility
    input("\nPress Enter to exit...")