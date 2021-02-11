# Basic script to set custom project hook and share it with other developers
# Script source: https://gist.github.com/tilap/0590e78c9cfd8f6548f5

# INSTALL HOOKS
echo "Install project git hooks"

# list of hooks the script will look for
HOOK_NAMES="applypatch-msg pre-applypatch post-applypatch pre-commit prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-receive update post-receive post-update pre-auto-gc"

# relative folder path of the .git hook / current script
GIT_HOOK_DIR=./.git/hooks
# relative folder path of the custom hooks to deploy / current script
LOCAL_HOOK_DIR=./tools/git-hooks
# relative folder path of the custom hooks to deploy / .git hook folder
LNS_RELATIVE_PATH=../../tools/git-hooks

for hook in $HOOK_NAMES; do
    # if we have a custom hook to set
    if [ -f $LOCAL_HOOK_DIR/$hook ]; then
      echo "> Hook $hook"
      # If the hook already exists, is executable, and is not a symlink
      if [ ! -h $GIT_HOOK_DIR/$hook -a -x $GIT_HOOK_DIR/$hook ]; then
          echo " > Old git hook $hook disabled"
          # append .local to disable it
          mv $GIT_HOOK_DIR/$hook $GIT_HOOK_DIR/$hook.local
      fi

      # create the symlink, overwriting the file if it exists
      echo " > Enable project git hook"
      ln -s -f $LNS_RELATIVE_PATH/$hook $GIT_HOOK_DIR/$hook
    fi
done
