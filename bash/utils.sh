SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON_DIR="$SCRIPT_DIR/python"

run_python() {
    local script_path=$PYTHON_DIR/$1
    # If python3 is in the PATH
    if command -v python3 &> /dev/null; then
        # Run the script with python3, pass rest of the arguments
        python3 $script_path "${@:2}"
    # If python is in the PATH
    elif command -v python &> /dev/null; then
        # Run the script with python, pass rest of the arguments
        python $script_path "${@:2}"
    else
        echo "Python is not found in the PATH"
        return 1
    fi
}