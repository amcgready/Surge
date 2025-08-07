# Surge Auto-Configuration Guide

Surge now includes powerful auto-configuration capabilities that automatically discover and share Radarr/Sonarr API keys with other services. This eliminates the need for manual configuration of service connections.

## 🔧 What Gets Auto-Configured

The auto-configuration system automatically connects:

- **Bazarr** ↔ Radarr/Sonarr (subtitle management)
- **GAPS** ↔ Radarr (missing movie detection)
- **Overseerr** ↔ Radarr/Sonarr (request management)
- **Placeholdarr** ↔ Radarr/Sonarr (placeholder files)
- **Tautulli** connection details prepared
- **NZBGet** ↔ Radarr/Sonarr (download client integration)
- **Prowlarr** ↔ Radarr/Sonarr (indexer management)
- **Homepage** dashboard with service widgets and API integration
- **Posterizarr** ↔ Radarr/Sonarr (automated poster management)

## 🚀 How It Works

1. **API Key Discovery**: Automatically extracts API keys from service configuration files
2. **Service Detection**: Identifies which services are running
3. **Connection Configuration**: Creates proper configuration files for each service
4. **Validation**: Verifies services are ready before configuration

## 📋 Usage

### Automatic Configuration (Recommended)

```bash
# Configure all services automatically
./surge auto-config

# Configure specific service only
./surge auto-config --service bazarr

# Just discover API keys without configuring
./surge auto-config --discover
```

### Manual Configuration

```bash
# Using the standalone script
./scripts/auto-config.sh

# Using Python directly for advanced options
python3 scripts/api-discovery.py --storage-path /opt/surge
```

## 🎯 Supported Services

| Service | Status | Configuration Method |
|---------|--------|---------------------|
| Bazarr | ✅ Full | config.ini file |
| GAPS | ✅ Full | application.properties |
| Placeholdarr | ✅ Full | config.yml file |
| NZBGet | ✅ Full | nzbget.conf + API integration |
| Prowlarr | ✅ Full | REST API integration |
| Overseerr | ⚠️ Partial | Configuration prepared for import |
| Tautulli | ⚠️ Partial | Connection details prepared |

## 🔧 Prerequisites

- Services must be running (Radarr, Sonarr, Prowlarr)
- Services must have completed initial setup
- Python 3 must be available for advanced features

## 📖 Step-by-Step Example

1. **Deploy Surge services**:
   ```bash
   ./surge deploy plex
   ```

2. **Complete initial setup** in web interfaces:
   - Radarr: http://localhost:7878
   - Sonarr: http://localhost:8989
   - Prowlarr: http://localhost:9696

3. **Run auto-configuration**:
   ```bash
   ./surge auto-config
   ```

4. **Verify connections** in service web interfaces

## 🔍 Discovery Process

The system discovers API keys using multiple methods:

1. **Config File Extraction**: Reads from `config.xml` files
2. **API Calls**: Queries service APIs directly
3. **Retry Logic**: Multiple attempts with timeout handling

## 📁 Configuration Files Created

### Bazarr (`config/Bazarr/config.ini`)
```ini
[radarr]
enabled = True
url = http://surge-radarr:7878
api_key = discovered_api_key

[sonarr]  
enabled = True
url = http://surge-sonarr:8989
api_key = discovered_api_key
```

### GAPS (`config/GAPS/application.properties`)
```properties
radarr.address=http://surge-radarr:7878
radarr.apiKey=discovered_api_key
```

### Placeholdarr (`config/Placeholdarr/config.yml`)
```yaml
radarr:
  url: http://surge-radarr:7878
  api_key: discovered_api_key

sonarr:
  url: http://surge-sonarr:8989
  api_key: discovered_api_key
```

## ⚙️ Advanced Options

### Storage Path
```bash
./surge auto-config --storage-path /custom/path
```

### Service-Specific Configuration
```bash
./surge auto-config --service bazarr
./surge auto-config --service gaps
./surge auto-config --service overseerr
./surge auto-config --service placeholdarr
```

### Discovery Only
```bash
./surge auto-config --discover
```

### Custom Timeout
```bash
./scripts/auto-config.sh --wait-timeout 600
```

## 🐛 Troubleshooting

### Services Not Found
- Ensure services are running: `docker ps | grep surge`
- Complete initial setup in web interfaces
- Check service logs: `./surge logs radarr`

### API Keys Not Discovered
- Verify services are accessible on expected ports
- Check config files exist in storage path
- Ensure services have completed initial setup wizard

### Configuration Not Applied
- Some services require restart after configuration
- Check service-specific logs for errors
- Verify file permissions on config directories

### Manual Verification
```bash
# Check if API keys exist in config files
grep -r "ApiKey" /opt/surge/*/config/config.xml

# Test service connectivity
curl -s http://localhost:7878/api/v3/system/status
curl -s http://localhost:8989/api/v3/system/status
```

## 🔄 Integration with Existing Workflows

### During Deployment
The auto-configuration runs automatically during deployment via the WebUI backend.

### Manual Triggers
Run after service updates or configuration changes:
```bash
./surge auto-config
```

### Scheduled Runs
Add to cron for periodic re-configuration:
```bash
# Daily at 3 AM
0 3 * * * /path/to/surge/surge auto-config >/dev/null 2>&1
```

## 📝 Custom Service Integration

To add support for additional services:

1. **Extend the Python script** (`scripts/api-discovery.py`):
   ```python
   def configure_myservice(self, radarr_api: str = None, sonarr_api: str = None) -> bool:
       # Implementation here
       pass
   ```

2. **Add to the bash utilities** (`scripts/api-key-utils.sh`):
   ```bash
   configure_myservice_connections() {
       # Implementation here
   }
   ```

3. **Update the main configuration function** to include your service.

## 🎉 Benefits

- **Zero Manual Configuration**: No need to copy/paste API keys
- **Error Reduction**: Eliminates typos and connection issues  
- **Time Saving**: Instant service interconnection
- **Consistency**: Uses proper container names and internal URLs
- **Maintenance**: Easy reconfiguration after updates

## 🚀 Next Steps

After auto-configuration:

1. **Verify Connections**: Check each service's web interface
2. **Test Functionality**: Try subtitle downloads, movie requests, etc.
3. **Monitor Logs**: Watch for any connection errors
4. **Customize Settings**: Fine-tune service-specific options

The auto-configuration sets up the basic connections - you can still customize advanced settings in each service's web interface as needed.
