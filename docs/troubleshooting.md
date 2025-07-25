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

### Permission Denied Errors

**Problem**: Services can't write to mounted directories.

**Solution**:
1. Check your user/group IDs:
   ```bash
   id
   ```

2. Update `.env` with correct values:
   ```bash
   PUID=1000  # Your user ID
   PGID=1000  # Your group ID
   ```

3. Fix directory permissions:
   ```bash
   sudo chown -R $USER:$USER /opt/surge
   ```

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
   - RDT-Client: `surge-rdt-client:6500`

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
