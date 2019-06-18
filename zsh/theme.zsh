SPACESHIP_PROMPT_ORDER=(
  # time          # Time stamps section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

SPACESHIP_EXEC_TIME_PREFIX=""
SPACESHIP_EXEC_TIME_COLOR="magenta"
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false

SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=white

SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

SPACESHIP_GIT_BRANCH_COLOR=green
SPACESHIP_GIT_PREFIX=""
SPACESHIP_GIT_STATUS_COLOR="yellow"

SPACESHIP_DIR_PREFIX=""
