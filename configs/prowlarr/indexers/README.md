# Prowlarr Custom Indexers

This directory contains custom indexer definitions for Prowlarr that extend its functionality beyond the built-in indexers.

## Included Indexers

### Torrentio
- **File**: `torrentio.yml`
- **Description**: Real-Debrid integration for streaming torrents
- **Requirements**: Real-Debrid API key
- **Source**: https://github.com/dreulavelle/Prowlarr-Indexers

## Setup Instructions

1. **Torrentio Setup**:
   - The indexer will be automatically available in Prowlarr after container restart
   - Go to Prowlarr Settings → Indexers → Add Indexer
   - Search for "Torrentio" and select it
   - Configure with your Real-Debrid API key
   - Adjust provider options as needed

2. **Configuration Options**:
   - **Debrid Provider**: Choose your debrid service (Real-Debrid, AllDebrid, etc.)
   - **API Key**: Your debrid service API key
   - **Providers**: Customize which torrent sources to use
   - **Quality Filters**: Set preferred quality options

## Integration

These custom indexers integrate seamlessly with:
- **Radarr**: Movie management and downloading
- **Sonarr**: TV show management and downloading
- **Real-Debrid**: Premium debrid service for fast downloads

## Troubleshooting

- Ensure your debrid service API key is valid
- Check that your debrid service account is active
- Verify network connectivity to torrentio.strem.fun
- Review Prowlarr logs for any indexer-specific errors

## Credits

Custom indexer definitions sourced from the community-maintained repository:
https://github.com/dreulavelle/Prowlarr-Indexers
