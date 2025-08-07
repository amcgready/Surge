# Surge Advanced Configuration System

## Overview

The Surge Advanced Configuration system provides a comprehensive CLI interface for configuring advanced options for all Surge services. This system complements the basic setup wizard by allowing deep customization of each service's behavior.

## Usage

### Basic Commands

```bash
# List all services with advanced configuration options
./surge advanced list

# Configure a specific service
./surge advanced config <service>

# Backup current advanced configurations  
./surge advanced backup

# Validate a service configuration
./surge advanced validate <service>

# Get help
./surge advanced help
```

### Available Services

The following services have advanced configuration options:

- **prowlarr** - Indexer management and automation
- **radarr** - Movie collection management
- **sonarr** - TV series management
- **bazarr** - Subtitle downloading and management
- **placeholdarr** - Placeholder file management
- **overseerr** - Media request management
- **tautulli** - Analytics and monitoring
- **nzbget** - Usenet download client
- **rdt-client** - Real-Debrid integration
- **zurg** - Real-Debrid mounting service
- **decypharr** - Decryption and processing
- **kometa** - Metadata management
- **posterizarr** - Poster and artwork management
- **scanly** - Media library scanning
- **cinesync** - Library synchronization
- **imagemaid** - Image processing
- **gaps** - Collection gap analysis
- **cli-debrid** - CLI debrid tools
- **homepage** - Dashboard customization

## Service-Specific Configuration Examples

### Prowlarr Advanced Configuration

Configure advanced Prowlarr settings including API limits, proxy settings, and logging:

```bash
./surge advanced config prowlarr
```

Options include:
- API rate limiting
- Authentication methods
- Proxy configuration
- Indexer sync settings
- Logging levels

### Placeholdarr Advanced Configuration

Set up comprehensive Placeholdarr integration with Plex, Radarr, and Sonarr:

```bash
./surge advanced config placeholdarr
```

Options include:
- Plex integration (URL, token, library updates)
- Service connections (Radarr, Sonarr APIs)
- Library paths and dummy file locations
- Placeholder strategies (hardlink, copy, symlink)
- Coming soon features and countdown timers
- Monitoring intervals and cleanup settings

### Zurg Advanced Configuration

Configure Real-Debrid mounting with advanced caching and performance options:

```bash
./surge advanced config zurg
```

Options include:
- Real-Debrid API integration
- Mount and network settings
- Cache configuration and performance tuning
- Logging and monitoring
- Auto-retry and error handling

### Radarr Advanced Configuration

Fine-tune movie management settings:

```bash
./surge advanced config radarr
```

Options include:
- Quality and media management rules
- Naming conventions and folder structures
- Import and processing settings
- Network and connection parameters
- Monitoring and RSS settings

### Sonarr Advanced Configuration

Configure TV series management in detail:

```bash
./surge advanced config sonarr
```

Options include:
- Episode management and naming
- Calendar and date formatting
- RSS sync intervals and search parameters
- Archive handling and reprocessing
- UI and accessibility options

## Configuration File Locations

Advanced configurations are saved to:

```
${STORAGE_PATH}/config/<service>/
├── advanced-settings.json    # For JSON-based services
├── config.yml.advanced       # For YAML-based services
└── config.ini.advanced       # For INI-based services
```

## Backup and Restore

### Creating Backups

```bash
# Backup all advanced configurations
./surge advanced backup
```

Backups are stored in:
```
${STORAGE_PATH}/config/backups/advanced-YYYYMMDD-HHMMSS/
├── manifest.json           # Backup metadata
├── prowlarr/              # Service configurations
├── radarr/
├── sonarr/
└── ...
```

### Validation

Validate service configurations for syntax errors and completeness:

```bash
# Validate specific service
./surge advanced validate placeholdarr

# Check all enabled services  
for service in prowlarr radarr sonarr; do
    ./surge advanced validate $service
done
```

## Integration with Main Surge System

The advanced configuration system integrates with:

1. **Auto-Config**: Advanced settings complement automatic API discovery
2. **Shared Config**: Works with shared variables (Discord, TMDB, etc.)
3. **WebUI**: Advanced options supplement the setup wizard
4. **Docker Compose**: Settings are applied through container restarts

## Best Practices

### Configuration Workflow

1. **Initial Setup**: Use `./surge setup` for basic configuration
2. **Deploy**: Run `./surge deploy <media-server>` to start services
3. **Advanced Config**: Use `./surge advanced config <service>` for fine-tuning
4. **Backup**: Create backups before major changes
5. **Validate**: Check configurations after modifications

### Service Dependencies

Configure services in this order for optimal integration:

1. **Core Services**: prowlarr, radarr, sonarr
2. **Enhancement Services**: bazarr, overseerr, tautulli  
3. **Download Clients**: nzbget, rdt-client, zurg
4. **Processing Tools**: placeholdarr, kometa, posterizarr
5. **Utilities**: scanly, cinesync, imagemaid

### Security Considerations

- Keep API tokens secure and never commit to version control
- Use environment variables for sensitive information
- Regularly backup configurations before updates
- Validate configurations after changes

## Troubleshooting

### Common Issues

**Configuration not applied after changes:**
```bash
# Restart the specific service
docker-compose restart <service>

# Or restart all services
./surge restart
```

**Permission errors during backup:**
```bash
# Check storage permissions
ls -la ${STORAGE_PATH}/config/

# Fix ownership if needed
./surge fix-ownership ${STORAGE_PATH}
```

**Invalid configuration syntax:**
```bash
# Validate configuration
./surge advanced validate <service>

# Check Docker logs
./surge logs <service>
```

### Getting Help

- Use `./surge advanced help` for command reference
- Check service logs with `./surge logs <service>`
- Review configuration files in `${STORAGE_PATH}/config/`
- Test individual settings through service web interfaces

## Future Enhancements

Planned features for the advanced configuration system:

- **Export/Import**: Configuration sharing between instances
- **Templates**: Pre-configured setups for common use cases
- **Validation**: Enhanced syntax and dependency checking
- **Integration**: Two-way sync with service web interfaces
- **Monitoring**: Configuration drift detection and alerts

---

For more information about specific service configurations, see the individual service documentation or use:

```bash
./surge advanced config <service>
```
