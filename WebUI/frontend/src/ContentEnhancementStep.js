import React from 'react';
import { Box, Typography, Button, Tooltip } from '@mui/material';

export default function ContentEnhancementStep(props) {
  const {
    contentEnhancementList,
    contentEnhancement,
    setContentEnhancement,
    config,
    setConfig,
    handleChange
  } = props;

  return (
    <Box>
      <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Content Enhancement</Typography>
      <Box display="flex" gap={1.5} mb={3} justifyContent="center">
        {contentEnhancementList.map((tool) => (
          <Tooltip key={tool.key} title={tool.desc} placement="top">
            <Box
              onClick={() => setContentEnhancement((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
              sx={{
                cursor: 'pointer',
                opacity: contentEnhancement[tool.key] ? 1 : 0.4,
                filter: contentEnhancement[tool.key] ? 'none' : 'grayscale(100%)',
                /* outer border removed */
                borderRadius: 2,
                p: 0.5,
                background: '#181818',
                transition: 'all 0.2s',
                position: 'relative',
                /* remove glow entirely */
                boxShadow: 'none',
                '&:hover': { boxShadow: 'none' }
              }}
            >
              <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
              <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
              {!contentEnhancement[tool.key] && (
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

      {/* Kometa - basic fields only */}
      {contentEnhancement.kometa && (
        <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2 }}>
          <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Kometa</Typography>
          <Box display="flex" gap={2} alignItems="center">
            <Typography style={{ color: '#fff' }}>Kometa URL</Typography>
            <input
              name="kometaUrl"
              value={config.kometaUrl}
              onChange={handleChange}
              placeholder="http://kometa:8000"
              style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
            />
          </Box>
          <Box display="flex" gap={2} alignItems="center" mt={2}>
            <Typography style={{ color: '#fff' }}>Kometa API Key</Typography>
            <input
              name="kometaApiKey"
              value={config.kometaApiKey}
              onChange={handleChange}
              placeholder="API Key"
              style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
            />
          </Box>
        </Box>
      )}

      {/* Posterizarr - basic fields only */}
      {contentEnhancement.posterizarr && (
        <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2 }}>
          <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Posterizarr</Typography>
          <Box display="flex" gap={2} alignItems="center">
            <Typography style={{ color: '#fff' }}>Posterizarr URL</Typography>
            <input
              name="posterizarrUrl"
              value={config.posterizarrUrl}
              onChange={handleChange}
              placeholder="http://posterizarr:8000"
              style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
            />
          </Box>
          <Box display="flex" gap={2} alignItems="center" mt={2}>
            <Typography style={{ color: '#fff' }}>Posterizarr API Key</Typography>
            <input
              name="posterizarrApiKey"
              value={config.posterizarrApiKey}
              onChange={handleChange}
              placeholder="API Key"
              style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
            />
          </Box>
        </Box>
      )}

      {/* Placeholdarr - basic fields only */}
      {contentEnhancement.placeholdarr && (
        <Box sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2 }}>
          <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>Placeholdarr</Typography>
          <Box display="flex" gap={2} alignItems="center">
            <Typography style={{ color: '#fff' }}>Plex URL</Typography>
            <input name="placeholdarrSettings.PLEX_URL" value={config.placeholdarrSettings?.PLEX_URL || ''} onChange={handleChange} placeholder="http://plex:32400" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
          </Box>
          <Box display="flex" gap={2} alignItems="center" mt={2}>
            <Typography style={{ color: '#fff' }}>Plex Token</Typography>
            <input name="placeholdarrSettings.PLEX_TOKEN" value={config.placeholdarrSettings?.PLEX_TOKEN || ''} onChange={handleChange} placeholder="Token" style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
          </Box>
        </Box>
      )}

    </Box>
  );
}
