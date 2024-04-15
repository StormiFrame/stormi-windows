if not exist "appserverset" (
    echo The current directory is not a working directory. you can run `stormi init` change current diretory to working directory or enter working directory to run current command.
    exit
)
if not exist "app.yaml" (
    echo The current directory is not a working directory. you can run `stormi init` change current diretory to working directory or enter working directory to run current command.
    exit
)