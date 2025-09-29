import React from 'react';
import { Box, Typography, Button, Tooltip } from '@mui/material';
import radarrLogo from './assets/service-logos/radarr.png';
import sonarrLogo from './assets/service-logos/sonarr.png';
import bazarrLogo from './assets/service-logos/bazarr.png';
import prowlarrLogo from './assets/service-logos/prowlarr.png';
import nzbgetLogo from './assets/service-logos/NZBGet.png';
import cliDebridLogo from './assets/service-logos/RDT-Client.png';
import decypharrLogo from './assets/service-logos/decypharr.png';
import posterizarrLogo from './assets/service-logos/posterizarr.png';
import cinesyncLogo from './assets/service-logos/cinesync.png';
import placeholdarrLogo from './assets/service-logos/Placeholdarr.png';
import overseerrLogo from './assets/service-logos/overseerr.png';
import tautulliLogo from './assets/service-logos/tautulli.png';
import gapsLogo from './assets/service-logos/gaps.jpg';
import homepageLogo from './assets/service-logos/homepage.png';
import kometaLogo from './assets/service-logos/kometa.png';
import pangolinLogo from './assets/service-logos/pangolin.png';
import dockupdaterLogo from './assets/service-logos/dockupdater.png';

import { getPangolinSetupToken } from './utils/readEnvToken';

export default function AdditionalServicesStep(props) {
  const {
    contentEnhancementList,
    contentEnhancement,
    setContentEnhancement,
    config,
    setConfig,
    handleChange
  } = props;

  // Auto-populate Pangolin setup token on first render
  React.useEffect(() => {
    async function fetchToken() {
      const token = await getPangolinSetupToken();
      if (token && !config.pangolinSetupToken) {
        setConfig(prev => ({ ...prev, pangolinSetupToken: token }));
      }
    }
    fetchToken();
  }, [setConfig, config.pangolinSetupToken]);

  // Default selected services
  React.useEffect(() => {
    const defaultSelected = {
      radarr: true,
      sonarr: true,
      prowlarr: true,
      bazarr: true,
      nzbget: true,
      'cli-debrid': false,
      decypharr: true,
      posterizarr: true,
      cinesync: true,
      placeholdarr: false,
      overseerr: true,
      tautulli: true,
      gaps: true,
      homepage: false,
      dockupdater: true,
      pangolin: true,
      kometa: true
    };
    // Only set defaults on first render
    setContentEnhancement((prev) => ({ ...defaultSelected, ...prev }));
  }, [setContentEnhancement]);

  // List of all services from docker-compose.yml
  const allServices = [
    'radarr', 'sonarr', 'bazarr', 'prowlarr', 'nzbget', 'cli-debrid', 'decypharr', 'posterizarr', 'cinesync', 'placeholdarr', 'overseerr', 'tautulli', 'gaps', 'homepage', 'dockupdater', 'pangolin', 'kometa'
  ];
  // Optionally, you can add logo and description for each service here
  const serviceMeta = {
    radarr: { name: 'Radarr', desc: 'Movie manager', logo: radarrLogo },
    sonarr: { name: 'Sonarr', desc: 'TV series manager', logo: sonarrLogo },
    bazarr: { name: 'Bazarr', desc: 'Subtitle manager', logo: bazarrLogo },
    prowlarr: { name: 'Prowlarr', desc: 'Indexer manager', logo: prowlarrLogo },
    nzbget: { name: 'NZBGet', desc: 'Usenet downloader', logo: nzbgetLogo },
    'cli-debrid': { name: 'cli-debrid', desc: 'Debrid CLI tool', logo: cliDebridLogo },
    decypharr: { name: 'Decypharr', desc: 'Qbittorrent API w/Debrid Support', logo: decypharrLogo },
    posterizarr: { name: 'Posterizarr', desc: 'Poster automation', logo: posterizarrLogo },
    cinesync: { name: 'CineSync', desc: 'Media folder manager', logo: cinesyncLogo },
    placeholdarr: { name: 'Placeholdarr', desc: 'Placeholder files', logo: placeholdarrLogo },
    overseerr: { name: 'Overseerr', desc: 'Media requests', logo: overseerrLogo },
    tautulli: { name: 'Tautulli', desc: 'Plex analytics', logo: tautulliLogo },
    gaps: { name: 'GAPS', desc: 'Missing movies finder', logo: gapsLogo },
    homepage: { name: 'Homepage', desc: 'Unified dashboard', logo: homepageLogo },
    dockupdater: { name: 'Dockupdater', desc: 'Docker updater', logo: dockupdaterLogo },
    pangolin: { name: 'Pangolin', desc: 'Tunneled Reverse Proxy', logo: pangolinLogo },
    kometa: { name: 'Kometa', desc: 'Collection and metadata manager', logo: kometaLogo }
  };
  return (
    <Box sx={{ p: 4 }}>
      <Typography variant="h6" align="center" style={{ color: '#fff', marginBottom: 16 }}>Service Selection</Typography>
      <Box display="flex" flexWrap="wrap" gap={2} mb={3} justifyContent="center">
        {allServices.map((key) => (
          <Tooltip key={key} title={serviceMeta[key]?.desc || key} placement="top">
            <Box
              onClick={() => setContentEnhancement((prev) => ({ ...prev, [key]: !prev[key] }))}
              sx={{
                cursor: 'pointer',
                opacity: contentEnhancement[key] ? 1 : 0.4,
                filter: contentEnhancement[key] ? 'none' : 'grayscale(100%)',
                borderRadius: 2,
                p: 0.5,
                background: '#181818',
                transition: 'all 0.2s',
                position: 'relative',
                boxShadow: 'none',
                '&:hover': { boxShadow: 'none' },
                width: 100,
                height: 120,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center'
              }}
            >
              {serviceMeta[key]?.logo && <img src={serviceMeta[key].logo} alt={serviceMeta[key].name} style={{ width: 48, height: 48, display: 'block', margin: '0 auto' }} />}
              <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{serviceMeta[key]?.name || key}</Typography>
              {!contentEnhancement[key] && (
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

      {/* Placeholdarr config UI can be added here if needed */}

    </Box>
  );
}
