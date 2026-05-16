# Shared helpers for the executables database backing `brew which-formula`
# and `brew exec`'s provider lookup.

# HOMEBREW_CACHE is set by utils/ruby.sh
# HOMEBREW_LIBRARY is set by bin/brew
# HOMEBREW_API_DEFAULT_DOMAIN HOMEBREW_CURL_SPEED_LIMIT HOMEBREW_CURL_SPEED_TIME HOMEBREW_USER_AGENT_CURL are set by brew.sh
# shellcheck disable=SC2154
ENDPOINT="internal/executables.txt"
DATABASE_FILE="${HOMEBREW_CACHE}/api/${ENDPOINT}"

is_file_fresh() {
  if [[ -n "${HOMEBREW_MACOS}" ]]
  then
    STAT_PRINTF=("/usr/bin/stat" "-f")
  else
    STAT_PRINTF=("/usr/bin/stat" "-c")
  fi

  local file_mtime
  local current_time
  local auto_update_secs

  file_mtime=$("${STAT_PRINTF[@]}" %m "${DATABASE_FILE}")
  current_time=$(date +%s)
  auto_update_secs=${HOMEBREW_API_AUTO_UPDATE_SECS:-450}

  [[ $((current_time - auto_update_secs)) -lt ${file_mtime} ]]
}

download_and_cache_executables_file() {
  source "${HOMEBREW_LIBRARY}/Homebrew/utils/helpers.sh"
  if [[ -s "${DATABASE_FILE}" ]] && ([[ -n "${HOMEBREW_SKIP_UPDATE}" ]] || is_file_fresh)
  then
    return
  else
    local url
    url="${HOMEBREW_API_DEFAULT_DOMAIN}/${ENDPOINT}"

    if [[ -n "${CI}" ]]
    then
      max_time=""
      retries="3"
    else
      max_time=10
      retries=0
    fi
    mkdir -p "${DATABASE_FILE%/*}"
    ${HOMEBREW_CURL} \
      --compressed \
      --speed-limit "${HOMEBREW_CURL_SPEED_LIMIT}" --speed-time "${HOMEBREW_CURL_SPEED_TIME}" \
      --location --remote-time --output "${DATABASE_FILE}" \
      ${max_time:+--max-time "${max_time}"} \
      ${retries:+--retry "${retries}" --retry-delay 0 --retry-max-time 60} \
      --user-agent "${HOMEBREW_USER_AGENT_CURL}" \
      "${url}"
    touch "${DATABASE_FILE}"

    git config --file="${HOMEBREW_REPOSITORY}/.git/config" --bool homebrew.commandnotfound true 2>/dev/null
  fi
}
