import React from 'react';
import { Box, Typography } from '@mui/material';

const ExternalAPIStep = ({ config, setConfig }) => {
  return (
    <Box sx={{ p: 4 }}>
      <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>External API Configuration</Typography>
      <Typography style={{ color: '#aaa', marginBottom: 24, fontSize: 14 }}>
        Configure external API keys to enhance your media server with metadata, artwork, and additional features. 
        These APIs improve the functionality of various services but are optional.
      </Typography>

      <Box display="grid" gridTemplateColumns="1fr" gap={3}>
        {/* Essential APIs */}
        <Box sx={{ border: '1px solid #07938f', borderRadius: 2, p: 3, background: '#0a2a2a' }}>
          <Typography style={{ color: '#07938f', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
            🎬 Essential APIs (Recommended)
          </Typography>
          <Box display="flex" flexDirection="column" gap={2}>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                TMDB API Key <span style={{ color: '#07938f' }}>*Recommended</span>
              </Typography>
              <input
                name="tmdbApiKey"
                value={config.tmdbApiKey || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, tmdbApiKey: e.target.value }))}
                placeholder="Enter your TMDB API key"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Get your free API key from <a href="https://www.themoviedb.org/settings/api" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>TMDB</a>. 
                Used by CineSync, Kometa, GAPS, and Posterizarr for movie/TV metadata.
              </Typography>
            </Box>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                Real-Debrid API Token
              </Typography>
              <input
                name="rdApiToken"
                value={config.rdApiToken || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, rdApiToken: e.target.value }))}
                placeholder="Enter your Real-Debrid API token"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Get from <a href="https://real-debrid.com/apitoken" target="_blank" rel="noopener noreferrer" style={{ color: '#07938f' }}>Real-Debrid</a>. 
                Required for Zurg, cli_debrid, and RDT-Client.
              </Typography>
            </Box>
          </Box>
        </Box>
        {/* Enhanced Features APIs */}
        <Box sx={{ border: '1px solid #444', borderRadius: 2, p: 3, background: '#1a1a1a' }}>
          <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
            🎨 Enhanced Features (Optional)
          </Typography>
          <Box display="flex" flexDirection="column" gap={2}>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                FanArt.tv API Key
              </Typography>
              <input
                name="fanartApiKey"
                value={config.fanartApiKey || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, fanartApiKey: e.target.value }))}
                placeholder="Enter your FanArt.tv API key (optional)"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Get from <a href="https://fanart.tv/get-an-api-key/" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>FanArt.tv</a>. 
                Provides high-quality artwork for Posterizarr and Kometa.
              </Typography>
            </Box>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                TVDB API Key
              </Typography>
              <input
                name="tvdbApiKey"
                value={config.tvdbApiKey || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, tvdbApiKey: e.target.value }))}
                placeholder="Enter your TVDB API key (optional)"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Enhanced TV show metadata. Register at <a href="https://thetvdb.com/api-information" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>TVDB</a>.
              </Typography>
            </Box>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                Trakt API Key
              </Typography>
              <input
                name="traktApiKey"
                value={config.traktApiKey || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, traktApiKey: e.target.value }))}
                placeholder="Enter your Trakt API key (optional)"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                For watchlist sync and recommendations. Get from <a href="https://trakt.tv/oauth/applications" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>Trakt</a>.
              </Typography>
            </Box>
          </Box>
        </Box>
        {/* Alternative Debrid Services */}
        <Box sx={{ border: '1px solid #333', borderRadius: 2, p: 3, background: '#151515' }}>
          <Typography style={{ color: '#fff', fontWeight: 'bold', marginBottom: 12, fontSize: 16 }}>
            🔄 Alternative Debrid Services (Optional)
          </Typography>
          <Box display="flex" flexDirection="column" gap={2}>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                AllDebrid API Token
              </Typography>
              <input
                name="adApiToken"
                value={config.adApiToken || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, adApiToken: e.target.value }))}
                placeholder="Enter your AllDebrid API token (optional)"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Alternative to Real-Debrid. Get from <a href="https://alldebrid.com/account/" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>AllDebrid</a>.
              </Typography>
            </Box>
            <Box>
              <Typography style={{ color: '#fff', marginBottom: 4 }}>
                Premiumize API Token
              </Typography>
              <input
                name="premiumizeApiToken"
                value={config.premiumizeApiToken || ''}
                onChange={(e) => setConfig(prev => ({ ...prev, premiumizeApiToken: e.target.value }))}
                placeholder="Enter your Premiumize API token (optional)"
                style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
              />
              <Typography style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                Alternative debrid service. Get from <a href="https://www.premiumize.me/account" target="_blank" rel="noopener noreferrer" style={{ color: '#888' }}>Premiumize</a>.
              </Typography>
            </Box>
          </Box>
        </Box>
      </Box>
      <Box mt={3} p={2} sx={{ background: '#0a1a2a', border: '1px solid #1a4a5a', borderRadius: 2 }}>
        <Typography style={{ color: '#79eaff', fontWeight: 'bold', marginBottom: 8, fontSize: 14 }}>
          💡 Pro Tips:
        </Typography>
        <ul style={{ color: '#aaa', fontSize: 12, margin: 0, paddingLeft: 16 }}>
          <li>TMDB API is free and greatly improves metadata quality</li>
          <li>Real-Debrid enables premium streaming and fast downloads</li>
          <li>All API keys are stored securely and never shared</li>
          <li>You can add or change API keys later in the configuration files</li>
        </ul>
      </Box>
    </Box>
  );
};

export default ExternalAPIStep;
