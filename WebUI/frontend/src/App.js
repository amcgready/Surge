import React, { useEffect } from 'react';
import { Container, Typography, Box, Stepper, Step, StepLabel, Button, Tooltip } from '@mui/material';
import SurgeLogo from './SurgeLogo';
import bgImage from './assets/background.jpg';
import radarrLogo from './assets/service-logos/radarr.png';
import sonarrLogo from './assets/service-logos/sonarr.png';
import prowlarrLogo from './assets/service-logos/prowlarr.png';
import bazarrLogo from './assets/service-logos/bazarr.png';
import cinesyncLogo from './assets/service-logos/cinesync.png';
import placeholdarrLogo from './assets/service-logos/Placeholdarr.png';
import plexLogo from './assets/service-logos/plex.png';
import embyLogo from './assets/service-logos/emby.png';
import jellyfinLogo from './assets/service-logos/jellyfin.png';
import nzbgetLogo from './assets/service-logos/NZBGet.png';
import rdtClientLogo from './assets/service-logos/RDT-Client.png';
import gapsLogo from './assets/service-logos/gaps.jpg';
import zurgLogo from './assets/service-logos/zurg.png';
import decypharrLogo from './assets/service-logos/decypharr.png';

const steps = [
  'Welcome',
  'Media Server',
  'Storage Config',
  'Media Automation',
  'Download Tools',
  'Content Enhancement',
  'Monitoring & UI',
  'Shared Config',
  'Review',
  'Deploy'
];

function App() {
  // Monitoring & Interface toggles
  const monitoringList = [
    { key: 'overseerr', name: 'Overseerr', desc: 'Media request and management tool', logo: require('./assets/service-logos/overseerr.png') },
    { key: 'tautulli', name: 'Tautulli', desc: 'Plex monitoring and analytics', logo: require('./assets/service-logos/tautulli.png') },
    { key: 'homepage', name: 'Homepage', desc: 'Unified dashboard for your media server', logo: require('./assets/service-logos/homepage.png') }
  ];
  const [monitoring, setMonitoring] = React.useState({
    overseerr: true,
    tautulli: true,
    homepage: true
  });
  // Content Enhancement toggles
  const contentEnhancementList = [
    { key: 'kometa', name: 'Kometa', desc: 'Collection and metadata management for Plex/Emby/Jellyfin', logo: require('./assets/service-logos/kometa.png') },
    { key: 'posterizarr', name: 'Posterizarr', desc: 'Automated poster and artwork management', logo: require('./assets/service-logos/posterizarr.png') }
  ];
  const [contentEnhancement, setContentEnhancement] = React.useState({
    kometa: true,
    posterizarr: true
  });
  // Download Tools toggles

  const downloadToolsList = [
    { key: 'nzbget', name: 'NZBGet', desc: 'Efficient Usenet downloader', logo: nzbgetLogo },
    { key: 'rdtclient', name: 'RDT-Client', desc: 'Real-Debrid download client', logo: rdtClientLogo },
    { key: 'gaps', name: 'GAPS', desc: 'Finds missing movies for Radarr', logo: gapsLogo },
    { key: 'zurg', name: 'Zurg', desc: 'NZBGet/Usenet automation tool', logo: zurgLogo },
    { key: 'decypharr', name: 'Decypharr', desc: 'Decryption and post-processing tool', logo: decypharrLogo }
  ];
  const [downloadTools, setDownloadTools] = React.useState({
    nzbget: true,
    rdtclient: true,
    gaps: true,
    zurg: true,
    decypharr: true
  });
  // Core Media Server single-select toggle
  const coreServers = [
    { key: 'plex', name: 'Plex', logo: plexLogo, desc: 'Premium media streaming platform' },
    { key: 'emby', name: 'Emby', logo: embyLogo, desc: 'Feature-rich media server with live TV support' },
    { key: 'jellyfin', name: 'Jellyfin', logo: jellyfinLogo, desc: 'Free and open-source media server' }
  ];
  const [activeStep, setActiveStep] = React.useState(0);

  const [mediaAutomation, setMediaAutomation] = React.useState({
    radarr: true,
    sonarr: true,
    prowlarr: true,
    bazarr: true,
    cinesync: true,
    placeholdarr: true
  });

  const defaultUrls = {
    radarr: 'http://radarr:7878',
    sonarr: 'http://sonarr:8989',
    prowlarr: 'http://prowlarr:9696',
    bazarr: 'http://bazarr:6767',
    cinesync: 'http://cinesync:8080',
    placeholdarr: 'http://placeholdarr:9090'
  };

  const serviceDescriptions = {
    radarr: 'Radarr: Movie collection manager for Usenet and BitTorrent',
    sonarr: 'Sonarr: TV series collection manager',
    prowlarr: 'Prowlarr: Indexer manager/proxy for torrent trackers and Usenet indexers',
    bazarr: 'Bazarr: Subtitle management for Radarr and Sonarr',
    cinesync: 'CineSync: Media library management for Movies & TV shows',
    placeholdarr: 'Placeholdarr: Creates placeholder files for undownloaded media'
  };

  const serviceLogos = {
    radarr: radarrLogo,
    sonarr: sonarrLogo,
    prowlarr: prowlarrLogo,
    bazarr: bazarrLogo,
    cinesync: cinesyncLogo,
    placeholdarr: placeholdarrLogo
  };

  const [config, setConfig] = React.useState({
    // Core Media Server
    mediaServer: '', // plex|emby|jellyfin
    // Storage Config
    storagePath: '',
    // Media Automation - Radarr settings
    radarrSettings: {
      port: 7878,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Media Automation - Sonarr settings
    sonarrSettings: {
      port: 8989,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Media Automation - Prowlarr settings
    prowlarrSettings: {
      port: 9696,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Media Automation - Bazarr settings
    bazarrSettings: {
      port: 6767,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Media Automation - CineSync settings
    cinesyncSettings: {
      webuiPort: 5173,
      apiPort: 8082,
      webdavPort: 8082,
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Media Automation - Placeholdarr settings
    placeholdarrSettings: {
      apiKey: 'surgestack',
      authMethod: 'Basic',
      logLevel: 'Info',
      branch: 'master',
      launchBrowser: 'false',
    },
    // Download Clients & Tools
    nzbgetUrl: '', nzbgetApiKey: '',
    rdtClientUrl: '', rdtClientApiKey: '',
    // Content Enhancement
    kometaUrl: '', kometaApiKey: '',
    posterizarrUrl: '', posterizarrApiKey: '',
    // Monitoring & Interface
    overseerrUrl: '', overseerrApiKey: '',
    tautulliUrl: '', tautulliApiKey: '',
    // Shared Configuration
    discordWebhook: '', traktApiKey: '', timezone: '', userId: '', groupId: ''
  });

  // Autodetect URLs and API keys (example: fetch from backend or localStorage)
  useEffect(() => {
    async function fetchDefaults() {
      // Try to fetch autodetected config from backend (implement endpoint if needed)
      try {
        const resp = await fetch('/api/autodetect');
        if (resp.ok) {
          const data = await resp.json();
          setConfig((prev) => ({ ...prev, ...data }));
        }
      } catch (e) {
        // fallback: try localStorage
        const local = localStorage.getItem('surge-setup');
        if (local) setConfig((prev) => ({ ...prev, ...JSON.parse(local) }));
      }
    }
    fetchDefaults();
  }, []);
  const [testResult, setTestResult] = React.useState('');
  const [deployResult, setDeployResult] = React.useState('');

  const handleNext = () => setActiveStep((prev) => prev + 1);
  const handleBack = () => setActiveStep((prev) => prev - 1);

  const handleChange = (e) => {
    setConfig({ ...config, [e.target.name]: e.target.value });
  };

  const handleTest = async (service) => {
    setTestResult('Testing...');
    let url = '', api_key = '';
    if (service === 'prowlarr') {
      url = config.prowlarrUrl; api_key = config.prowlarrApiKey;
    } else if (service === 'radarr') {
      url = config.radarrUrl; api_key = config.radarrApiKey;
    } else if (service === 'sonarr') {
      url = config.sonarrUrl; api_key = config.sonarrApiKey;
    }
    try {
      const resp = await fetch('/api/test_connection', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url, api_key })
      });
      const data = await resp.json();
      setTestResult(data.status === 'success' ? 'Connection successful!' : 'Failed: ' + (data.error || data.output));
    } catch (e) {
      setTestResult('Error: ' + e.message);
    }
  };

  const handleSave = async () => {
    localStorage.setItem('surge-setup', JSON.stringify(config));
    await fetch('/api/save_config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config)
    });
  };

  const handleDeploy = async () => {
    setDeployResult('Deploying...');
    try {
      const resp = await fetch('/api/deploy_services', { method: 'POST' });
      const data = await resp.json();
      setDeployResult(data.status === 'deployed' ? 'Deployment successful!' : 'Failed: ' + (data.error || data.output));
    } catch (e) {
      setDeployResult('Error: ' + e.message);
    }
  };

  return (
    <>
      <div style={{
        minHeight: '100vh',
        minWidth: '100vw',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundImage: `url(${bgImage})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundAttachment: 'fixed',
        zIndex: -1
      }} />
      <div style={{
        minHeight: '100vh',
        width: '100vw',
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1
      }}>
        <Container maxWidth="md" style={{ minWidth: 600, background: 'rgba(17,17,17,0.92)', borderRadius: 12, boxShadow: '0 0 24px #000', paddingBottom: 32 }}>
        <Box sx={{ my: 4 }}>
        <SurgeLogo />
        <Typography variant="h4" align="center" gutterBottom style={{ color: '#fff' }}>
          Surge Setup
        </Typography>
        <Stepper activeStep={activeStep} alternativeLabel>
          {steps.map((label, idx) => {
            // Only allow jumping if both mediaServer and storagePath are set, or if on welcome/core/storage steps
            const canJump =
              idx === 0 ||
              (idx === 1) ||
              (idx === 2) ||
              (config.mediaServer && config.storagePath);
            return (
              <Step key={label}>
                <StepLabel
                  sx={{
                    '& .MuiStepLabel-label': { color: '#fff !important' },
                    '& .MuiStepIcon-root': { color: canJump ? '#07938f' : '#444', cursor: canJump ? 'pointer' : 'not-allowed' }
                  }}
                  onClick={() => {
                    if (canJump) setActiveStep(idx);
                  }}
                  style={{ cursor: canJump ? 'pointer' : 'not-allowed' }}
                >
                  {label}
                </StepLabel>
              </Step>
            );
          })}
        </Stepper>
        <Box sx={{ my: 4 }}>
          {activeStep === 0 && (
            <Typography align="center" style={{ color: '#fff' }}>Welcome to Surge! Surge aims to take the hassle out of media server management by allowing you to easily deploy a media server and all the backend software you may need.</Typography>
          )}
          {activeStep === 1 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Core Media Server</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {coreServers.map((srv) => (
                  <Tooltip key={srv.key} title={srv.desc} placement="top">
                    <Box
                      onClick={() => setConfig((prev) => ({ ...prev, mediaServer: srv.key }))}
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
            </Box>
          )}
          {activeStep === 2 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Storage Config</Typography>
              <Typography style={{ color: '#fff', marginBottom: 8 }}>Where would you like to store your media and config?</Typography>
              <Box display="flex" gap={2} alignItems="center">
                <input
                  type="text"
                  name="storagePath"
                  placeholder="/mnt/media or /home/user/SurgeData"
                  value={config.storagePath}
                  onChange={handleChange}
                  style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                />
                <Button
                  variant="outlined"
                  style={{ color: '#fff', borderColor: '#fff', minWidth: 120 }}
                  onClick={async () => {
                    // Use the File System Access API if available
                    if (window.showDirectoryPicker) {
                      try {
                        const dirHandle = await window.showDirectoryPicker();
                        setConfig((prev) => ({ ...prev, storagePath: dirHandle.name }));
                      } catch (e) {
                        // User cancelled or not supported
                      }
                    } else {
                      alert('Directory picker is not supported in this browser. Please type the path manually.');
                    }
                  }}
                >
                  Browse
                </Button>
              </Box>
              <Typography style={{ color: '#aaa', fontSize: 13, marginTop: 8 }}>
                You can type a path or use the Browse button (if supported by your browser).
              </Typography>
            </Box>
          )}
          {activeStep === 3 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Media Automation & Management</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {Object.keys(serviceLogos).map((service) => (
                  <Tooltip key={service} title={serviceDescriptions[service]} placement="top">
                    <Box
                      onClick={() => setMediaAutomation((prev) => ({ ...prev, [service]: !prev[service] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: mediaAutomation[service] ? 1 : 0.4,
                        filter: mediaAutomation[service] ? 'none' : 'grayscale(100%)',
                        border: mediaAutomation[service] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: mediaAutomation[service] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={serviceLogos[service]} alt={service} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{service.charAt(0).toUpperCase() + service.slice(1)}</Typography>
                      {!mediaAutomation[service] && (
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
              {/* Sub-sections for enabled services */}
              {Object.keys(serviceLogos).filter((service) => mediaAutomation[service]).map((service) => (
                <Box key={service} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{service.charAt(0).toUpperCase() + service.slice(1)}</Typography>
                  {service === 'radarr' || service === 'sonarr' || service === 'prowlarr' || service === 'bazarr' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Port</Typography>
                          <input
                            name={`${service}_port`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].port}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], port: val } }));
                            }}
                            placeholder={service === 'radarr' ? '7878' : service === 'sonarr' ? '8989' : service === 'prowlarr' ? '9696' : '6767'}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={2}>
                          <Typography style={{ color: '#fff' }}>API Key</Typography>
                          <input
                            name={`${service}_apikey`}
                            value={config[`${service}Settings`].apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Authentication Method</Typography>
                          <select
                            name={`${service}_auth`}
                            value={config[`${service}Settings`].authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Log Level</Typography>
                          <select
                            name={`${service}_loglevel`}
                            value={config[`${service}Settings`].logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Branch</Typography>
                          <input
                            name={`${service}_branch`}
                            value={config[`${service}Settings`].branch}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Launch Browser</Typography>
                          <select
                            name={`${service}_launchbrowser`}
                            value={config[`${service}Settings`].launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                    </Box>
                  ) : service === 'cinesync' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>WebUI Port</Typography>
                          <input
                            name="cinesync_webuiport"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.webuiPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, webuiPort: val } }));
                            }}
                            placeholder="5173"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>API Server Port</Typography>
                          <input
                            name="cinesync_apiport"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.apiPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, apiPort: val } }));
                            }}
                            placeholder="8082"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>WebDAV Port</Typography>
                          <input
                            name="cinesync_webdavport"
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config.cinesyncSettings.webdavPort}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, webdavPort: val } }));
                            }}
                            placeholder="8082"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>API Key</Typography>
                          <input
                            name="cinesync_apikey"
                            value={config.cinesyncSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Authentication Method</Typography>
                          <select
                            name="cinesync_auth"
                            value={config.cinesyncSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Log Level</Typography>
                          <select
                            name="cinesync_loglevel"
                            value={config.cinesyncSettings.logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Branch</Typography>
                          <input
                            name="cinesync_branch"
                            value={config.cinesyncSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Launch Browser</Typography>
                          <select
                            name="cinesync_launchbrowser"
                            value={config.cinesyncSettings.launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                    </Box>
                  ) : service === 'placeholdarr' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>API Key</Typography>
                          <input
                            name="placeholdarr_apikey"
                            value={config.placeholdarrSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Authentication Method</Typography>
                          <select
                            name="placeholdarr_auth"
                            value={config.placeholdarrSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Log Level</Typography>
                          <select
                            name="placeholdarr_loglevel"
                            value={config.placeholdarrSettings.logLevel}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, logLevel: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Trace">Trace</option>
                            <option value="Debug">Debug</option>
                            <option value="Info">Info</option>
                            <option value="Warn">Warn</option>
                            <option value="Error">Error</option>
                            <option value="Fatal">Fatal</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Branch</Typography>
                          <input
                            name="placeholdarr_branch"
                            value={config.placeholdarrSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff' }}>Launch Browser</Typography>
                          <select
                            name="placeholdarr_launchbrowser"
                            value={config.placeholdarrSettings.launchBrowser}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, launchBrowser: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                    </Box>
                  ) : (
                    <Typography style={{ color: '#bbb', fontStyle: 'italic' }}>Settings for {service} will appear here.</Typography>
                  )}
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 4 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Download Clients & Tools</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {downloadToolsList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setDownloadTools((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: downloadTools[tool.key] ? 1 : 0.4,
                        filter: downloadTools[tool.key] ? 'none' : 'grayscale(100%)',
                        border: downloadTools[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: downloadTools[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
                      {!downloadTools[tool.key] && (
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
              {/* Sub-sections for enabled download tools */}
              {downloadToolsList.filter((tool) => downloadTools[tool.key]).map((tool) => (
                <Box key={tool.key} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{tool.name}</Typography>
                  {/* TODO: Add {tool.name} settings here */}
                  <Typography style={{ color: '#bbb', fontStyle: 'italic' }}>Settings for {tool.name} will appear here.</Typography>
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 5 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Content Enhancement</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {contentEnhancementList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setContentEnhancement((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: contentEnhancement[tool.key] ? 1 : 0.4,
                        filter: contentEnhancement[tool.key] ? 'none' : 'grayscale(100%)',
                        border: contentEnhancement[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: contentEnhancement[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
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
              {/* Sub-sections for enabled content enhancement tools */}
              {contentEnhancementList.filter((tool) => contentEnhancement[tool.key]).map((tool) => (
                <Box key={tool.key} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{tool.name}</Typography>
                  {/* TODO: Add {tool.name} settings here */}
                  <Typography style={{ color: '#bbb', fontStyle: 'italic' }}>Settings for {tool.name} will appear here.</Typography>
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 6 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff', marginBottom: 16 }}>Monitoring & Interface</Typography>
              <Box display="flex" gap={3} mb={3} justifyContent="center">
                {monitoringList.map((tool) => (
                  <Tooltip key={tool.key} title={tool.desc} placement="top">
                    <Box
                      onClick={() => setMonitoring((prev) => ({ ...prev, [tool.key]: !prev[tool.key] }))}
                      sx={{
                        cursor: 'pointer',
                        opacity: monitoring[tool.key] ? 1 : 0.4,
                        filter: monitoring[tool.key] ? 'none' : 'grayscale(100%)',
                        border: monitoring[tool.key] ? '2px solid #07938f' : '2px solid #444',
                        borderRadius: 2,
                        p: 1,
                        background: '#181818',
                        transition: 'all 0.2s',
                        position: 'relative',
                        boxShadow: monitoring[tool.key] ? '0 0 8px #07938f' : 'none',
                        '&:hover': { boxShadow: '0 0 16px #07938f' }
                      }}
                    >
                      <img src={tool.logo} alt={tool.name} style={{ width: 64, height: 64, display: 'block', margin: '0 auto' }} />
                      <Typography align="center" style={{ color: '#fff', fontSize: 14, marginTop: 4 }}>{tool.name}</Typography>
                      {!monitoring[tool.key] && (
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
              {/* Sub-sections for enabled monitoring tools */}
              {monitoringList.filter((tool) => monitoring[tool.key]).map((tool) => (
                <Box key={tool.key} sx={{ background: '#232323', borderRadius: 2, p: 2, mb: 2, mt: 2, border: '2px solid #07938f' }}>
                  <Typography variant="subtitle1" style={{ color: '#fff', fontWeight: 600, marginBottom: 8 }}>{tool.name}</Typography>
                  {/* TODO: Add {tool.name} settings here */}
                  <Typography style={{ color: '#bbb', fontStyle: 'italic' }}>Settings for {tool.name} will appear here.</Typography>
                </Box>
              ))}
            </Box>
          )}
          {activeStep === 7 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Shared Configuration</Typography>
              <Box mb={2}>
                <Typography style={{ color: '#fff', marginBottom: 4 }}>Destination Directory</Typography>
                <Box display="flex" gap={2} alignItems="center">
                  <input
                    type="text"
                    name="destinationDirectory"
                    placeholder="/mnt/downloads or /home/user/Downloads"
                    value={config.destinationDirectory || ''}
                    onChange={handleChange}
                    style={{ flex: 1, background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                  />
                  <Button
                    variant="outlined"
                    style={{ color: '#fff', borderColor: '#fff', minWidth: 120 }}
                    onClick={async () => {
                      if (window.showDirectoryPicker) {
                        try {
                          const dirHandle = await window.showDirectoryPicker();
                          setConfig((prev) => ({ ...prev, destinationDirectory: dirHandle.name }));
                        } catch (e) {
                          // User cancelled or not supported
                        }
                      } else {
                        alert('Directory picker is not supported in this browser. Please type the path manually.');
                      }
                    }}
                  >
                    Browse
                  </Button>
                </Box>
                <Typography style={{ color: '#aaa', fontSize: 13, marginTop: 8 }}>
                  This directory will be used as the destination for all download clients.
                </Typography>
              </Box>
              <input name="discordWebhook" placeholder="Discord Webhook URL" value={config.discordWebhook} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="traktApiKey" placeholder="Trakt API Key" value={config.traktApiKey} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="timezone" placeholder="Timezone (e.g. UTC, America/New_York)" value={config.timezone} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="userId" placeholder="User ID (default 1000)" value={config.userId} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
              <input name="groupId" placeholder="Group ID (default 1000)" value={config.groupId} onChange={handleChange} style={{width:'100%',margin:'8px 0',background:'#222',color:'#fff',border:'1px solid #444',borderRadius:4}} />
            </Box>
          )}
          {activeStep === 8 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Review</Typography>
              <pre style={{ color: '#fff', background: '#222', padding: 12, borderRadius: 4 }}>{JSON.stringify(config, null, 2)}</pre>
              <Button onClick={handleSave} variant="contained">Save Configuration</Button>
            </Box>
          )}
          {activeStep === 9 && (
            <Box>
              <Typography variant="h6" style={{ color: '#fff' }}>Deploy</Typography>
              <Button 
                onClick={handleDeploy} 
                variant="contained"
                disabled={!config.mediaServer || !config.storagePath}
              >
                Deploy Services
              </Button>
              {(!config.mediaServer || !config.storagePath) && (
                <Typography style={{ color: '#ffb300', marginTop: 8 }}>
                  Please set both a Media Server and Storage Path before deploying.
                </Typography>
              )}
              <Typography style={{ color: '#fff' }}>{deployResult}</Typography>
            </Box>
          )}
        </Box>
        <Box display="flex" justifyContent="space-between">
          <Button disabled={activeStep === 0} onClick={handleBack} variant="outlined" style={{ color: '#fff', borderColor: '#fff' }}>Back</Button>
          <Button
            disabled={
              (activeStep === 1 && !config.mediaServer) ||
              (activeStep === 2 && !config.storagePath) ||
              activeStep === steps.length - 1
            }
            onClick={handleNext}
            variant="outlined"
            style={{ color: '#fff', borderColor: '#fff' }}
          >
            Next
          </Button>
        </Box>
      </Box>
      </Container>
      </div>
    </>
  );
}

export default App;
