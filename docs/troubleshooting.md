# Troubleshooting Guide

This guide covers common issues and their solutions when running Surge.

## Container Issues

### Container Fails to Start

**Problem**: Container exits immediately or fails to start.

**Solution**:
1. Check logs for the specific service:
   ```bash
   ./scripts/maintenance.sh logs [service-name]
   ```

2. Common causes and fixes:
   - **Permission issues**: Check PUID/PGID in `.env`
   - **Port conflicts**: Change port in `.env`
   - **Missing directories**: Run deployment script again
   - **Configuration errors**: Reset service configuration

### STORAGE_PATH Environment Variable Not Set

**Problem**: Docker Compose shows warnings like "The 'STORAGE_PATH' variable is not set" and services can't find their configuration.

**Common Symptoms**:
- Applications not appearing in Prowlarr UI
- Configuration files not being created properly
- Services fail to start or connect to each other
- Warning messages in Docker Compose logs

**Solution**:
1. Check your `.env` file:
   ```bash
   grep STORAGE_PATH .env
   ```

2. If missing, add the STORAGE_PATH variable:
   ```bash
   echo "STORAGE_PATH=/opt/surge" >> .env
   ```

3. Or edit `.env` manually and add:
   ```bash
   # Storage configuration
   STORAGE_PATH=/path/to/your/storage/location
   ```

4. Restart all services:
   ```bash
   docker compose down
   docker compose up -d
   ```

**Note**: Replace `/path/to/your/storage/location` with your actual storage path. For NAS setups, this is typically something like `/mnt/nas-name/Surge`.

### Permission Denied Errors

**Problem**: Services can't write to mounted directories or configs are locked.

**Common Symptoms**:
- Overseerr config directory is locked/inaccessible
- Services fail to create configuration files
- "Permission denied" errors in container logs

**Solution**:
1. Use the built-in ownership fix command:
   ```bash
   ./surge fix-ownership
   ```

2. For custom storage paths:
   ```bash
   ./surge fix-ownership /path/to/your/storage
   ```

3. Manual approach - Check your user/group IDs:
   ```bash
   id
   ```

4. Update `.env` with correct values:
   ```bash
   PUID=1000  # Your user ID
   PGID=1000  # Your group ID
   ```

5. Manual fix directory permissions:
   ```bash
   sudo chown -R $PUID:$PGID $STORAGE_PATH
   ```

6. Restart affected containers:
   ```bash
   docker-compose restart
   ```

**Note**: The `fix-ownership` command automatically reads your PUID/PGID from `.env` and applies the correct ownership.

### Port Already in Use

**Problem**: "Port already in use" error when starting containers.

**Solution**:
1. Check what's using the port:
   ```bash
   sudo netstat -tulpn | grep :8989
   ```

2. Change the port in `.env`:
   ```bash
   SONARR_PORT=8990  # Use different port
   ```

3. Restart the service:
   ```bash
   ./scripts/deploy.sh [media-server]
   ```

## Network Issues

### Services Can't Communicate

**Problem**: Services can't reach each other (e.g., Radarr can't connect to download client).

**Solution**:
1. Use container names for internal communication:
   - NZBGet: `surge-nzbget:6789`

2. Check network exists:
   ```bash
   docker network ls | grep surge
   ```

3. Recreate network if needed:
   ```bash
   docker network rm surge-network
   ./scripts/deploy.sh [media-server]
   ```

### Can't Access Web Interfaces

**Problem**: Web interfaces not accessible from browser.

**Solution**:
1. Check if container is running:
   ```bash
   docker ps | grep surge-
   ```

2. Check port mappings:
   ```bash
   docker port surge-radarr
   ```

3. Test with curl:
   ```bash
   curl http://localhost:7878
   ```

4. Check firewall settings if accessing remotely.

## Storage Issues

### Out of Disk Space

**Problem**: Downloads fail or services become unresponsive due to disk space.

**Solution**:
1. Check disk usage:
   ```bash
   df -h
   ```

2. Clean up Docker system:
   ```bash
   ./scripts/maintenance.sh cleanup
   ```

3. Move data to larger drive and update `.env`:
   ```bash
   DATA_ROOT=/mnt/large-drive/surge
   ```

### Slow Performance

**Problem**: Services are slow or downloads are slow.

**Solution**:
1. Check system resources:
   ```bash
   ./scripts/maintenance.sh status
   ```

2. Increase Docker resources (if using Docker Desktop).

3. Consider moving transcoding to RAM:
   ```bash
   # Add to docker-compose.plex.yml
   tmpfs:
     - /transcode:rw,nodev,nosuid,size=2G
   ```

## Media Server Issues

### Plex

**Libraries Not Updating**:
1. Check folder permissions
2. Force library update in Plex
3. Restart Plex container:
   ```bash
   ./scripts/maintenance.sh reset plex
   ```

**Can't Access Remotely**:
1. Check port forwarding (32400)
2. Set `PLEX_ADVERTISE_IP` in `.env`
3. Verify Plex Pass for remote access features

### Jellyfin/Emby

**Hardware Transcoding Not Working**:
1. Ensure `/dev/dri` is available:
   ```bash
   ls -la /dev/dri
   ```

2. Add user to video group:
   ```bash
   sudo usermod -a -G video $USER
   ```

## Service-Specific Issues

### Radarr/Sonarr

**Movies/Shows Not Downloading**:
1. Check indexer configuration
2. Verify download client connection
3. Check quality profiles
4. Review activity logs in the web interface

**Import Failures**:
1. Check file permissions
2. Verify root folder paths
3. Check naming conventions

### NZBGet

**Downloads Failing**:
1. Check Usenet provider settings
2. Verify account status and limits
3. Check disk space
4. Review NZBGet logs

### Bazarr

**Subtitles Not Downloading**:
1. Check provider settings
2. Verify Radarr/Sonarr API connections
3. Check language profiles

### Prowlarr

**Applications Not Showing in UI**:

**Problem**: Radarr and Sonarr applications don't appear in Prowlarr's Settings > Apps section, even though they should be automatically configured.

**Common Symptoms**:
- Empty Applications list in Prowlarr UI
- "STORAGE_PATH variable is not set" warnings in Docker logs
- Prowlarr can't sync indexers to Radarr/Sonarr
- Applications missing after deployment

**Automated Solution**:

The deployment script now automatically configures Prowlarr applications using Prowlarr's REST API. This approach is more reliable than XML file manipulation.

If the automatic configuration fails during deployment, you can run it manually:

```bash
# Run the API-based automated configuration
python3 scripts/prowlarr-api-config.py

# Or test the integrated automation
python3 scripts/test-automation.py
```

**How the Automation Works**:

1. **Waits for all services** (Prowlarr, Radarr, Sonarr) to start and generate their API keys
2. **Extracts API keys** from each service's configuration file  
3. **Uses Prowlarr's REST API** to add Radarr and Sonarr applications
4. **Configures proper URLs** using Docker container names (`surge-radarr:7878`, `surge-sonarr:8989`)
5. **Enables all features** including RSS feeds, automatic search, and interactive search

**Manual Troubleshooting Steps**:

1. **Check Environment Variables**:
   ```bash
   grep STORAGE_PATH .env
   ```
   If missing, add:
   ```bash
   echo "STORAGE_PATH=/opt/surge" >> .env
   ```

2. **Verify Applications in Configuration**:
   ```bash
   # Check XML config (primary source)
   grep -A5 -B5 "ApplicationDefinition" /opt/surge/Prowlarr/config/config.xml
   
   # Check database (secondary)
   sqlite3 /opt/surge/Prowlarr/config/prowlarr.db "SELECT Name, Implementation FROM Applications;"
   ```

3. **Restart Services with Proper Environment**:
   ```bash
   # Stop and restart all services
   docker compose down
   docker compose up -d
   
   # Or restart just Prowlarr
   docker compose restart prowlarr
   ```

4. **Clear Browser Cache**:
   - Hard refresh: Ctrl+F5 or Ctrl+Shift+R
   - Try incognito/private mode
   - Try different browser

5. **Check Service Connectivity**:
   ```bash
   # Verify all services are running
   docker compose ps
   
   # Test if Radarr/Sonarr are accessible
   curl -H "X-Api-Key: YOUR_RADARR_API_KEY" http://localhost:7878/api/v3/system/status
   curl -H "X-Api-Key: YOUR_SONARR_API_KEY" http://localhost:8989/api/v3/system/status
   ```

6. **Manual Application Configuration** (Last Resort):
   If automated configuration fails, try adding applications manually through the Prowlarr UI:
   - Go to Settings > Apps > Add Application
   - Select Radarr/Sonarr
   - Enter the internal container URLs:
     - Radarr: `http://surge-radarr:7878`
     - Sonarr: `http://surge-sonarr:8989`
   - Use the API keys from their respective config files
   
   Get API keys with:
   ```bash
   # Radarr API Key
   grep -o '<ApiKey>[^<]*' /opt/surge/Radarr/config/config.xml | cut -d'>' -f2
   
   # Sonarr API Key  
   grep -o '<ApiKey>[^<]*' /opt/surge/Sonarr/config/config.xml | cut -d'>' -f2
   ```

7. **Force UI Refresh**:
   If applications are in the configuration but not showing:
   ```bash
   # Clear all browser data for the site
   # Or try accessing Prowlarr from a different device/network
   # Sometimes the issue is client-side caching
   ```

**Note**: The automated configuration uses XML-first approach which is Prowlarr's primary configuration method. Applications may not appear if Prowlarr cannot establish connections to Radarr/Sonarr. Ensure all services are running and accessible.

## Update Issues

### Update Fails

**Problem**: Update script fails or containers won't restart.

**Solution**:
1. Stop all services:
   ```bash
   ./scripts/deploy.sh --stop
   ```

2. Clean up system:
   ```bash
   ./scripts/maintenance.sh cleanup
   ```

3. Restart deployment:
   ```bash
   ./scripts/deploy.sh [media-server]
   ```

### Configuration Lost After Update

**Problem**: Settings reset after container update.

**Solution**:
1. Configuration should persist in Docker volumes
2. Check volume mounts:
   ```bash
   docker volume ls | grep surge
   ```

3. Restore from backup if needed:
   ```bash
   # Restore from backup directory
   docker run --rm -v surge_radarr-config:/volume -v /path/to/backup:/backup alpine tar xzf /backup/radarr-config.tar.gz -C /volume
   ```

## Performance Optimization

### High CPU Usage

1. Limit concurrent downloads in download clients
2. Reduce quality profiles if transcoding is intensive
3. Schedule intensive tasks during off-peak hours

### High Memory Usage

1. Restart services periodically:
   ```bash
   ./scripts/maintenance.sh restart
   ```

2. Monitor with system tools:
   ```bash
   htop
   docker stats
   ```

## Getting Help

If you're still experiencing issues:

1. Check the logs:
   ```bash
   ./scripts/maintenance.sh logs
   ```

2. Search existing issues on GitHub
3. Create a new issue with:
   - Your configuration (remove sensitive data)
   - Error logs
   - Steps to reproduce
   - System information

## Emergency Recovery

### Complete Reset

If everything is broken:

```bash
# Stop all services
./scripts/deploy.sh --stop

# Remove all containers and networks
docker compose down --volumes

# Clean Docker system
docker system prune -a --volumes

# Redeploy
./scripts/deploy.sh [media-server]
```

**Warning**: This will delete all configuration and data. Make sure you have backups!
