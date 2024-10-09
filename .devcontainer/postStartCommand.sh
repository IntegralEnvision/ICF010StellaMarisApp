# Path to the file that tracks whether the project has been initialized
INIT_FLAG=".devcontainer/INIT_FLAG"

# Path to the file that identifies the template repo
TEMPLATE_REPO_FLAG=".devcontainer/TEMPLATE_REPO_FLAG"

# Workaround to commit and push files generated after project initialization
# This code snippet is not supposed to be run in template repo
if [ ! -e $INIT_FLAG ] && [ ! -e $TEMPLATE_REPO_FLAG ]; then

    # Create file to indicate that the project has been initialized
    touch $INIT_FLAG

    # Push {golem} and {renv} files created during project initialization
    git add .
    git commit -m "Initialize golem with renv"
    git push

fi
