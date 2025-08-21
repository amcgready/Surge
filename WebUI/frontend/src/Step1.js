import React from 'react';
import { Box, Typography, Tooltip, Button, Divider } from '@mui/material';
// ...import any other components, hooks, or assets needed for step 1...

const Step1 = ({ config, setConfig, coreServers }) => {
  return (
    <Box>
      <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Core Media Server</Typography>
      <Box display="flex" gap={3} mb={3} justifyContent="center">
        {coreServers.map((srv) => (
          <Tooltip key={srv.key} title={srv.desc} placement="top">
            <Box
              onClick={() => setConfig((prev) => ({ ...prev, mediaServer: prev.mediaServer === srv.key ? '' : srv.key }))}
              sx={{
                cursor: 'pointer',
                opacity: config.mediaServer === srv.key ? 1 : 0.4,
                filter: config.mediaServer === srv.key ? 'none' : 'grayscale(100%)',
                border: config.mediaServer === srv.key ? '2px solid #07938f' : '2px solid #444',
                borderRadius: 2,
                p: 1,
                background: '#181818',
                transition: 'all 0.2s',
                position: 'relative',
                boxShadow: config.mediaServer === srv.key ? '0 0 8px #07938f' : 'none',
                '&:hover': { boxShadow: '0 0 16px #07938f' }
              }}
            >
              <img src={srv.logo} alt={srv.name} style={{ maxWidth: 192, maxHeight: 192, width: 'auto', height: 'auto', display: 'block', margin: '0 auto' }} />
              {config.mediaServer !== srv.key && (
                <Box sx={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  width: '100%',
                  height: '100%',
                  bgcolor: 'rgba(40,40,40,0.6)',
                  borderRadius: 2
                }} />
              )}
            </Box>
          </Tooltip>
        ))}
      </Box>
      {/* Media Server Configuration */}
      {config.mediaServer && (
        <Box mt={4} p={2} sx={{ background: '#1a1a1a', borderRadius: 2, border: '1px solid #333' }}>
          <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>
            {coreServers.find(s => s.key === config.mediaServer)?.name} Configuration
          </Typography>
          {config.mediaServer === 'plex' && (
            <Box>
              <Box display="flex" gap={2} mb={2}>
                <Box flex={1}>
                  <Typography style={{ color: '#fff', marginBottom: 8 }}>Server Name</Typography>
                  <input
                    type="text"
                    value={config.plexSettings.HOSTNAME}
                    onChange={(e) => setConfig(prev => ({
                      ...prev,
                      plexSettings: { ...prev.plexSettings, HOSTNAME: e.target.value }
                    }))}
                    placeholder="PlexServer"
                    style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                  />
                  <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                    The friendly name for your Plex server
                  </Typography>
                </Box>
                <Box flex={1}>
                  <Typography style={{ color: '#fff', marginBottom: 8 }}>Plex Claim Token (Optional)</Typography>
                  <input
                    type="text"
                    value={config.plexSettings.PLEX_CLAIM}
                    onChange={(e) => setConfig(prev => ({
                      ...prev,
                      plexSettings: { ...prev.plexSettings, PLEX_CLAIM: e.target.value }
                    }))}
                    placeholder="claim-xxxxxxxxx"
                    style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                  />
                  <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                    Get from <a href="https://plex.tv/claim" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>plex.tv/claim</a>
                  </Typography>
                </Box>
              </Box>
              <Box mt={3} p={2} sx={{ background: '#252525', borderRadius: 1, border: '1px solid #444' }}>
                <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 8 }}>
                  🎬 Automatic Library Creation
                </Typography>
                <Typography style={{ color: '#aaa', fontSize: 14 }}>
                  Surge will automatically create Plex libraries based on your CineSync folder structure:
                </Typography>
                <Box mt={1} ml={2}>
                  <Typography style={{ color: '#fff', fontSize: 13 }}>• Movies</Typography>
                  <Typography style={{ color: '#fff', fontSize: 13 }}>• TV Shows</Typography>
                  <Typography style={{ color: '#fff', fontSize: 13 }}>• Anime Movies</Typography>
                  <Typography style={{ color: '#fff', fontSize: 13 }}>• Anime Series</Typography>
                </Box>
                <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 8 }}>
                  Libraries will be created automatically after deployment with proper metadata agents.
                </Typography>
              </Box>
            </Box>
          )}
          {config.mediaServer === 'jellyfin' && (
            <Box>
              <Box display="flex" gap={2} mb={2}>
                <Box flex={1}>
                  <Typography style={{ color: '#fff', marginBottom: 8 }}>Published Server URL</Typography>
                  <input
                    type="text"
                    value={config.jellyfinSettings.JELLYFIN_PublishedServerUrl}
                    onChange={(e) => setConfig(prev => ({
                      ...prev,
                      jellyfinSettings: { ...prev.jellyfinSettings, JELLYFIN_PublishedServerUrl: e.target.value }
                    }))}
                    placeholder="https://jellyfin.yourdomain.com"
                    style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                  />
                  <Typography style={{ color: '#aaa', fontSize: 12, marginTop: 4 }}>
                    The external URL for your Jellyfin server
                  </Typography>
                </Box>
              </Box>
            </Box>
          )}
          {config.mediaServer === 'emby' && (
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 8 }}>Emby Configuration</Typography>
              <Typography style={{ color: '#aaa', fontSize: 14 }}>
                Basic Emby setup with default configuration. Advanced settings can be configured after deployment.
              </Typography>
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
};

export default Step1;
