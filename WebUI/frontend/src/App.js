import React, { useEffect } from 'react';
import { Container, Typography, Box, Stepper, Step, StepLabel, Button, Tooltip, Divider } from '@mui/material';
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
  const [showProgress, setShowProgress] = React.useState(false);
  const [progress, setProgress] = React.useState(0);
  const [progressMessage, setProgressMessage] = React.useState('');
  const [timeEstimate, setTimeEstimate] = React.useState(0);

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
                      {/* Info tooltips for each field */}
                      {/** Helper for info tooltips */}
                      {(() => {
                        // Field descriptions for tooltips
                        const fieldInfo = {
                          port: 'The main HTTP port for the web interface.',
                          sslPort: 'The HTTPS port for secure web access.',
                          enableSsl: 'Enable or disable SSL (HTTPS) for the web interface.',
                          apiKey: 'API key for accessing the service programmatically.',
                          urlBase: 'Base URL path if running behind a reverse proxy (e.g. /radarr).',
                          authMethod: 'Authentication method for the web interface.',
                          logLevel: 'Verbosity of logs written by the service.',
                          branch: 'Branch or release channel to use for updates.',
                          launchBrowser: 'Whether to launch a browser window on startup.',
                          analyticsEnabled: 'Allow sending anonymous usage analytics.',
                          updateAutomatically: 'Enable automatic updates for the service.',
                          updateMechanism: 'How updates are applied (Docker, Script, None).',
                          logRotate: 'Number of days to keep log files before rotating.',
                          backupRetention: 'Number of days to keep backups before deleting.',
                          proxyEnabled: 'Enable or disable use of a proxy server.',
                          proxyType: 'Type of proxy server (HTTP or SOCKS5).',
                          proxyHostname: 'Hostname or IP address of the proxy server.',
                          proxyPort: 'Port number of the proxy server.',
                          proxyUsername: 'Username for proxy authentication.',
                          proxyPassword: 'Password for proxy authentication.',
                          appData: 'Path to the application data directory.',
                          configPath: 'Path to the main configuration file.'
                        };
                        // Expose for use in field rendering
                        return null;
                      })()}
                      {/* Main network and API settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="The main HTTP port for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
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
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            SSL Port
                            <Tooltip title="The HTTPS port for secure web access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_sslport`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].sslPort || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], sslPort: val } }));
                            }}
                            placeholder="443"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Enable SSL
                            <Tooltip title="Enable or disable SSL (HTTPS) for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_enablessl`}
                            value={config[`${service}Settings`].enableSsl || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], enableSsl: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={2}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for accessing the service programmatically.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_apikey`}
                            value={config[`${service}Settings`].apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={2}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            URL Base
                            <Tooltip title="Base URL path if running behind a reverse proxy (e.g. /radarr).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_urlbase`}
                            value={config[`${service}Settings`].urlBase || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], urlBase: e.target.value } }))}
                            placeholder="/radarr or /sonarr or /prowlarr"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Authentication Method
                            <Tooltip title="Authentication method for the web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by the service.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
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
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Branch
                            <Tooltip title="Branch or release channel to use for updates.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_branch`}
                            value={config[`${service}Settings`].branch}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Launch Browser
                            <Tooltip title="Whether to launch a browser window on startup.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
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
                      {/* Advanced/optional settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Analytics Enabled
                            <Tooltip title="Allow sending anonymous usage analytics.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_analytics`}
                            value={config[`${service}Settings`].analyticsEnabled || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], analyticsEnabled: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Update Automatically
                            <Tooltip title="Enable automatic updates for the service.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_updateauto`}
                            value={config[`${service}Settings`].updateAutomatically || 'true'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], updateAutomatically: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="true">True</option>
                            <option value="false">False</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Update Mechanism
                            <Tooltip title="How updates are applied (Docker, Script, None).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_updatemechanism`}
                            value={config[`${service}Settings`].updateMechanism || 'docker'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], updateMechanism: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="docker">Docker</option>
                            <option value="script">Script</option>
                            <option value="none">None</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Rotate (days)
                            <Tooltip title="Number of days to keep log files before rotating.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_logrotate`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].logRotate || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], logRotate: val } }));
                            }}
                            placeholder="7"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Backup Retention (days)
                            <Tooltip title="Number of days to keep backups before deleting.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_backupretention`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].backupRetention || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], backupRetention: val } }));
                            }}
                            placeholder="30"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      {/* Proxy settings */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Enabled
                            <Tooltip title="Enable or disable use of a proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_proxyenabled`}
                            value={config[`${service}Settings`].proxyEnabled || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyEnabled: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Type
                            <Tooltip title="Type of proxy server (HTTP or SOCKS5).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name={`${service}_proxytype`}
                            value={config[`${service}Settings`].proxyType || 'http'}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyType: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="http">HTTP</option>
                            <option value="socks5">SOCKS5</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Hostname
                            <Tooltip title="Hostname or IP address of the proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyhostname`}
                            value={config[`${service}Settings`].proxyHostname || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyHostname: e.target.value } }))}
                            placeholder="proxy.example.com"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Port
                            <Tooltip title="Port number of the proxy server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyport`}
                            type="text"
                            inputMode="numeric"
                            pattern="[0-9]*"
                            value={config[`${service}Settings`].proxyPort || ''}
                            onChange={e => {
                              const val = e.target.value.replace(/[^0-9]/g, '');
                              setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyPort: val } }));
                            }}
                            placeholder="8080"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Username
                            <Tooltip title="Username for proxy authentication.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxyusername`}
                            value={config[`${service}Settings`].proxyUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyUsername: e.target.value } }))}
                            placeholder="username"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Proxy Password
                            <Tooltip title="Password for proxy authentication.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_proxypassword`}
                            type="password"
                            value={config[`${service}Settings`].proxyPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], proxyPassword: e.target.value } }))}
                            placeholder="password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      {/* Additional paths (advanced) */}
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            App Data Path
                            <Tooltip title="Path to the application data directory.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_appdata`}
                            value={config[`${service}Settings`].appData || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], appData: e.target.value } }))}
                            placeholder="/config/{service}"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Config Path
                            <Tooltip title="Path to the main configuration file.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name={`${service}_configpath`}
                            value={config[`${service}Settings`].configPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, [`${service}Settings`]: { ...prev[`${service}Settings`], configPath: e.target.value } }))}
                            placeholder="/config/{service}/config.xml"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  ) : service === 'cinesync' ? (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            WebUI Port
                            <Tooltip title="The port for the Cinesync web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_webuiPort"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Server Port
                            <Tooltip title="The port for the Cinesync API server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_apiPort"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            WebDAV Port
                            <Tooltip title="The port for the Cinesync WebDAV server.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_webdavPort"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for accessing the Cinesync API.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_apiKey"
                            value={config.cinesyncSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Authentication Method
                            <Tooltip title="Authentication method for the Cinesync web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_authMethod"
                            value={config.cinesyncSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by Cinesync.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_logLevel"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Branch
                            <Tooltip title="Branch or release channel to use for Cinesync updates.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="cinesync_branch"
                            value={config.cinesyncSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, cinesyncSettings: { ...prev.cinesyncSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Launch Browser
                            <Tooltip title="Whether to launch a browser window on Cinesync startup.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="cinesync_launchBrowser"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for accessing Placeholdarr.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="placeholdarr_apiKey"
                            value={config.placeholdarrSettings.apiKey}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, apiKey: e.target.value } }))}
                            placeholder="surgestack"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Authentication Method
                            <Tooltip title="Authentication method for the Placeholdarr web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="placeholdarr_authMethod"
                            value={config.placeholdarrSettings.authMethod}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, authMethod: e.target.value } }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="Basic">Basic</option>
                            <option value="Forms">Forms</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Log Level
                            <Tooltip title="Verbosity of logs written by Placeholdarr.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="placeholdarr_logLevel"
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
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Branch
                            <Tooltip title="Branch or release channel to use for Placeholdarr updates.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="placeholdarr_branch"
                            value={config.placeholdarrSettings.branch}
                            onChange={e => setConfig(prev => ({ ...prev, placeholdarrSettings: { ...prev.placeholdarrSettings, branch: e.target.value } }))}
                            placeholder="master"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Launch Browser
                            <Tooltip title="Whether to launch a browser window on Placeholdarr startup.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="placeholdarr_launchBrowser"
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
                  {/* NZBGet fields */}
                  {tool.key === 'nzbget' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where NZBGet is accessible (e.g. http://nzbget:6789).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="nzbget_url"
                            value={config.nzbgetUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetUrl: e.target.value }))}
                            placeholder="http://nzbget:6789"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="The port NZBGet listens on (default: 6789).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="nzbget_port"
                            value={config.nzbgetPort || ''}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetPort: e.target.value }))}
                            placeholder="6789"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            SSL/TLS
                            <Tooltip title="Enable SSL/TLS for secure NZBGet access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select
                            name="nzbget_ssl"
                            value={config.nzbgetSsl || 'false'}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetSsl: e.target.value }))}
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}
                          >
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Username
                            <Tooltip title="Username for NZBGet web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="nzbget_username"
                            value={config.nzbgetUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetUsername: e.target.value }))}
                            placeholder="nzbget"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Password
                            <Tooltip title="Password for NZBGet web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="nzbget_password"
                            type="password"
                            value={config.nzbgetPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetPassword: e.target.value }))}
                            placeholder="password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for NZBGet RPC access (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="nzbget_apikey"
                            value={config.nzbgetApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, nzbgetApiKey: e.target.value }))}
                            placeholder="API Key (optional)"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* RDT-Client fields */}
                  {tool.key === 'rdtclient' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where RDT-Client is accessible (e.g. http://rdtclient:6500).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_url"
                            value={config.rdtClientUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientUrl: e.target.value }))}
                            placeholder="http://rdtclient:6500"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Port
                            <Tooltip title="The port RDT-Client listens on (default: 6500).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_port"
                            value={config.rdtClientPort || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientPort: e.target.value }))}
                            placeholder="6500"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for RDT-Client access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_apikey"
                            value={config.rdtClientApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Username
                            <Tooltip title="Username for RDT-Client web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_username"
                            value={config.rdtClientUsername || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientUsername: e.target.value }))}
                            placeholder="username"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Password
                            <Tooltip title="Password for RDT-Client web interface.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_password"
                            type="password"
                            value={config.rdtClientPassword || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientPassword: e.target.value }))}
                            placeholder="password"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Path
                            <Tooltip title="Path where RDT-Client will save downloads.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="rdtclient_downloadPath"
                            value={config.rdtClientDownloadPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, rdtClientDownloadPath: e.target.value }))}
                            placeholder="/downloads"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* GAPS fields */}
                  {tool.key === 'gaps' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where GAPS is accessible (e.g. http://gaps:8484).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_url"
                            value={config.gapsUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsUrl: e.target.value }))}
                            placeholder="http://gaps:8484"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for GAPS access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_apikey"
                            value={config.gapsApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Radarr URL
                            <Tooltip title="The URL for your Radarr instance used by GAPS.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_radarrUrl"
                            value={config.gapsRadarrUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsRadarrUrl: e.target.value }))}
                            placeholder="http://radarr:7878"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Radarr API Key
                            <Tooltip title="API key for your Radarr instance used by GAPS.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="gaps_radarrApiKey"
                            value={config.gapsRadarrApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, gapsRadarrApiKey: e.target.value }))}
                            placeholder="Radarr API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Zurg fields */}
                  {tool.key === 'zurg' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where Zurg is accessible (e.g. http://zurg:9000).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_url"
                            value={config.zurgUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgUrl: e.target.value }))}
                            placeholder="http://zurg:9000"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for Zurg access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_apikey"
                            value={config.zurgApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Path
                            <Tooltip title="Path where Zurg will save downloads.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="zurg_downloadPath"
                            value={config.zurgDownloadPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, zurgDownloadPath: e.target.value }))}
                            placeholder="/downloads"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Decypharr fields */}
                  {tool.key === 'decypharr' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Host/URL
                            <Tooltip title="The URL or IP address where Decypharr is accessible (e.g. http://decypharr:8081).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_url"
                            value={config.decypharrUrl || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrUrl: e.target.value }))}
                            placeholder="http://decypharr:8081"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            API Key
                            <Tooltip title="API key for Decypharr access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_apikey"
                            value={config.decypharrApiKey || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrApiKey: e.target.value }))}
                            placeholder="API Key"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>
                            Download Path
                            <Tooltip title="Path where Decypharr will save downloads.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input
                            name="decypharr_downloadPath"
                            value={config.decypharrDownloadPath || ''}
                            onChange={e => setConfig(prev => ({ ...prev, decypharrDownloadPath: e.target.value }))}
                            placeholder="/downloads"
                            style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8, '::placeholder': { color: '#bbb' } }}
                          />
                        </Box>
                      </Box>
                    </Box>
                  )}
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
                  {/* Overseerr fields (all variables, with info icons and tooltips) */}
                  {tool.key === 'overseerr' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Host/URL
                            <Tooltip title="The URL or IP address where Overseerr is accessible (e.g. http://overseerr:5055).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_url" value={config.overseerrUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrUrl: e.target.value }))} placeholder="http://overseerr:5055" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Port
                            <Tooltip title="The port Overseerr listens on (default: 5055).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_port" value={config.overseerrPort || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrPort: e.target.value }))} placeholder="5055" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>SSL/TLS
                            <Tooltip title="Enable SSL/TLS for secure Overseerr access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <select name="overseerr_ssl" value={config.overseerrSsl || 'false'} onChange={e => setConfig(prev => ({ ...prev, overseerrSsl: e.target.value }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}>
                            <option value="false">False</option>
                            <option value="true">True</option>
                          </select>
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Base URL
                            <Tooltip title="Base URL for Overseerr if running behind a reverse proxy (e.g. /overseerr).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_baseurl" value={config.overseerrBaseUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrBaseUrl: e.target.value }))} placeholder="/overseerr" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>API Key
                            <Tooltip title="API key for Overseerr API access.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_apikey" value={config.overseerrApiKey || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrApiKey: e.target.value }))} placeholder="API Key" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Username
                            <Tooltip title="Username for Overseerr web interface (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_username" value={config.overseerrUsername || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrUsername: e.target.value }))} placeholder="username (optional)" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Password
                            <Tooltip title="Password for Overseerr web interface (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_password" type="password" value={config.overseerrPassword || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrPassword: e.target.value }))} placeholder="password (optional)" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Default Language
                            <Tooltip title="Default language for Overseerr UI and notifications.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_language" value={config.overseerrLanguage || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrLanguage: e.target.value }))} placeholder="en" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                      </Box>
                      <Box display="flex" gap={2}>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Log Level
                            <Tooltip title="Logging level for Overseerr (info, debug, warn, error).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_loglevel" value={config.overseerrLogLevel || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrLogLevel: e.target.value }))} placeholder="info" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Notification Email
                            <Tooltip title="Email address for Overseerr notifications.">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_email" value={config.overseerrEmail || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrEmail: e.target.value }))} placeholder="user@email.com" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Request Limit
                            <Tooltip title="Maximum number of requests per user (if set).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_requestlimit" value={config.overseerrRequestLimit || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRequestLimit: e.target.value }))} placeholder="10" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                        </Box>
                        <Box flex={1}>
                          <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Authentication Method
                            <Tooltip title="Authentication method for Overseerr (e.g. Plex, local, etc).">
                              <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                              </span>
                            </Tooltip>
                          </Typography>
                          <input name="overseerr_authmethod" value={config.overseerrAuthMethod || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrAuthMethod: e.target.value }))} placeholder="plex" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                      <Divider style={{ margin: '24px 0', background: '#444' }} />
                      <Box display="flex" gap={0}>
                        {/* Radarr Integration */}
                        <Box flex={1}>
                          <Typography variant="h6" style={{ color: '#fff', marginBottom: 8 }}>Radarr Integration</Typography>
                          <Box display="flex" flexDirection="column" gap={2}>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Radarr URL
                                <Tooltip title="The URL or IP address of your Radarr server (e.g. http://radarr:7878).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_radarr_url" value={config.overseerrRadarrUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrUrl: e.target.value }))} placeholder="http://radarr:7878" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Radarr API Key
                                <Tooltip title="API key for your Radarr server (Settings > General > Security).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_radarr_apikey" value={config.overseerrRadarrApiKey || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrApiKey: e.target.value }))} placeholder="Radarr API Key" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Radarr Default Profile
                                <Tooltip title="Default quality profile to use for Radarr requests (e.g. HD-1080p).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_radarr_profile" value={config.overseerrRadarrProfile || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrProfile: e.target.value }))} placeholder="HD-1080p" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Radarr Root Folder
                                <Tooltip title="Root folder path in Radarr where movies will be stored (e.g. /movies).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_radarr_root" value={config.overseerrRadarrRoot || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrRoot: e.target.value }))} placeholder="/movies" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Radarr Minimum Availability
                                <Tooltip title="Minimum availability for Radarr requests (e.g. announced, released, cinemas, etc).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_radarr_min_avail" value={config.overseerrRadarrMinAvail || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrMinAvail: e.target.value }))} placeholder="released" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Enable Radarr
                                <Tooltip title="Enable or disable Radarr integration in Overseerr.">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <select name="overseerr_radarr_enabled" value={config.overseerrRadarrEnabled || 'true'} onChange={e => setConfig(prev => ({ ...prev, overseerrRadarrEnabled: e.target.value }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}>
                                <option value="true">True</option>
                                <option value="false">False</option>
                              </select>
                            </Box>
                          </Box>
                        </Box>
                        {/* Sonarr Integration */}
                        <Box flex={1}>
                          <Typography variant="h6" style={{ color: '#fff', marginBottom: 8 }}>Sonarr Integration</Typography>
                          <Box display="flex" flexDirection="column" gap={2}>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Sonarr URL
                                <Tooltip title="The URL or IP address of your Sonarr server (e.g. http://sonarr:8989).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_sonarr_url" value={config.overseerrSonarrUrl || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrUrl: e.target.value }))} placeholder="http://sonarr:8989" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Sonarr API Key
                                <Tooltip title="API key for your Sonarr server (Settings > General > Security).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_sonarr_apikey" value={config.overseerrSonarrApiKey || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrApiKey: e.target.value }))} placeholder="Sonarr API Key" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Sonarr Default Profile
                                <Tooltip title="Default quality profile to use for Sonarr requests (e.g. HD-1080p).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_sonarr_profile" value={config.overseerrSonarrProfile || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrProfile: e.target.value }))} placeholder="HD-1080p" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Sonarr Root Folder
                                <Tooltip title="Root folder path in Sonarr where series will be stored (e.g. /tv).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_sonarr_root" value={config.overseerrSonarrRoot || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrRoot: e.target.value }))} placeholder="/tv" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Sonarr Minimum Availability
                                <Tooltip title="Minimum availability for Sonarr requests (e.g. announced, released, continuing, etc).">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <input name="overseerr_sonarr_min_avail" value={config.overseerrSonarrMinAvail || ''} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrMinAvail: e.target.value }))} placeholder="continuing" style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }} />
                            </Box>
                            <Box>
                              <Typography style={{ color: '#fff', display: 'flex', alignItems: 'center' }}>Enable Sonarr
                                <Tooltip title="Enable or disable Sonarr integration in Overseerr.">
                                  <span style={{ marginLeft: 4, cursor: 'pointer', color: '#79eaff' }}>
                                    <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' strokeWidth='2' strokeLinecap='round' strokeLinejoin='round'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg>
                                  </span>
                                </Tooltip>
                              </Typography>
                              <select name="overseerr_sonarr_enabled" value={config.overseerrSonarrEnabled || 'true'} onChange={e => setConfig(prev => ({ ...prev, overseerrSonarrEnabled: e.target.value }))} style={{ width: '100%', background: '#222', color: '#fff', border: '1px solid #444', borderRadius: 4, padding: 8 }}>
                                <option value="true">True</option>
                                <option value="false">False</option>
                              </select>
                            </Box>
                          </Box>
                        </Box>
                      </Box>
                        </Box>
                      </Box>
                    </Box>
                  )}
                  {/* Tautulli fields (expanded) */}
                  {tool.key === 'tautulli' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      {/* ...Tautulli fields as above... */}
                    </Box>
                  )}
                  {/* Homepage fields */}
                  {tool.key === 'homepage' && (
                    <Box display="flex" flexDirection="column" gap={2}>
                      {/* ...Homepage fields as above... */}
                    </Box>
                  )}
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
                onClick={async () => {
                  setShowProgress(true);
                  setProgress(0);
                  setProgressMessage('Adjusting configs...');
                  setTimeEstimate(10); // initial estimate in seconds
                  // Simulate progress
                  let percent = 0;
                  let interval = setInterval(() => {
                    percent += 10;
                    setProgress(percent);
                    setTimeEstimate((prev) => prev - 1);
                    if (percent >= 100) {
                      clearInterval(interval);
                      setProgressMessage('Deploying containers...');
                    }
                  }, 1000);
                  await handleDeploy();
                  setShowProgress(false);
                }}
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
              {showProgress && (
                <Box mt={2}>
                  <Typography style={{ color: '#fff' }}>{progressMessage} {progress}% ({timeEstimate}s left)</Typography>
                  <Box sx={{ width: '100%', background: '#333', borderRadius: 4, mt: 1 }}>
                    <Box sx={{ width: `${progress}%`, background: '#07938f', height: 12, borderRadius: 4, transition: 'width 0.5s' }} />
                  </Box>
                </Box>
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
