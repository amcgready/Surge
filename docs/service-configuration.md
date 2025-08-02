# Automatic Service Configuration

Surge automatically configures service interconnections so that your media management tools can communicate with each other seamlessly.

## Service Interconnections

### Bazarr ↔ Radarr/Sonarr
- **Automatic Configuration**: Bazarr is automatically configured to connect to Radarr and Sonarr
- **Subtitle Management**: Downloads subtitles for movies and TV shows managed by Radarr/Sonarr
- **Real API Keys**: Uses actual API keys instead of placeholders

### Overseerr ↔ Radarr/Sonarr/Tautulli
- **Media Requests**: Overseerr can automatically send requests to Radarr/Sonarr
- **Statistics Integration**: Connects to Tautulli for viewing statistics and activity
- **Unified Dashboard**: Single interface for requesting and monitoring media

### Prowlarr ↔ Radarr/Sonarr
- **Indexer Management**: Prowlarr automatically appears in Radarr/Sonarr as a connected application
- **Search Integration**: Radarr/Sonarr can search through all Prowlarr indexers
- **Centralized Configuration**: Manage all indexers from one place

## How It Works

### API Key Generation
```bash
# Generate API keys for all services
./surge inject-keys --generate-all
```

This command:
1. Generates unique API keys for each service
2. Injects them into service configuration files
3. Configures cross-service connections automatically

### Service-Specific Configuration

#### Bazarr Configuration
- Reads API keys from Radarr and Sonarr config files
- Creates `config/bazarr/config.ini` with:
  - Bazarr's own API key
  - Connection settings for Radarr (movies)
  - Connection settings for Sonarr (TV shows)

#### Overseerr Configuration
```bash
# Configure Overseerr with service connections
./surge configure-overseerr
```

This command:
1. Reads API keys from Radarr, Sonarr, and Tautulli
2. Generates Tautulli API key if missing
3. Creates `config/overseerr/settings.json` with:
   - Radarr connection for movie requests
   - Sonarr connection for TV show requests
   - Tautulli connection for statistics
   - Plex connection settings

#### Prowlarr Application Setup
- Automatically adds Radarr and Sonarr as "Applications" in Prowlarr
- Uses real API keys for authentication
- Enables automatic search and RSS sync

## Configuration Files

### Generated/Modified Files
- `config/prowlarr/config.xml` - Prowlarr API key
- `config/radarr/config.xml` - Radarr API key
- `config/sonarr/config.xml` - Sonarr API key
- `config/bazarr/config.ini` - Bazarr API key + Radarr/Sonarr connections
- `config/overseerr/settings.json` - Overseerr API key + service connections
- `config/tautulli/config.ini` - Tautulli API key (generated if missing)

### Docker Networking
All services use the `surge-network` Docker network, allowing them to communicate using container names:
- `surge-radarr:7878`
- `surge-sonarr:8989`
- `surge-bazarr:6767`
- `surge-prowlarr:9696`
- `surge-overseerr:5055`
- `surge-tautulli:8181`

## Deployment Integration

### Automatic Configuration During Deployment
When you deploy Surge, the system automatically:

1. **Creates Directory Structure**: Sets up all config directories
2. **Sets Proper Ownership**: Ensures Docker containers can access files
3. **Generates API Keys**: Creates unique keys for all services
4. **Configures Connections**: Sets up service interconnections
5. **Starts Containers**: Launches all services with proper configuration

### Manual Configuration
If you need to reconfigure services:

```bash
# Regenerate all API keys and connections
./surge inject-keys --generate-all

# Fix specific service
./surge inject-keys --service bazarr

# Reconfigure Overseerr
./surge configure-overseerr

# Fix file permissions
./surge fix-ownership
```

## Verification

### Check Service Status
```bash
# View available services and their status
./surge inject-keys --list-services
```

### Test API Discovery
```bash
# Discover all API keys
./surge api-keys --discover
```

### Manual Verification
```bash
# Check Bazarr connections
cat config/bazarr/config.ini

# Check Overseerr connections
cat config/overseerr/settings.json

# Check generated API keys
grep -r "apikey\|ApiKey" config/
```

## Troubleshooting

### Services Not Connecting
1. **Check API Keys**: Ensure all services have API keys generated
2. **Check Networks**: Verify all containers are on `surge-network`
3. **Check Ownership**: Ensure config files have proper ownership
4. **Restart Services**: Container restart may be needed after config changes

### Permission Issues
```bash
# Fix ownership for all storage directories
./surge fix-ownership

# Restart affected containers
docker-compose restart
```

### Missing Connections
```bash
# Reconfigure all service connections
./surge inject-keys --generate-all
./surge configure-overseerr
```

## Advanced Configuration

### Custom Storage Paths
```bash
# Configure with custom storage path
./surge configure-overseerr --storage-path /custom/path
./surge fix-ownership /custom/path
```

### Environment Variables
Configure PUID/PGID in `.env` for proper file ownership:
```bash
PUID=1000
PGID=1000
STORAGE_PATH=/opt/surge
```
