# Template for Placeholdarr .env fields
# Fill these from your environment or config as needed
ENV_FIELDS = {
    # Required
    "PLEX_URL": "",
    "PLEX_TOKEN": "",
    "RADARR_URL": "",
    "RADARR_API_KEY": "",
    "SONARR_URL": "",
    "SONARR_API_KEY": "",
    "MOVIE_LIBRARY_FOLDER": "",
    "TV_LIBRARY_FOLDER": "",
    "DUMMY_FILE_PATH": "",
    # Optional
    "PLACEHOLDER_STRATEGY": "copy",  # or "hardlink"
    "TV_PLAY_MODE": "episode",  # or "season", "series"
    "TITLE_UPDATES": "REQUEST",  # or "OFF", "ALL"
    "INCLUDE_SPECIALS": "false",
    "EPISODES_LOOKAHEAD": "5",
    "MAX_MONITOR_TIME": "600",
    "CHECK_INTERVAL": "60",
    "AVAILABLE_CLEANUP_DELAY": "300",
    "CALENDAR_LOOKAHEAD_DAYS": "30",
    "CALENDAR_SYNC_INTERVAL_HOURS": "6",
    "ENABLE_COMING_SOON_PLACEHOLDERS": "true",
    "PREFERRED_MOVIE_DATE_TYPE": "inCinemas",
    "ENABLE_COMING_SOON_COUNTDOWN": "true",
    "CALENDAR_PLACEHOLDER_MODE": "episode",
    "COMING_SOON_DUMMY_FILE_PATH": ""
}
